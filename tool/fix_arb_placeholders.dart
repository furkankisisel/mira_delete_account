import 'dart:io';
import 'dart:convert';

void main() async {
  final l10nDir = Directory('lib/l10n');
  if (!await l10nDir.exists()) {
    print('Error: lib/l10n directory not found.');
    return;
  }

  final files = l10nDir.listSync().where((item) => item.path.endsWith('.arb'));

  for (var fileEntity in files) {
    if (fileEntity is File) {
      final file = fileEntity;
      print('Processing ${file.path}...');
      try {
        String content = await file.readAsString();
        Map<String, dynamic> arbData = json.decode(content);

        // Log all top-level keys for debugging
        print('  Keys: ${arbData.keys.toList()}');

        // Find the key that contains "stepOf"
        String? stepOfKey;
        for (var key in arbData.keys) {
          if (key.contains('stepOf') && key.startsWith('@')) {
            stepOfKey = key;
            break;
          }
        }

        if (stepOfKey != null) {
          final stepOfData = arbData[stepOfKey];
          if (stepOfData is Map && stepOfData.containsKey('placeholders')) {
            final placeholders = stepOfData['placeholders'];
            if (placeholders is Map) {
              bool modified = false;
              if (placeholders.containsKey('current') && placeholders['current'] is Map) {
                if (placeholders['current'].remove('type') != null) {
                  modified = true;
                }
              }
              if (placeholders.containsKey('total') && placeholders['total'] is Map) {
                if (placeholders['total'].remove('type') != null) {
                  modified = true;
                }
              }

              if (modified) {
                // Use an encoder with indentation for readability
                final encoder = JsonEncoder.withIndent('  ');
                final newContent = encoder.convert(arbData);
                await file.writeAsString('$newContent\n');
                print('  Updated placeholders in $stepOfKey in ${file.path}');
              } else {
                print('  No "type" attribute to remove in $stepOfKey placeholders.');
              }
            }
          }
        } else {
          print('  No key containing "@stepOf" was found.');
        }
      } catch (e) {
        print('Error processing ${file.path}: $e');
      }
    }
  }
  print('Finished processing all .arb files.');
}
