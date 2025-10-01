import 'dart:convert';
import 'dart:io';

/// Syncs all ARB files in lib/l10n/ by adding any missing keys from app_en.arb.
/// - Preserves existing translations.
/// - Skips metadata keys that start with '@'.
/// - Ensures @@locale exists for each file (kept as-is if present).
/// - Does not modify app_en.arb.
Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;
  final l10nDir = Directory('$projectRoot/lib/l10n');
  final enFile = File('${l10nDir.path}/app_en.arb');

  if (!await enFile.exists()) {
    stderr.writeln('ERROR: ${enFile.path} not found.');
    exit(1);
  }

  final enMap = _readArb(enFile);
  // Build a map of only translatable keys (exclude metadata keys starting with '@')
  final enTranslatables = <String, dynamic>{}
    ..addEntries(
      enMap.entries.where((e) => !e.key.startsWith('@') && e.key != '@@locale'),
    );

  final arbFiles =
      l10nDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .where((f) => !f.path.endsWith('app_en.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (arbFiles.isEmpty) {
    stdout.writeln('No ARB files found to update.');
    return;
  }

  var totalAdded = 0;
  for (final file in arbFiles) {
    final map = _readArb(file);

    // Ensure @@locale exists
    final localeGuess = _extractLocaleFromFilename(file);
    map['@@locale'] ??= localeGuess;

    int added = 0;
    enTranslatables.forEach((key, value) {
      if (!map.containsKey(key)) {
        map[key] = value; // fallback to English
        added++;
      }
    });

    if (added > 0) {
      totalAdded += added;
      _writeArb(file, map);
      stdout.writeln('Updated ${file.uri.pathSegments.last}: +$added keys');
    } else {
      stdout.writeln('Up-to-date ${file.uri.pathSegments.last}');
    }
  }

  stdout.writeln(
    'Done. Added $totalAdded missing keys across ${arbFiles.length} files.',
  );
}

Map<String, dynamic> _readArb(File file) {
  try {
    final raw = file.readAsStringSync();
    final jsonMap = json.decode(raw);
    if (jsonMap is Map<String, dynamic>)
      return Map<String, dynamic>.from(jsonMap);
  } catch (e) {
    stderr.writeln('Failed to read ${file.path}: $e');
  }
  return <String, dynamic>{};
}

void _writeArb(File file, Map<String, dynamic> map) {
  // Sort keys with @@locale first, then others alphabetically.
  final sortedKeys = map.keys.toList()
    ..sort((a, b) {
      if (a == '@@locale') return -1;
      if (b == '@@locale') return 1;
      return a.compareTo(b);
    });

  final sorted = <String, dynamic>{};
  for (final k in sortedKeys) {
    sorted[k] = map[k];
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final content = encoder.convert(sorted) + '\n';
  file.writeAsStringSync(content);
}

String _extractLocaleFromFilename(File file) {
  // Expect filenames like app_xx.arb
  final name = file.uri.pathSegments.last;
  final match = RegExp(r'app_([a-zA-Z_-]+)\.arb').firstMatch(name);
  return match != null ? match.group(1)! : '';
}
