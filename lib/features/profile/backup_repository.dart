import 'dart:convert';
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

  Future<Map<String, dynamic>?> _findBackupFile() async {
    final token = await _getAccessToken();
    if (token == null) return null;
    // Search files in appDataFolder by name
    final q = Uri.encodeQueryComponent(
      "name = '$_backupFileName' and trashed = false",
    );
    final uri = Uri.parse(
      '$_driveFilesUrl?q=$q&spaces=appDataFolder&fields=files(id,name)',
    );
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) return null;
    final body = json.decode(res.body) as Map<String, dynamic>;
    final files = body['files'] as List<dynamic>?;
    if (files == null || files.isEmpty) return null;
    return files.first as Map<String, dynamic>;
  }

  Future<bool> uploadBackup(String jsonPayload) async {
    final token = await _getAccessToken();
    if (token == null) return false;
    final existing = await _findBackupFile();
    if (existing != null) {
      // update
      final id = existing['id'] as String;
      final uri = Uri.parse('$_driveFilesUrl/$id?uploadType=media');
      final res = await http.patch(
        uri,
        body: jsonPayload,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 200;
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
      final res = await http.post(
        uri,
        body: body.toString(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
      );
      return res.statusCode == 200 || res.statusCode == 201;
    }
  }

  Future<String?> downloadBackup() async {
    final token = await _getAccessToken();
    if (token == null) return null;
    final existing = await _findBackupFile();
    if (existing == null) return null;
    final id = existing['id'] as String;
    final uri = Uri.parse('$_driveFilesUrl/$id?alt=media');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) return null;
    return res.body;
  }
}
