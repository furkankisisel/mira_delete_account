import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final l10nDir = Directory('lib/l10n');
  final trFile = File('${l10nDir.path}/app_tr.arb');
  final enFile = File('${l10nDir.path}/app_en.arb');

  if (!await trFile.exists() || !await enFile.exists()) {
    print('Error: tr or en file missing.');
    return;
  }

  final trContent =
      jsonDecode(await trFile.readAsString()) as Map<String, dynamic>;
  final enContent =
      jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;

  final trKeys = trContent.keys.where((k) => !k.startsWith('@')).toSet();
  final enKeys = enContent.keys.where((k) => !k.startsWith('@')).toSet();

  final missingInEn = trKeys.difference(enKeys);

  print('Missing keys in EN (${missingInEn.length}):');
  for (final key in missingInEn) {
    print(key);
  }
}
