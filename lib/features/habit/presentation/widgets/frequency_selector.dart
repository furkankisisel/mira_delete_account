import 'package:flutter/material.dart';
import 'package:mira/l10n/app_localizations.dart';

/// Sıklık seçici widget.
/// Günlük, Haftalık, Aylık, Yıllık ve Periyodik seçenekleri sunar.
class FrequencySelector extends StatelessWidget {
  const FrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    required this.weeklyDays,
    required this.onWeeklyDaysChanged,
    required this.monthDays,
    required this.onMonthDaysChanged,
    required this.yearDays,
    required this.onYearDayAdded,
    required this.onYearDayRemoved,
    required this.periodicDays,
    required this.onPeriodicDaysChanged,
  });

  final String selectedFrequency;
  final ValueChanged<String> onFrequencyChanged;

  // Weekly
  final Set<int> weeklyDays;
  final ValueChanged<Set<int>> onWeeklyDaysChanged;

  // Monthly
  final Set<int> monthDays;
  final ValueChanged<Set<int>> onMonthDaysChanged;

  // Yearly
  final List<String> yearDays;
  final ValueChanged<String> onYearDayAdded;
  final ValueChanged<String> onYearDayRemoved;

  // Periodic
  final int periodicDays;
  final ValueChanged<int> onPeriodicDaysChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sıklık seçenekleri
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FrequencyChip(
              label: 'Günlük',
              icon: Icons.today,
              isSelected: selectedFrequency == 'daily',
              onTap: () => onFrequencyChanged('daily'),
            ),
            _FrequencyChip(
              label: 'Haftalık',
              icon: Icons.date_range,
              isSelected: selectedFrequency == 'weekly',
              onTap: () => onFrequencyChanged('weekly'),
            ),
            _FrequencyChip(
              label: 'Aylık',
              icon: Icons.calendar_view_month,
              isSelected: selectedFrequency == 'monthly',
              onTap: () => onFrequencyChanged('monthly'),
            ),
            _FrequencyChip(
              label: 'Yıllık',
              icon: Icons.event,
              isSelected: selectedFrequency == 'yearly',
              onTap: () => onFrequencyChanged('yearly'),
            ),
            _FrequencyChip(
              label: 'Periyodik',
              icon: Icons.repeat,
              isSelected: selectedFrequency == 'periodic',
              onTap: () => onFrequencyChanged('periodic'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sıklık detay seçicileri
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildFrequencyDetails(context),
        ),
      ],
    );
  }

  Widget _buildFrequencyDetails(BuildContext context) {
    switch (selectedFrequency) {
      case 'daily':
        return _buildDailyInfo(context);
      case 'weekly':
        return _WeeklyDayPicker(
          selected: weeklyDays,
          onChanged: onWeeklyDaysChanged,
        );
      case 'monthly':
        return _MonthDayPicker(
          selected: monthDays,
          onChanged: onMonthDaysChanged,
        );
      case 'yearly':
        return _YearDayPicker(
          selected: yearDays,
          onAdd: onYearDayAdded,
          onRemove: onYearDayRemoved,
        );
      case 'periodic':
        return _PeriodicPicker(
          days: periodicDays,
          onChanged: onPeriodicDaysChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDailyInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('daily'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu alışkanlık her gün tekrarlanacak',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sıklık seçim chip'i
class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Haftalık gün seçici
class _WeeklyDayPicker extends StatelessWidget {
  const _WeeklyDayPicker({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  static const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('weekly'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hangi günler?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final day = index + 1; // 1-7 (Pazartesi-Pazar)
              final isSelected = selected.contains(day);
              return GestureDetector(
                onTap: () {
                  final newSet = {...selected};
                  if (isSelected) {
                    newSet.remove(day);
                  } else {
                    newSet.add(day);
                  }
                  onChanged(newSet);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _dayLabels[index],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Aylık gün seçici
class _MonthDayPicker extends StatelessWidget {
  const _MonthDayPicker({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('monthly'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayın hangi günleri?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(31, (index) {
              final day = index + 1;
              final isSelected = selected.contains(day);
              return GestureDetector(
                onTap: () {
                  final newSet = {...selected};
                  if (isSelected) {
                    newSet.remove(day);
                  } else {
                    newSet.add(day);
                  }
                  onChanged(newSet);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Yıllık tarih seçici
class _YearDayPicker extends StatelessWidget {
  const _YearDayPicker({
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> selected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('yearly'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yılın hangi günleri?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (selected.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected.map((md) {
                return Chip(
                  label: Text(_formatMonthDay(md)),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onRemove(md),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).addDate),
          ),
        ],
      ),
    );
  }

  String _formatMonthDay(String md) {
    final parts = md.split('-');
    if (parts.length != 2) return md;
    final months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    final month = int.tryParse(parts[0]) ?? 1;
    final day = parts[1];
    return '$day ${months[month - 1]}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, 1, 1),
      lastDate: DateTime(now.year, 12, 31),
    );
    if (date != null) {
      final md =
          '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (!selected.contains(md)) {
        onAdd(md);
      }
    }
  }
}

/// Periyodik gün seçici
class _PeriodicPicker extends StatelessWidget {
  const _PeriodicPicker({required this.days, required this.onChanged});

  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('periodic'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kaç günde bir?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: days > 1 ? () => onChanged(days - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$days gün',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                onPressed: days < 365 ? () => onChanged(days + 1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Her $days günde bir tekrarlanacak',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
