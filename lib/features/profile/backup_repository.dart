import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_repository.dart';

class BackupRepository {
  BackupRepository._();
  static final BackupRepository instance = BackupRepository._();

  static const _driveFilesUrl = 'https://www.googleapis.com/drive/v3/files';
  static const _backupFileName = 'mira_backup.json';

  Future<String?> _getAccessToken() async {
    final headers = await AuthRepository.instance.getAuthHeaders();
    return headers?['Authorization']?.replaceFirst('Bearer ', '');
  }

  Future<http.Response?> _withAuth(
    Future<http.Response> Function(String token) run,
  ) async {
    var token = await _getAccessToken();
    if (token == null) {
      throw Exception(
        'Yetkilendirme başarısız. Lütfen Google hesabınızla giriş yapın.',
      );
    }

    debugPrint(
      'Attempting backup with token (first ${token.length > 20 ? token.substring(0, 20) : token}...)',
    );
    var res = await run(token);
    debugPrint('Backup response: ${res.statusCode}');

    // If unauthorized/forbidden, try requesting Drive AppData scope and retry
    if (res.statusCode == 401 || res.statusCode == 403) {
      debugPrint('Backup auth failed (${res.statusCode})');
      debugPrint('Response body: ${res.body}');

      // Parse error for more details
      String? errorReason;
      String? errorDomain;
      String? activationUrl;
      bool isServiceDisabled = false;

      try {
        final errorBody = json.decode(res.body);
        errorReason = errorBody['error']?['message'];

        // Check for SERVICE_DISABLED specifically
        final details = errorBody['error']?['details'] as List?;
        if (details != null) {
          for (final detail in details) {
            if (detail['reason'] == 'SERVICE_DISABLED') {
              isServiceDisabled = true;
              activationUrl = detail['metadata']?['activationUrl'];
              debugPrint('SERVICE_DISABLED detected');
              debugPrint('Activation URL: $activationUrl');
            }
          }
        }

        // Also check errors array
        final errors = errorBody['error']?['errors'] as List?;
        if (errors != null && errors.isNotEmpty) {
          errorDomain = errors[0]['reason'];
        }

        if (errorReason != null) {
          debugPrint('Error reason: $errorReason');
        }
      } catch (e) {
        debugPrint('Error parsing error body: $e');
      }

      // If Drive API is not enabled, throw immediate helpful error
      if (isServiceDisabled && activationUrl != null) {
        throw Exception(
          '🚫 Google Drive API Etkin Değil\n\n'
          'Google Cloud Console\'da Drive API\'yi etkinleştirmeniz gerekiyor.\n\n'
          '📋 ADIMLAR:\n'
          '1. Bu linke tıklayın (tarayıcıda açın):\n'
          '   $activationUrl\n\n'
          '2. "ENABLE" (Etkinleştir) butonuna basın\n\n'
          '3. Birkaç dakika bekleyin (API aktifleşmesi için)\n\n'
          '4. Bu uygulamaya geri dönüp tekrar deneyin\n\n'
          '💡 İpucu: Link uzunsa, ekran görüntüsü alıp tarayıcıda açın.',
        );
      }

      if (res.statusCode == 401) {
        debugPrint('401 = Token expired or invalid, forcing token refresh...');
      } else {
        debugPrint('403 = Permission denied, requesting Drive scope...');
      }

      // Request Drive scope (this also triggers token refresh)
      final granted = await AuthRepository.instance.requestDriveAppDataScope();
      debugPrint('Drive scope request result: $granted');

      if (!granted) {
        debugPrint('Drive scope NOT granted by user');
        throw Exception(
          'Google Drive yetkisi gerekli.\n\n'
          'Lütfen tekrar deneyin ve açılan pencereden Drive erişimine izin verin.',
        );
      }

      debugPrint('Drive scope granted, waiting for token refresh...');
      // Longer delay to ensure token is fully refreshed
      await Future.delayed(const Duration(seconds: 2));

      // Force a completely fresh token by clearing cache
      await AuthRepository.instance.clearTokenCache();

      token = await _getAccessToken();
      if (token == null) {
        throw Exception(
          'Token alınamadı.\n\n'
          'Lütfen çıkış yapıp tekrar giriş yapın.',
        );
      }
      debugPrint(
        'New token obtained (first ${token.length > 20 ? token.substring(0, 20) : token}...)',
      );
      debugPrint('Retrying backup with new token...');
      res = await run(token);
      debugPrint('Retry response: ${res.statusCode}');

      if (res.statusCode == 401 || res.statusCode == 403) {
        debugPrint('Still getting ${res.statusCode} after retry');
        debugPrint('Response body: ${res.body}');

        if (res.statusCode == 403) {
          debugPrint(
            'CRITICAL: 403 after scope grant suggests configuration issue',
          );
          debugPrint('1. Google Drive API may not be enabled in Cloud Console');
          debugPrint(
            '2. OAuth consent screen may not have drive.appdata scope',
          );
          debugPrint('3. App credentials may be misconfigured');

          throw Exception(
            '403: Google Drive erişimi reddedildi.\n\n'
            'Muhtemel nedenler:\n'
            '• Google Cloud Console\'da Drive API etkin değil\n'
            '• OAuth ekranında drive.appdata scope\'u eksik\n'
            '• Kullanıcı test listesine eklenmemiş\n\n'
            'Çözüm: "Yeniden Google\'a Bağlan" butonuna basın.\n'
            'Sorun devam ederse geliştirici ile iletişime geçin.',
          );
        }

        if (res.statusCode == 401) {
          throw Exception(
            'Token hala geçersiz.\n\n'
            'Lütfen "Yeniden Google\'a Bağlan" butonuna basın ve çıkış yapıp tekrar giriş yapın.',
          );
        }
      }
    }
    return res;
  }

  Future<Map<String, dynamic>?> _findBackupFile() async {
    // Search files in appDataFolder by name
    final q = Uri.encodeQueryComponent(
      "name = '$_backupFileName' and trashed = false",
    );
    final uri = Uri.parse(
      '$_driveFilesUrl?q=$q&spaces=appDataFolder&fields=files(id,name)',
    );
    final res = await _withAuth(
      (token) => http.get(uri, headers: {'Authorization': 'Bearer $token'}),
    );
    if (res == null) return null;
    if (res.statusCode != 200) {
      debugPrint('Backup find failed: ${res.statusCode} ${res.body}');
      return null;
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final files = body['files'] as List<dynamic>?;
    if (files == null || files.isEmpty) return null;
    return files.first as Map<String, dynamic>;
  }

  Future<void> uploadBackup(String jsonPayload) async {
    final existing = await _findBackupFile();
    if (existing != null) {
      // update
      final id = existing['id'] as String;
      // Use the upload endpoint for media updates
      final uri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files/$id?uploadType=media',
      );
      final res = await _withAuth(
        (token) => http.patch(
          uri,
          body: jsonPayload,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (res == null) {
        throw Exception(
          'İstek başarısız. Lütfen internet bağlantınızı kontrol edin.',
        );
      }
      if (res.statusCode != 200) {
        debugPrint('Backup update failed: ${res.statusCode} ${res.body}');
        throw Exception('Backup güncelleme başarısız (${res.statusCode})');
      }
      debugPrint('Backup updated successfully');
    } else {
      // create with metadata to add to appDataFolder
      final uri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
      );
      final metadata = json.encode({
        'name': _backupFileName,
        'parents': ['appDataFolder'],
      });
      final boundary =
          '----MiraBoundary${DateTime.now().millisecondsSinceEpoch}';
      final body = StringBuffer()
        ..writeln('--$boundary')
        ..writeln('Content-Type: application/json; charset=UTF-8')
        ..writeln()
        ..writeln(metadata)
        ..writeln('--$boundary')
        ..writeln('Content-Type: application/json')
        ..writeln()
        ..writeln(jsonPayload)
        ..writeln('--$boundary--');
      final res = await _withAuth(
        (token) => http.post(
          uri,
          body: body.toString(),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/related; boundary=$boundary',
          },
        ),
      );
      if (res == null) {
        throw Exception(
          'İstek başarısız. Lütfen internet bağlantınızı kontrol edin.',
        );
      }
      if (res.statusCode != 200 && res.statusCode != 201) {
        debugPrint('Backup create failed: ${res.statusCode} ${res.body}');
        throw Exception('Backup oluşturma başarısız (${res.statusCode})');
      }
      debugPrint('Backup created successfully');
    }
  }

  Future<String?> downloadBackup() async {
    final existing = await _findBackupFile();
    if (existing == null) {
      throw Exception('Backup bulunamadı');
    }
    final id = existing['id'] as String;
    final uri = Uri.parse('$_driveFilesUrl/$id?alt=media');
    final res = await _withAuth(
      (token) => http.get(uri, headers: {'Authorization': 'Bearer $token'}),
    );
    if (res == null) {
      throw Exception(
        'İstek başarısız. Lütfen internet bağlantınızı kontrol edin.',
      );
    }
    if (res.statusCode != 200) {
      debugPrint('Backup download failed: ${res.statusCode} ${res.body}');
      throw Exception('Backup indirme başarısız (${res.statusCode})');
    }
    debugPrint('Backup downloaded successfully');
    return res.body;
  }
}
