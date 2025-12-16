import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;

/// Google Drive tabanlı basit yedekleme/geri yükleme yöneticisi.
/// - GoogleSignIn ile kimlik doğrulama
/// - Drive API v3 ile dosya listeleme, yükleme ve indirme
class GoogleDriveBackupManager {
  GoogleDriveBackupManager._();
  static final GoogleDriveBackupManager instance = GoogleDriveBackupManager._();

  // Drive AppData scope ile başlat
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  /// Drive API için gerekli scope
  static const String driveScope = drive.DriveApi.driveFileScope;

  /// Sign-in ve scope sağlama
  Future<GoogleSignInAccount?> _ensureSignedInWithDriveScope() async {
    GoogleSignInAccount? acc = await _googleSignIn.signInSilently();
    acc ??= await _googleSignIn.signIn();
    if (acc == null) return null;

    // Eğer Drive scope'u yoksa, iste
    final hasDrive = await _googleSignIn.requestScopes([driveScope]);
    if (!hasDrive) return null;
    return acc;
  }

  /// HTTP client oluştur (Signed)
  Future<http.Client?> _authedClient() async {
    final acc = await _ensureSignedInWithDriveScope();
    if (acc == null) return null;
    try {
      final headers = await acc.authHeaders;
      final base = http_io.IOClient(HttpClient());
      return _GoogleAuthClient(base, headers);
    } on PlatformException {
      return null;
    }
  }

  /// Verilen [data] içeriğini JSON dosyası olarak Drive'a yükler.
  Future<String?> backupToDrive(String data) async {
    final client = await _authedClient();
    if (client == null) return null;

    try {
      final api = drive.DriveApi(client);
      final now = DateTime.now();
      final name =
          'mira_yedekleme_${now.toIso8601String().split('T').first}.json';

      final media = drive.Media(
        Stream<List<int>>.fromIterable([utf8.encode(data)]),
        utf8.encode(data).length,
      );

      final file = drive.File();
      file.name = name;
      file.mimeType = 'application/json';

      final created = await api.files.create(file, uploadMedia: media);
      return created.id; // başarı: dosya id döner
    } catch (e) {
      if (kDebugMode) debugPrint('Drive backup error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Drive'daki yedekleme dosyalarını listeler (en yeni önce)
  Future<List<drive.File>> listBackups() async {
    final client = await _authedClient();
    if (client == null) return [];
    try {
      final api = drive.DriveApi(client);
      final res = await api.files.list(
        q: "name contains 'mira_yedekleme_' and mimeType='application/json'",
        spaces: 'drive',
        $fields: 'files(id,name,modifiedTime)',
        orderBy: 'modifiedTime desc',
        pageSize: 50,
      );
      return res.files ?? [];
    } catch (e) {
      if (kDebugMode) debugPrint('Drive list error: $e');
      return [];
    } finally {
      client.close();
    }
  }

  /// Seçilen dosyayı indirip String olarak döndürür.
  Future<String?> restoreFromDrive(String fileId) async {
    final client = await _authedClient();
    if (client == null) return null;
    try {
      final api = drive.DriveApi(client);
      final media =
          await api.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;
      final bytes = await media.stream.fold<List<int>>(
        [],
        (p, e) => p..addAll(e),
      );
      return utf8.decode(bytes);
    } catch (e) {
      if (kDebugMode) debugPrint('Drive restore error: $e');
      return null;
    } finally {
      client.close();
    }
  }
}

/// Google Sign-In authHeaders kullanan basit Client sarmalayıcı
class _GoogleAuthClient extends http.BaseClient {
  final http.Client _base;
  final Map<String, String> _headers;
  _GoogleAuthClient(this._base, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _base.send(request);
  }

  @override
  void close() => _base.close();
}
