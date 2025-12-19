import 'dart:io';
import 'dart:convert';

void main() async {
  final l10nDir = Directory('lib/l10n');
  if (!await l10nDir.exists()) {
    print('Error: lib/l10n directory not found.');
    return;
  }

  final files = l10nDir.listSync().where((item) => item.path.endsWith('.arb'));
  final templateFile = File('lib/l10n/app_en.arb');

  // A hardcoded list of keys and their placeholders that should not have a 'type'.
  final Map<String, List<String>> keysToFix = {
    '@stepOf': ['current', 'total'],
    '@approxVisionDurationDays': ['days'],
  };

  for (var fileEntity in files) {
    if (fileEntity.path == templateFile.path) {
      continue; // Skip the template file.
    }

    if (fileEntity is File) {
      final file = fileEntity;
      print('Processing ${file.path}...');
      try {
        String content = await file.readAsString();
        Map<String, dynamic> arbData = json.decode(content);
        bool modified = false;

        keysToFix.forEach((key, placeholderNames) {
          if (arbData.containsKey(key)) {
            final value = arbData[key];
            if (value is Map && value.containsKey('placeholders')) {
              final placeholders = value['placeholders'] as Map;

              for (var placeholderKey in placeholderNames) {
                if (placeholders.containsKey(placeholderKey)) {
                  final placeholderValue = placeholders[placeholderKey];
                  if (placeholderValue is Map && placeholderValue.containsKey('type')) {
                    placeholderValue.remove('type');
                    modified = true;
                    print('  - Removed "type" from "$placeholderKey" in "$key"');
                  }
                }
              }
            }
          }
        });

        if (modified) {
          final encoder = JsonEncoder.withIndent('  ');
          final newContent = encoder.convert(arbData);
          await file.writeAsString('$newContent\n');
          print('  Updated file.');
        } else {
          print('  No modifications needed.');
        }
      } catch (e) {
        print('Error processing ${file.path}: $e');
      }
    }
  }
  print('Finished processing all .arb files.');
}
