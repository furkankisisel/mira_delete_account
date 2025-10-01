import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../design_system/theme/theme_variations.dart';

import '../../design_system/components/mood_chip.dart';
import '../../design_system/tokens/colors.dart';
import 'data/mood_entry.dart';
import 'data/mood_repository.dart';
import '../../l10n/app_localizations.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key, required this.variant});

  final ThemeVariant variant;

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _repo = MoodRepository();

  MoodValue? _selected;
  final _noteCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _repo.initialize().then((_) async {
      final today = DateTime.now();
      final existing = _repo.getForDate(today);
      if (existing != null) {
        _selected = existing.mood;
        _noteCtrl.text = existing.note ?? '';
      }
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveToday() async {
    final mood = _selected;
    if (mood == null) return;
    await _repo.upsertForDate(
      DateTime.now(),
      mood,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.saved)));
    setState(() {}); // refresh analysis tab
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final bool usePurple = widget.variant == ThemeVariant.world;
    final themed = usePurple
        ? base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: AppColors.accentPurple,
            ),
          )
        : base;
    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).mood),
          bottom: TabBar(
            controller: _tab,
            tabs: [
              Tab(text: AppLocalizations.of(context).input),
              Tab(text: AppLocalizations.of(context).analysis),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tab,
                children: [_buildInputTab(context), _buildAnalysisTab(context)],
              ),
      ),
    );
  }

  Widget _buildInputTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final moods = MoodValue.values;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pickTodaysMood,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final m in moods)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: DsMoodChip(
                      label: _localizedMoodLabel(m, l10n),
                      icon: m.icon,
                      baseColor: _colorForMood(m),
                      selected: _selected == m,
                      onTap: () => setState(() => _selected = m),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.noteOptional,
              prefixIcon: const Icon(Icons.notes),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _selected == null ? null : _saveToday,
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = _repo.all();
    final avg30 = _repo.averageScore(days: 30);
    final counts = _repo.counts(days: 30);
    final nf = NumberFormat('0.0');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _kpiCard(context, l10n.daysAverageShort(30), nf.format(avg30)),
              const SizedBox(width: 8),
              _kpiCard(context, l10n.entries, entries.length.toString()),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in MoodValue.values)
                _chipStat(
                  _localizedMoodLabel(m, l10n),
                  counts[m] ?? 0,
                  _colorForMood(m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      l10n.noEntriesYet,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      return ListTile(
                        leading: Icon(
                          e.mood.icon,
                          color: _colorForMood(e.mood),
                        ),
                        title: Text(DateFormat.yMMMEd().format(e.date)),
                        subtitle: e.note == null || e.note!.isEmpty
                            ? null
                            : Text(e.note!),
                        onLongPress: () => _showEntryMenu(context, e),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEntryMenu(BuildContext context, MoodEntry e) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _selected = e.mood;
                  _noteCtrl.text = e.note ?? '';
                  _tab.index = 0; // jump to input tab for editing
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                l10n.delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed =
                    await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: Text(l10n.delete),
                        content: Text(l10n.deleteEntryConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dctx, false),
                            child: Text(l10n.cancel),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red[600],
                            ),
                            onPressed: () => Navigator.pop(dctx, true),
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmed) {
                  await _repo.removeForDate(e.date);
                  if (mounted) setState(() {});
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipStat(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('$label: $count'),
        ],
      ),
    );
  }

  Color _colorForMood(MoodValue m) => switch (m) {
    MoodValue.terrible => Colors.redAccent,
    MoodValue.bad => Colors.deepOrange,
    MoodValue.ok => AppColors.accentSand,
    MoodValue.good => AppColors.accentBlue,
    MoodValue.great => AppColors.accentGold,
  };

  String _localizedMoodLabel(MoodValue m, AppLocalizations l10n) => switch (m) {
    MoodValue.terrible => l10n.moodTerrible,
    MoodValue.bad => l10n.moodBad,
    MoodValue.ok => l10n.moodOk,
    MoodValue.good => l10n.moodGood,
    MoodValue.great => l10n.moodGreat,
  };
}
