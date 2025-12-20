import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import '../../habit/domain/habit_repository.dart';
import '../../habit/domain/habit_model.dart';
import '../../habit/domain/habit_types.dart';
import '../data/vision_model.dart';
import '../../../design_system/theme/theme_variations.dart';
import '../data/vision_repository.dart';
import 'vision_create_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../data/freeform_text_repository.dart';
import '../data/freeform_text_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/freeform_image_repository.dart';
import '../data/freeform_image_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../data/vision_template_repository.dart';
import '../../../ui/premium_gate.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({
    super.key,
    required this.variant,
    this.freeformNotifier,
    this.roundCornersNotifier,
    this.showTextNotifier,
    this.showProgressNotifier,
    this.boardBoundaryKey,
  });

  final ThemeVariant variant;
  final ValueNotifier<bool>? freeformNotifier;
  final ValueNotifier<bool>? roundCornersNotifier;
  final ValueNotifier<bool>? showTextNotifier;
  final ValueNotifier<bool>? showProgressNotifier;
  // Optional: a key for capturing the freeform board as image from outside
  final GlobalKey? boardBoundaryKey;

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  final _repo = VisionRepository.instance;
  final _textRepo = FreeformTextRepository.instance;
  final _imageRepo = FreeformImageRepository.instance;
  bool _freeform = false;
  VoidCallback? _notifierListener;
  bool _roundCorners = true;
  bool _showText = true;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    _repo.initialize();
    _textRepo.initialize();
    _imageRepo.initialize();
    HabitRepository.instance.initialize();
    if (widget.freeformNotifier != null) {
      _freeform = widget.freeformNotifier!.value;
      _notifierListener = () {
        if (mounted) setState(() => _freeform = widget.freeformNotifier!.value);
      };
      widget.freeformNotifier!.addListener(_notifierListener!);
    }
    widget.roundCornersNotifier?.addListener(_onSettingsChanged);
    widget.showTextNotifier?.addListener(_onSettingsChanged);
    widget.showProgressNotifier?.addListener(_onSettingsChanged);
    _roundCorners = widget.roundCornersNotifier?.value ?? true;
    _showText = widget.showTextNotifier?.value ?? true;
    _showProgress = widget.showProgressNotifier?.value ?? false;
  }

  @override
  void didUpdateWidget(covariant VisionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.freeformNotifier != widget.freeformNotifier) {
      if (oldWidget.freeformNotifier != null && _notifierListener != null) {
        oldWidget.freeformNotifier!.removeListener(_notifierListener!);
      }
      if (widget.freeformNotifier != null) {
        _freeform = widget.freeformNotifier!.value;
        _notifierListener = () {
          if (mounted) {
            setState(() => _freeform = widget.freeformNotifier!.value);
          }
        };
        widget.freeformNotifier!.addListener(_notifierListener!);
      }
    }
    if (oldWidget.roundCornersNotifier != widget.roundCornersNotifier ||
        oldWidget.showTextNotifier != widget.showTextNotifier ||
        oldWidget.showProgressNotifier != widget.showProgressNotifier) {
      oldWidget.roundCornersNotifier?.removeListener(_onSettingsChanged);
      oldWidget.showTextNotifier?.removeListener(_onSettingsChanged);
      oldWidget.showProgressNotifier?.removeListener(_onSettingsChanged);
      widget.roundCornersNotifier?.addListener(_onSettingsChanged);
      widget.showTextNotifier?.addListener(_onSettingsChanged);
      widget.showProgressNotifier?.addListener(_onSettingsChanged);
      _roundCorners = widget.roundCornersNotifier?.value ?? _roundCorners;
      _showText = widget.showTextNotifier?.value ?? _showText;
      _showProgress = widget.showProgressNotifier?.value ?? _showProgress;
    }
  }

  @override
  void dispose() {
    if (widget.freeformNotifier != null && _notifierListener != null) {
      widget.freeformNotifier!.removeListener(_notifierListener!);
    }
    widget.roundCornersNotifier?.removeListener(_onSettingsChanged);
    widget.showTextNotifier?.removeListener(_onSettingsChanged);
    widget.showProgressNotifier?.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {
      _roundCorners = widget.roundCornersNotifier?.value ?? _roundCorners;
      _showText = widget.showTextNotifier?.value ?? _showText;
      _showProgress = widget.showProgressNotifier?.value ?? _showProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // If global theme is 'world', override locally to 'earth' so Vision and its popups share earth look.
    final bool isDark = theme.brightness == Brightness.dark;
    final ThemeData localTheme = widget.variant == ThemeVariant.world
        ? (isDark
              ? ThemeVariations.dark(ThemeVariant.earth)
              : ThemeVariations.light(ThemeVariant.earth))
        : theme;
    final accent = localTheme.colorScheme.primary;

    return Theme(
      data: localTheme.copyWith(
        floatingActionButtonTheme: localTheme.floatingActionButtonTheme
            .copyWith(
              backgroundColor: accent,
              foregroundColor: localTheme.colorScheme.onPrimary,
            ),
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateActions,
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context).createVision),
        ),
        body: StreamBuilder<List<Vision>>(
          stream: _repo.stream,
          initialData: _repo.all(),
          builder: (context, snapshot) {
            final visions = snapshot.data ?? const [];
            return _freeform
                ? StreamBuilder<List<FreeformImage>>(
                    stream: _imageRepo.stream,
                    initialData: _imageRepo.all(),
                    builder: (context, imgSnap) {
                      final images = imgSnap.data ?? const [];
                      return StreamBuilder<List<FreeformText>>(
                        stream: _textRepo.stream,
                        initialData: _textRepo.all(),
                        builder: (context, textSnap) {
                          final texts = textSnap.data ?? const [];
                          // Wrap only the board with a RepaintBoundary so captures exclude app bar, FAB, nav bar
                          return RepaintBoundary(
                            key: widget.boardBoundaryKey,
                            child: SizedBox.expand(
                              child: _FreeformBoard(
                                visions: visions,
                                images: images,
                                texts: texts,
                                onMenu: _menuFor,
                                onTap: _openVision,
                                onChanged: (id, x, y, scale) =>
                                    _repo.updateLayout(
                                      id: id,
                                      posX: x,
                                      posY: y,
                                      scale: scale,
                                    ),
                                onImageChanged: (id, x, y, scale) =>
                                    _imageRepo.updateLayout(
                                      id: id,
                                      posX: x,
                                      posY: y,
                                      scale: scale,
                                    ),
                                onTextChanged: (id, x, y, scale) =>
                                    _textRepo.updateLayout(
                                      id: id,
                                      posX: x,
                                      posY: y,
                                      scale: scale,
                                    ),
                                onTextMenu: _showTextBottomSheet,
                                onImageMenu: _showImageBottomSheet,
                                roundCorners: _roundCorners,
                                showText: _showText,
                                showProgress: _showProgress,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : _Board(
                    visions: visions,
                    onTap: _openVision,
                    onMenu: _menuFor,
                    onAddTask: _showQuickAddTask,
                    onToggleTask: (v, taskId) async {
                      await _repo.toggleTask(v.id, taskId);
                    },
                  );
          },
        ),
      ),
    );
  }

  void _openVision(Vision v) {
    _showVisionBottomSheet(v);
  }

  void _menuFor(Vision v) => _showVisionBottomSheet(v);

  /// Quick add task dialog for board view
  Future<void> _showQuickAddTask(Vision v) async {
    final l10n = AppLocalizations.of(context);
    final taskCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addTask),
        content: TextField(
          controller: taskCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.taskTitle,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) async {
            if (value.trim().isNotEmpty) {
              await _repo.addTask(v.id, value.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (taskCtrl.text.trim().isNotEmpty) {
                await _repo.addTask(v.id, taskCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<Vision>(
      MaterialPageRoute(
        builder: (_) => VisionCreateScreen(variant: widget.variant),
      ),
    );
    if (created != null) {
      // Already added in create screen; stream updates will refresh UI.
    }
  }

  void _showCreateActions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: Text(AppLocalizations.of(context).visionCreateTitle),
              onTap: () {
                Navigator.pop(ctx);
                requirePremium(context).then((ok) {
                  if (!ok) return;
                  _openCreate();
                });
              },
            ),
            if (_freeform)
              ListTile(
                leading: const Icon(Icons.text_fields_outlined),
                title: Text(AppLocalizations.of(context).addText),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await requirePremium(context);
                  if (!ok) return;
                  await _openCreateTextSticker();
                },
              ),
            if (_freeform)
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(AppLocalizations.of(context).addImage),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await requirePremium(context);
                  if (!ok) return;
                  await _openCreateImageSticker();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateImageSticker() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final img = FreeformImage(
        id: id,
        path: file.path,
        posX: 0.5,
        posY: 0.5,
        scale: 1.0,
        createdAt: DateTime.now(),
      );
      await FreeformImageRepository.instance.add(img);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _openCreateTextSticker() async {
    String text = '';
    String font = 'Poppins';
    Color color = Colors.white;
    bool plateEnabled = false;
    Color plateColor = Colors.black;
    bool outlineEnabled = false;
    Color outlineColor = Colors.white;
    final theme = Theme.of(context);
    final fonts = const [
      'Poppins',
      'Lato',
      'Merriweather',
      'Pacifico',
      'Roboto',
    ];
    final colors = <Color>[
      Colors.white,
      Colors.black,
      theme.colorScheme.primary,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.purple,
      Colors.pink,
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final kb = MediaQuery.of(ctx).viewInsets.bottom;
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: kb),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: StatefulBuilder(
                  builder: (ctx, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).textLabel,
                        ),
                        onChanged: (v) => text = v,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).colorLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in colors)
                            GestureDetector(
                              onTap: () => setState(() => color = c),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color == c
                                        ? theme.colorScheme.onSurface
                                        : Colors.black12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context).backgroundPlate,
                        ),
                        value: plateEnabled == true,
                        onChanged: (v) => setState(() => plateEnabled = v),
                      ),
                      if (plateEnabled) ...[
                        Text(
                          AppLocalizations.of(context).plateColor,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in colors)
                              GestureDetector(
                                onTap: () => setState(() => plateColor = c),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: plateColor == c
                                          ? theme.colorScheme.onSurface
                                          : Colors.black12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context).outline),
                        value: outlineEnabled == true,
                        onChanged: (v) => setState(() => outlineEnabled = v),
                      ),
                      if (outlineEnabled) ...[
                        Text(
                          AppLocalizations.of(context).outlineColor,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in colors)
                              GestureDetector(
                                onTap: () => setState(() => outlineColor = c),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: outlineColor == c
                                          ? theme.colorScheme.onSurface
                                          : Colors.black12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        AppLocalizations.of(context).font,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: font,
                        items: [
                          for (final f in fonts)
                            DropdownMenuItem(
                              value: f,
                              child: Text(f, style: GoogleFonts.getFont(f)),
                            ),
                        ],
                        onChanged: (v) => setState(() => font = v ?? font),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(AppLocalizations.of(context).cancel),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              if (text.trim().isEmpty) return;
                              final id = DateTime.now().microsecondsSinceEpoch
                                  .toString();
                              final sticker = FreeformText(
                                id: id,
                                text: text.trim(),
                                colorValue: color.toARGB32(),
                                fontFamily: font,
                                posX: 0.5,
                                posY: 0.5,
                                scale: 1.0,
                                createdAt: DateTime.now(),
                                plateEnabled: plateEnabled,
                                plateColorValue: plateColor.toARGB32(),
                                outlineEnabled: outlineEnabled,
                                outlineColorValue: outlineColor.toARGB32(),
                              );
                              await FreeformTextRepository.instance.add(
                                sticker,
                              );
                              if (mounted) Navigator.pop(ctx);
                            },
                            child: Text(AppLocalizations.of(context).add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVisionBottomSheet(Vision v) {
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
            if (_freeform) ...[
              ListTile(
                leading: const Icon(Icons.arrow_upward_outlined),
                title: Text(AppLocalizations.of(context).bringForward),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _repo.bringForward(v.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward_outlined),
                title: Text(AppLocalizations.of(context).sendBackward),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _repo.sendBackward(v.id);
                },
              ),
              const Divider(height: 1),
            ],
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(AppLocalizations.of(context).shareVision),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final tpl = _repo.exportAsTemplate(v);
                  final link = VisionTemplateRepository.instance.toShareLink(
                    tpl,
                  );
                  await SharePlus.instance.share(
                    ShareParams(
                      text: link,
                      subject: AppLocalizations.of(context).vision,
                    ),
                  );
                } catch (_) {}
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(AppLocalizations.of(context).edit),
              onTap: () {
                Navigator.pop(ctx);
                _editVision(v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: Text(AppLocalizations.of(context).linkHabits),
              onTap: () {
                Navigator.pop(ctx);
                _pickHabits(v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist_outlined),
              title: Text(AppLocalizations.of(context).manageVisionTasks),
              onTap: () {
                Navigator.pop(ctx);
                _manageTasks(v);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                bool deleteHabits = false;
                final ok =
                    await showDialog<bool>(
                      context: context,
                      builder: (dctx) => StatefulBuilder(
                        builder: (dctx, setState) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(context).deleteVisionTitle,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).deleteVisionMessage,
                              ),
                              const SizedBox(height: 8),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: deleteHabits,
                                onChanged: (v) =>
                                    setState(() => deleteHabits = v ?? false),
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).alsoDeleteLinkedHabits,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dctx, false),
                              child: Text(AppLocalizations.of(context).cancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red[600],
                              ),
                              onPressed: () => Navigator.pop(dctx, true),
                              child: Text(AppLocalizations.of(context).delete),
                            ),
                          ],
                        ),
                      ),
                    ) ??
                    false;
                if (ok) {
                  await _repo.removeWithCascade(
                    v.id,
                    deleteLinkedHabits: deleteHabits,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Opens a dialog to manage one-time tasks for a vision
  Future<void> _manageTasks(Vision v) async {
    final l10n = AppLocalizations.of(context);
    final taskCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Get fresh vision from repository
          final vision = _repo.visions.firstWhere(
            (vis) => vis.id == v.id,
            orElse: () => v,
          );

          return AlertDialog(
            title: Text(l10n.visionTasks),
            content: SizedBox(
              width: 400,
              height: 400,
              child: Column(
                children: [
                  // Add new task input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskCtrl,
                          decoration: InputDecoration(
                            hintText: l10n.addTask,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (value) async {
                            if (value.trim().isNotEmpty) {
                              await _repo.addTask(v.id, value.trim());
                              taskCtrl.clear();
                              setDialogState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () async {
                          if (taskCtrl.text.trim().isNotEmpty) {
                            await _repo.addTask(v.id, taskCtrl.text.trim());
                            taskCtrl.clear();
                            setDialogState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Task list
                  Expanded(
                    child: vision.tasks.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noTasksYet,
                              style: TextStyle(color: Theme.of(ctx).hintColor),
                            ),
                          )
                        : ListView.builder(
                            itemCount: vision.tasks.length,
                            itemBuilder: (_, i) {
                              final task = vision.tasks[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) async {
                                    await _repo.toggleTask(v.id, task.id);
                                    setDialogState(() {});
                                  },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted
                                        ? Theme.of(ctx).hintColor
                                        : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () async {
                                    await _repo.removeTask(v.id, task.id);
                                    setDialogState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.close),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTextBottomSheet(FreeformText t) {
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
              leading: const Icon(Icons.arrow_upward_outlined),
              title: Text(AppLocalizations.of(context).bringForward),
              onTap: () async {
                Navigator.pop(ctx);
                await _textRepo.bringForward(t.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward_outlined),
              title: Text(AppLocalizations.of(context).sendBackward),
              onTap: () async {
                Navigator.pop(ctx);
                await _textRepo.sendBackward(t.id);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(AppLocalizations.of(context).edit),
              onTap: () {
                Navigator.pop(ctx);
                _editTextSticker(t);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _textRepo.remove(t.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showImageBottomSheet(FreeformImage img) {
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
              leading: const Icon(Icons.arrow_upward_outlined),
              title: Text(AppLocalizations.of(context).bringForward),
              onTap: () async {
                Navigator.pop(ctx);
                await _imageRepo.bringForward(img.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward_outlined),
              title: Text(AppLocalizations.of(context).sendBackward),
              onTap: () async {
                Navigator.pop(ctx);
                await _imageRepo.sendBackward(img.id);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _imageRepo.remove(img.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editTextSticker(FreeformText t) async {
    String text = t.text;
    int colorValue = t.colorValue;
    String font = t.fontFamily;
    bool plateEnabled = t.plateEnabled;
    int plateColorValue = t.plateColorValue;
    bool outlineEnabled = t.outlineEnabled;
    int outlineColorValue = t.outlineColorValue;
    final theme = Theme.of(context);
    final colors = <Color>[
      Colors.white,
      Colors.black,
      theme.colorScheme.primary,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.purple,
      Colors.pink,
    ];
    final fonts = const [
      'Poppins',
      'Lato',
      'Merriweather',
      'Pacifico',
      'Roboto',
    ];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final kb = MediaQuery.of(ctx).viewInsets.bottom;
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: kb),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: StatefulBuilder(
                  builder: (ctx, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: TextEditingController(text: text),
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).textLabel,
                        ),
                        onChanged: (v) => text = v,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).colorLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in colors)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => colorValue = c.toARGB32()),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(colorValue) == c
                                        ? theme.colorScheme.onSurface
                                        : Colors.black12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context).backgroundPlate,
                        ),
                        value: plateEnabled == true,
                        onChanged: (v) => setState(() => plateEnabled = v),
                      ),
                      if (plateEnabled) ...[
                        Text(
                          AppLocalizations.of(context).plateColor,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in colors)
                              GestureDetector(
                                onTap: () => setState(
                                  () => plateColorValue = c.toARGB32(),
                                ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(plateColorValue) == c
                                          ? theme.colorScheme.onSurface
                                          : Colors.black12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context).outline),
                        value: outlineEnabled == true,
                        onChanged: (v) => setState(() => outlineEnabled = v),
                      ),
                      if (outlineEnabled) ...[
                        Text(
                          AppLocalizations.of(context).outlineColor,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in colors)
                              GestureDetector(
                                onTap: () => setState(
                                  () => outlineColorValue = c.toARGB32(),
                                ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(outlineColorValue) == c
                                          ? theme.colorScheme.onSurface
                                          : Colors.black12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        AppLocalizations.of(context).font,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: fonts.contains(font) ? font : fonts.first,
                        items: [
                          for (final f in fonts)
                            DropdownMenuItem(
                              value: f,
                              child: Text(f, style: GoogleFonts.getFont(f)),
                            ),
                        ],
                        onChanged: (v) => setState(() => font = v ?? font),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(AppLocalizations.of(context).cancel),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              if (text.trim().isEmpty) return;
                              await _textRepo.update(
                                t.copyWith(
                                  text: text.trim(),
                                  colorValue: colorValue,
                                  fontFamily: font,
                                  plateEnabled: plateEnabled,
                                  plateColorValue: plateColorValue,
                                  outlineEnabled: outlineEnabled,
                                  outlineColorValue: outlineColorValue,
                                ),
                              );
                              if (mounted) Navigator.pop(ctx);
                            },
                            child: Text(AppLocalizations.of(context).save),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editVision(Vision v) async {
    await Navigator.of(context).push<Vision>(
      MaterialPageRoute(
        builder: (_) =>
            VisionCreateScreen(variant: widget.variant, initialVision: v),
      ),
    );
    // Updates and pop are handled inside VisionCreateScreen.
  }

  Future<void> _pickHabits(Vision v) async {
    final repo = HabitRepository.instance;
    final all = repo.habits;
    final selected = v.linkedHabitIds.toSet();
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(AppLocalizations.of(context).linkHabits),
          content: SizedBox(
            width: 400,
            height: 400,
            child: ListView.builder(
              itemCount: all.length,
              itemBuilder: (_, i) {
                final h = all[i];
                final checked = selected.contains(h.id);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (val) {
                    setS(() {
                      if (val == true) {
                        selected.add(h.id);
                      } else {
                        selected.remove(h.id);
                      }
                    });
                  },
                  title: Text(h.title),
                  subtitle: Text(_habitSubtitle(h)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: Text(AppLocalizations.of(context).save),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      final updated = v.copyWith(linkedHabitIds: result.toList());
      await _repo.update(updated);
    }
  }

  String _habitSubtitle(Habit h) {
    final l10n = AppLocalizations.of(context);
    switch (h.habitType) {
      case HabitType.simple:
        return l10n.dailyCheck;
      case HabitType.checkbox:
        return l10n.dailyCheck;
      case HabitType.subtasks:
        return '${h.subtasks.length} alt görev';
      case HabitType.numerical:
        return l10n.targetShort('${h.targetCount} ${h.unit ?? ''}'.trim());
      case HabitType.timer:
        return l10n.targetShort('${h.targetCount} ${l10n.minutes}');
    }
  }
}

class _FreeformBoard extends StatefulWidget {
  final List<Vision> visions;
  final List<FreeformImage> images;
  final List<FreeformText> texts;
  final void Function(Vision) onTap;
  final void Function(Vision) onMenu;
  final void Function(String id, double x, double y, double scale) onChanged;
  final void Function(String id, double x, double y, double scale)
  onImageChanged;
  final void Function(String id, double x, double y, double scale)
  onTextChanged;
  final void Function(FreeformText) onTextMenu;
  final void Function(FreeformImage) onImageMenu;
  final bool roundCorners;
  final bool showText;
  final bool showProgress;
  const _FreeformBoard({
    required this.visions,
    required this.images,
    required this.texts,
    required this.onTap,
    required this.onMenu,
    required this.onChanged,
    required this.onImageChanged,
    required this.onTextChanged,
    required this.onTextMenu,
    required this.onImageMenu,
    required this.roundCorners,
    required this.showText,
    required this.showProgress,
  });

  @override
  State<_FreeformBoard> createState() => _FreeformBoardState();
}

class _FreeformBoardState extends State<_FreeformBoard> {
  Size? _size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        // Render in reverse so index 0 is painted last (on top).
        return Container(
          color: theme.scaffoldBackgroundColor,
          child: Stack(
            children: [
              for (final v in widget.visions.reversed)
                _DraggableVision(
                  key: ValueKey(
                    '${v.id}_${v.createdAt.millisecondsSinceEpoch}',
                  ),
                  vision: v,
                  size: _size!,
                  onTap: () => widget.onTap(v),
                  onLongPress: () => widget.onMenu(v),
                  onChanged: (x, y, s) => widget.onChanged(v.id, x, y, s),
                  roundCorners: widget.roundCorners,
                  showText: widget.showText,
                  showProgress: widget.showProgress,
                ),
              // Render freeform images above visions, below texts
              for (final im in widget.images.reversed)
                _DraggableImageSticker(
                  image: im,
                  size: _size!,
                  onLongPress: () => widget.onImageMenu(im),
                  onChanged: (x, y, s) => widget.onImageChanged(im.id, x, y, s),
                ),
              // Render text stickers above visions
              for (final t in widget.texts.reversed)
                _DraggableTextSticker(
                  text: t,
                  size: _size!,
                  onLongPress: () => widget.onTextMenu(t),
                  onChanged: (x, y, s) => widget.onTextChanged(t.id, x, y, s),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableVision extends StatefulWidget {
  final Vision vision;
  final Size size;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final void Function(double x, double y, double scale) onChanged;
  final bool roundCorners;
  final bool showText;
  final bool showProgress;
  const _DraggableVision({
    super.key,
    required this.vision,
    required this.size,
    required this.onLongPress,
    required this.onTap,
    required this.onChanged,
    required this.roundCorners,
    required this.showText,
    required this.showProgress,
  });

  @override
  State<_DraggableVision> createState() => _DraggableVisionState();
}

class _DraggableVisionState extends State<_DraggableVision> {
  late double _x;
  late double _y;
  late double _scale;
  Offset? _dragStart;
  double? _startScale;
  double? _startX;
  double? _startY;
  double _aspect = 1.0; // width/height for cover images

  bool get _hasImage =>
      widget.vision.coverImage != null && widget.vision.coverImage!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _x = widget.vision.posX;
    _y = widget.vision.posY;
    _scale = widget.vision.scale;
    if (_hasImage) {
      _loadAspect(widget.vision.coverImage!);
    }
  }

  Future<void> _loadAspect(String path) async {
    try {
      Uint8List bytes;
      final isFile =
          path.startsWith('/') || path.contains('\\') || path.contains(':\\');
      if (isFile) {
        bytes = await io.File(path).readAsBytes();
      } else {
        final bd = await rootBundle.load(path);
        bytes = bd.buffer.asUint8List();
      }
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final img = frame.image;
      if (img.height != 0) {
        if (mounted) setState(() => _aspect = img.width / img.height);
      }
      img.dispose();
    } catch (_) {
      // ignore decode errors; fallback to square
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size.width;
    final h = widget.size.height;
    const baseSize = 160.0;
    final width = (baseSize * _scale).clamp(80.0, 480.0);
    final height = _hasImage ? (width / (_aspect == 0 ? 1.0 : _aspect)) : width;
    // Allow positioning beyond edges by not clamping to canvas size
    final left = _x * w;
    final top = _y * h;
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        onScaleStart: (d) {
          _dragStart = d.focalPoint;
          _startScale = _scale;
          _startX = _x;
          _startY = _y;
        },
        onScaleUpdate: (d) {
          setState(() {
            // Pan
            final delta = d.focalPoint - (_dragStart ?? d.focalPoint);
            final baseX = _startX ?? _x;
            final baseY = _startY ?? _y;
            final nx = (baseX * w + delta.dx) / w;
            final ny = (baseY * h + delta.dy) / h;
            _x = nx;
            _y = ny;
            // Scale
            final s = (_startScale ?? _scale) * d.scale;
            _scale = s.clamp(0.5, 3.0);
          });
        },
        onScaleEnd: (d) {
          widget.onChanged(_x, _y, _scale);
          _dragStart = null;
          _startScale = null;
          _startX = null;
          _startY = null;
        },
        child: _FreeformCard(
          vision: widget.vision,
          width: width,
          height: height,
          roundCorners: widget.roundCorners,
          showText: widget.showText,
          showProgress: widget.showProgress,
        ),
      ),
    );
  }
}

class _FreeformCard extends StatelessWidget {
  final Vision vision;
  final double width;
  final double height;
  final bool roundCorners;
  final bool showText;
  final bool showProgress;
  const _FreeformCard({
    required this.vision,
    required this.width,
    required this.height,
    required this.roundCorners,
    required this.showText,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(vision.colorValue);
    // Scale font sizes based on card width to prevent overflow
    final emojiFontSize = (width * 0.25).clamp(16.0, 40.0);
    final titleFontSize = (width * 0.1).clamp(10.0, 16.0);
    final spacing = (width * 0.05).clamp(4.0, 8.0);

    // Hide any date-related info on freeform cards
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(roundCorners ? 16 : 0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (vision.coverImage != null && vision.coverImage!.isNotEmpty)
              _CoverImage(path: vision.coverImage!)
            else
              DecoratedBox(decoration: BoxDecoration(color: color)),
            // Apply subtle gradient only when showing text so text is readable
            if (showText &&
                vision.coverImage != null &&
                vision.coverImage!.isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            // Date badge and expired overlay removed per requirement
            if (showText)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vision.coverImage == null ||
                          vision.coverImage!.isEmpty) ...[
                        Text(
                          vision.emoji ?? '🎯',
                          style: TextStyle(fontSize: emojiFontSize),
                        ),
                        SizedBox(height: spacing),
                      ],
                      Text(
                        vision.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!showText &&
                (vision.coverImage == null || vision.coverImage!.isEmpty))
              Center(
                child: Text(
                  vision.emoji ?? '🎯',
                  style: TextStyle(fontSize: emojiFontSize),
                ),
              ),
            if (showProgress)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0x80000000)],
                    ),
                  ),
                  child: _ProgressBar(vision: vision, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DraggableTextSticker extends StatefulWidget {
  final FreeformText text;
  final Size size;
  final VoidCallback onLongPress;
  final void Function(double x, double y, double scale) onChanged;
  const _DraggableTextSticker({
    required this.text,
    required this.size,
    required this.onLongPress,
    required this.onChanged,
  });

  @override
  State<_DraggableTextSticker> createState() => _DraggableTextStickerState();
}

class _DraggableImageSticker extends StatefulWidget {
  final FreeformImage image;
  final Size size;
  final VoidCallback onLongPress;
  final void Function(double x, double y, double scale) onChanged;
  const _DraggableImageSticker({
    required this.image,
    required this.size,
    required this.onLongPress,
    required this.onChanged,
  });

  @override
  State<_DraggableImageSticker> createState() => _DraggableImageStickerState();
}

class _DraggableImageStickerState extends State<_DraggableImageSticker> {
  late double _x = widget.image.posX;
  late double _y = widget.image.posY;
  late double _scale = widget.image.scale;
  Offset? _dragStart;
  double? _baseX;
  double? _baseY;
  double? _startScale;
  double _aspect = 1.0; // width/height

  @override
  void initState() {
    super.initState();
    _loadAspect(widget.image.path);
  }

  @override
  void didUpdateWidget(covariant _DraggableImageSticker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.path != widget.image.path) {
      _loadAspect(widget.image.path);
    }
  }

  Future<void> _loadAspect(String path) async {
    try {
      Uint8List bytes;
      final isFile =
          path.startsWith('/') || path.contains('\\') || path.contains(':\\');
      if (isFile) {
        bytes = await io.File(path).readAsBytes();
      } else {
        final bd = await rootBundle.load(path);
        bytes = bd.buffer.asUint8List();
      }
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final img = frame.image;
      if (img.height != 0) {
        if (mounted) setState(() => _aspect = img.width / img.height);
      }
      img.dispose();
    } catch (_) {
      // ignore decode errors
    }
  }

  @override
  Widget build(BuildContext context) {
    // Base width scales; height follows aspect to preserve format
    const base = 160.0;
    final width = (base * _scale).clamp(64.0, 640.0);
    final safeAspect = _aspect == 0 ? 1.0 : _aspect;
    final height = width / safeAspect;
    // Permit positions beyond edges; no clamping to available area
    final aw = (widget.size.width - width);
    final ah = (widget.size.height - height);
    final left = _x * (aw == 0 ? widget.size.width : aw);
    final top = _y * (ah == 0 ? widget.size.height : ah);
    final isFile =
        widget.image.path.startsWith('/') ||
        widget.image.path.contains('\\') ||
        widget.image.path.contains(':\\');
    final child = DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black12),
      child: isFile
          ? Image.file(io.File(widget.image.path), fit: BoxFit.contain)
          : Image.asset(widget.image.path, fit: BoxFit.contain),
    );

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: widget.onLongPress,
        onScaleStart: (d) {
          _dragStart = d.focalPoint;
          _baseX = _x;
          _baseY = _y;
          _startScale = _scale;
        },
        onScaleUpdate: (d) {
          final start = _dragStart ?? d.focalPoint;
          final delta = d.focalPoint - start;
          final nx =
              (_baseX ?? _x) +
              (widget.size.width > 0 ? delta.dx / widget.size.width : 0.0);
          final ny =
              (_baseY ?? _y) +
              (widget.size.height > 0 ? delta.dy / widget.size.height : 0.0);
          setState(() {
            _x = nx;
            _y = ny;
            _scale = ((_startScale ?? _scale) * d.scale).clamp(0.25, 5.0);
          });
        },
        onScaleEnd: (_) {
          widget.onChanged(_x, _y, _scale);
          _dragStart = null;
          _baseX = null;
          _baseY = null;
          _startScale = null;
        },
        child: SizedBox(width: width, height: height, child: child),
      ),
    );
  }
}

class _DraggableTextStickerState extends State<_DraggableTextSticker> {
  late double _x = widget.text.posX;
  late double _y = widget.text.posY;
  late double _scale = widget.text.scale;
  double? _startScale;
  Offset? _dragStart; // screen-space focal point at gesture start
  double? _baseX; // normalized position at gesture start
  double? _baseY;

  @override
  Widget build(BuildContext context) {
    final font = widget.text.fontFamily;
    final color = Color(widget.text.colorValue);
    final baseSize = 20.0; // base font size multiplier
    final textWidget = Text(
      widget.text.text,
      style: GoogleFonts.getFont(
        font,
        color: color,
        fontSize: baseSize * _scale,
        // Simple outline using shadows when enabled
        shadows: widget.text.outlineEnabled
            ? [
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 2,
                  color: Color(widget.text.outlineColorValue),
                ),
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 2,
                  color: Color(widget.text.outlineColorValue),
                ),
                Shadow(
                  offset: const Offset(-0.5, -0.5),
                  blurRadius: 2,
                  color: Color(widget.text.outlineColorValue),
                ),
              ]
            : null,
      ),
    );
    // Estimate size using TextPainter
    final tp = TextPainter(
      text: TextSpan(
        text: widget.text.text,
        style: GoogleFonts.getFont(font, fontSize: baseSize * _scale),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    // Visual chip size
    final chipWidth = tp.width + 16;
    final chipHeight = tp.height + 12;
    // Expand interactive hit area to make pinch easier
    final interactiveWidth = chipWidth + 24; // extra padding around chip
    final interactiveHeight = chipHeight + 24;
    final minInteractiveW = 80.0;
    final minInteractiveH = 60.0;
    final iw = interactiveWidth < minInteractiveW
        ? minInteractiveW
        : interactiveWidth;
    final ih = interactiveHeight < minInteractiveH
        ? minInteractiveH
        : interactiveHeight;
    // Available area for top-left of the interactive box
    // Remove clamping so the interactive area can go beyond edges
    final aw = (widget.size.width - iw);
    final ah = (widget.size.height - ih);
    final left = _x * (aw == 0 ? widget.size.width : aw);
    final top = _y * (ah == 0 ? widget.size.height : ah);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior
            .opaque, // capture touches in transparent padding area
        onScaleStart: (d) {
          _dragStart = d.focalPoint;
          _baseX = _x;
          _baseY = _y;
          _startScale = _scale;
        },
        onScaleUpdate: (d) {
          // Accumulate pan from the gesture start, normalize by available area for more natural speed
          final start = _dragStart ?? d.focalPoint;
          final delta = d.focalPoint - start;
          final nx = (_baseX ?? _x) + (aw != 0 ? delta.dx / (aw.abs()) : 0.0);
          final ny = (_baseY ?? _y) + (ah != 0 ? delta.dy / (ah.abs()) : 0.0);
          setState(() {
            _x = nx;
            _y = ny;
            // Make scaling a bit more permissive for text stickers
            _scale = (_startScale! * d.scale).clamp(0.25, 5.0);
          });
        },
        onScaleEnd: (_) {
          widget.onChanged(_x, _y, _scale);
          _dragStart = null;
          _baseX = null;
          _baseY = null;
          _startScale = null;
        },
        onLongPress: widget.onLongPress,
        child: SizedBox(
          width: iw,
          height: ih,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: widget.text.plateEnabled
                    ? Color(widget.text.plateColorValue)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                // Show a rectangular border only when a plate is present
                border: widget.text.plateEnabled && widget.text.outlineEnabled
                    ? Border.all(
                        color: Color(
                          widget.text.outlineColorValue,
                        ).withValues(alpha: 0.8),
                        width: 1,
                      )
                    : null,
              ),
              child: textWidget,
            ),
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  final List<Vision> visions;
  final void Function(Vision) onTap;
  final void Function(Vision) onMenu;
  final void Function(Vision) onAddTask;
  final void Function(Vision, String taskId) onToggleTask;
  const _Board({
    required this.visions,
    required this.onTap,
    required this.onMenu,
    required this.onAddTask,
    required this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: visions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final v = visions[i];
          final color = Color(v.colorValue);
          final tasks = v.tasks;

          return GestureDetector(
            onTap: () => onTap(v),
            onLongPress: () => onMenu(v),
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 4,
              ), // Slight spacing for shadow visibility
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Softer corners
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    Color.lerp(color, Colors.black, 0.2)!, // Richer gradient
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              v.emoji ?? '🎯',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _CompactProgressBar(vision: v),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tasks Section (Card-in-Card look)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (tasks.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Column(
                                children: tasks
                                    .map(
                                      (task) => Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => onToggleTask(v, task.id),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: task.isCompleted
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.9,
                                                              )
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  width: 20,
                                                  height: 20,
                                                  child: task.isCompleted
                                                      ? Icon(
                                                          Icons.check,
                                                          size: 14,
                                                          color: color,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    task.title,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha:
                                                                task.isCompleted
                                                                ? 0.5
                                                                : 0.95,
                                                          ),
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration:
                                                          task.isCompleted
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                      decorationColor: Colors
                                                          .white
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                          // Add Task Button (always visible footer of the list)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onAddTask(v),
                              borderRadius: BorderRadius.vertical(
                                top: tasks.isEmpty
                                    ? const Radius.circular(16)
                                    : Radius.zero,
                                bottom: const Radius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.addTask,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactProgressBar extends StatelessWidget {
  final Vision vision;
  const _CompactProgressBar({required this.vision});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: VisionRepository.instance.calculateVisionProgress(vision.id),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        final percent = (progress * 100).toInt();
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percent%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final Vision vision;
  final Color? color;
  const _ProgressBar({required this.vision, this.color});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: VisionRepository.instance.calculateVisionProgress(vision.id),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: (color ?? Theme.of(context).colorScheme.primary)
                  .withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text('${(progress * 100).toStringAsFixed(0)}%'),
          ],
        );
      },
    );
  }
}

// EmptyState removed: freeform mode renders even with no visions; board shows grid.

class _CoverImage extends StatelessWidget {
  final String path;
  const _CoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    // Heuristic: if path looks like a file path, use Image.file, else Image.asset
    final isFile =
        path.startsWith('/') || path.contains('\\') || path.contains(':\\');
    final Widget img = isFile
        ? Image.file(io.File(path), fit: BoxFit.cover)
        : Image.asset(path, fit: BoxFit.cover);
    return img;
  }
}
