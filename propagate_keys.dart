import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final l10nDir = Directory('lib/l10n');
  final keysToAdd = {
    'socialFeedTitle': 'Feed',
    'visionTasks': 'Tasks',
    'taskCompleted': 'Completed',
    'taskPending': 'Pending',
    'noTasksYet': 'No tasks added yet',
    'deleteTaskConfirm': 'Are you sure you want to delete this task?',
    'taskAdded': 'Task added',
    'manageVisionTasks': 'Manage Tasks',
    // Ensuring these specific subscription keys are present everywhere (defaulting to English if missing)
    'daysLeft': 'days left',
    'usePlayStoreToManage':
        'Use Google Play Store to manage your subscription.',
    'subscriptionDetails': 'Subscription Details',
    'statusLabel': 'Status',
    'active': 'Active',
    'inactive': 'Inactive',
    'endDate': 'End Date',
    'daysRemaining': 'Days Remaining',
    'validity': 'Validity',
    'close': 'Close',
    'goToPlayStore': 'Go to Play Store',
  };

  await for (final file in l10nDir.list()) {
    if (file is File && file.path.endsWith('.arb')) {
      // Skip TR (template) as it is the source
      if (file.path.endsWith('app_tr.arb')) continue;

      try {
        final content = await file.readAsString();
        final Map<String, dynamic> json = jsonDecode(content);
        bool modified = false;

        keysToAdd.forEach((key, value) {
          if (!json.containsKey(key)) {
            json[key] = value;
            modified = true;
            print('${file.path}: Added $key');
          }
        });

        if (modified) {
          final sortedKeys = json.keys.toList()..sort();
          final Map<String, dynamic> sortedJson = {
            for (var k in sortedKeys) k: json[k],
          };
          const encoder = JsonEncoder.withIndent('    ');
          await file.writeAsString(encoder.convert(sortedJson));
        }
      } catch (e) {
        print('Error processing ${file.path}: $e');
      }
    }
  }
  print('Propagation complete.');
}
