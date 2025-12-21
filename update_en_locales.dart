import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final file = File('lib/l10n/app_en.arb');
  if (!await file.exists()) return;

  final content = await file.readAsString();
  final Map<String, dynamic> json = jsonDecode(content);

  final missingKeys = {
    'socialFeedTitle': 'Feed',
    'visionTasks': 'Tasks',
    'taskCompleted': 'Completed',
    'taskPending': 'Pending',
    'noTasksYet': 'No tasks added yet',
    'deleteTaskConfirm': 'Are you sure you want to delete this task?',
    'taskAdded': 'Task added',
    'manageVisionTasks': 'Manage Tasks',
  };

  bool modified = false;
  missingKeys.forEach((key, value) {
    if (!json.containsKey(key)) {
      json[key] = value;
      modified = true;
      print('Added $key');
    }
  });

  if (modified) {
    final sortedKeys = json.keys.toList()..sort();
    final Map<String, dynamic> sortedJson = {
      for (var k in sortedKeys) k: json[k],
    };
    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(sortedJson));
    print('Updated app_en.arb');
  } else {
    print('No changes for app_en.arb');
  }
}
