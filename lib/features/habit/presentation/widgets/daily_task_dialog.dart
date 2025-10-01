import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class DailyTaskDialog extends StatefulWidget {
  const DailyTaskDialog({super.key});

  @override
  State<DailyTaskDialog> createState() => _DailyTaskDialogState();
}

class _DailyTaskDialogState extends State<DailyTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement task creation logic
      final task = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': DateTime.now(),
        'completed': false,
      };

      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        l10n.createDailyTask,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.taskTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.taskTitleRequired;
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.taskDescription,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _createTask, child: Text(l10n.create)),
      ],
    );
  }
}
