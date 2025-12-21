import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final l10nDir = Directory('lib/l10n');
  final trFile = File('${l10nDir.path}/app_tr.arb');

  if (!await trFile.exists()) {
    print('Error: app_tr.arb not found.');
    return;
  }

  final trContent =
      jsonDecode(await trFile.readAsString()) as Map<String, dynamic>;
  final trKeys = trContent.keys.where((k) => !k.startsWith('@')).toSet();

  print('Total keys in TR (template): ${trKeys.length}');

  await for (final file in l10nDir.list()) {
    if (file is File &&
        file.path.endsWith('.arb') &&
        !file.path.endsWith('app_tr.arb')) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      try {
        final content =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final keys = content.keys.where((k) => !k.startsWith('@')).toSet();

        final missing = trKeys.difference(keys);

        if (missing.isNotEmpty) {
          print('\n$fileName is missing ${missing.length} keys:');
          missing.take(10).forEach((k) => print(' - $k'));
          if (missing.length > 10)
            print(' ... and ${missing.length - 10} more');
        } else {
          print('\n$fileName has all keys.');
        }
      } catch (e) {
        print('Error reading $fileName: $e');
      }
    }
  }
}
