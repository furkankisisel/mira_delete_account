import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'vision_template.dart';

class VisionTemplateRepository {
  VisionTemplateRepository._();
  static final instance = VisionTemplateRepository._();

  Future<List<VisionTemplate>> loadBundled({String? lang}) async {
    final locale = ui.PlatformDispatcher.instance.locale;
    final resolvedLang = (lang != null && lang.isNotEmpty)
        ? lang.toLowerCase()
        : ((locale.languageCode.isNotEmpty)
              ? locale.languageCode.toLowerCase()
              : 'en');
    final candidates = <String>[
      // Prefer language-specific file if available
      'assets/seeds/vision_templates.$resolvedLang.json',
      // Fallbacks
      'assets/seeds/vision_templates.json',
      'assets/vision_templates.json',
    ];
    List<VisionTemplate>? localized;
    String? localizedPath;
    for (final p in candidates) {
      try {
        final str = await rootBundle.loadString(p);
        final raw = (json.decode(str) as List).cast<Map<String, dynamic>>();
        final list = raw.map(VisionTemplate.fromJson).toList();
        // First successful load becomes primary
        localized ??= list;
        localizedPath ??= p;
        break;
      } catch (_) {}
    }
    // If we loaded a language-specific file, merge in any missing templates from default
    if (localized != null &&
        localizedPath != null &&
        localizedPath.endsWith('.$resolvedLang.json')) {
      try {
        final fallbackStr = await rootBundle.loadString(
          'assets/seeds/vision_templates.json',
        );
        final fallbackRaw = (json.decode(fallbackStr) as List)
            .cast<Map<String, dynamic>>();
        final fallback = fallbackRaw.map(VisionTemplate.fromJson).toList();
        final existingIds = localized.map((e) => e.id).toSet();
        final merged = [
          ...localized,
          ...fallback.where((e) => !existingIds.contains(e.id)),
        ];
        return merged;
      } catch (_) {
        // If fallback merge fails, just return localized
        return localized;
      }
    }
    if (localized != null) return localized;
    return const [];
  }

  Future<void> exportToFile(
    List<VisionTemplate> templates,
    String filePath,
  ) async {
    final file = File(filePath);
    final jsonStr = json.encode(templates.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonStr);
  }

  Future<List<VisionTemplate>> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return const [];
    final str = await file.readAsString();
    final raw = (json.decode(str) as List).cast<Map<String, dynamic>>();
    return raw.map(VisionTemplate.fromJson).toList();
  }

  // --- Link sharing helpers ---
  // Encode a single template as a compact base64url string prefixed with mira://vision?tpl=
  String toShareLink(VisionTemplate template) {
    final map = template.toJson();
    // Keep it portable: ensure autoSeed false and endDate removed
    map['autoSeed'] = false;
    map.remove('endDate');
    final jsonStr = json.encode(map);
    final bytes = utf8.encode(jsonStr);
    final b64 = base64Url.encode(bytes);
    return 'mira://vision?tpl=$b64';
  }

  // Decode a single template from a share link; returns null if invalid
  VisionTemplate? fromShareLink(String link) {
    try {
      final uri = Uri.parse(link.trim());
      String? encoded;
      if (uri.scheme == 'mira') {
        encoded = uri.queryParameters['tpl'];
      } else {
        // also support plain base64 passed directly
        encoded = link.trim();
      }
      if (encoded == null || encoded.isEmpty) return null;
      final bytes = base64Url.decode(encoded);
      final str = utf8.decode(bytes);
      final map = json.decode(str) as Map<String, dynamic>;
      // Ensure required fields
      map['autoSeed'] = false;
      map.remove('endDate');
      // If id missing, synthesize a stable-ish one
      map['id'] = (map['id']?.toString().isNotEmpty == true)
          ? map['id']
          : 'tpl_${DateTime.now().millisecondsSinceEpoch}';
      return VisionTemplate.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
