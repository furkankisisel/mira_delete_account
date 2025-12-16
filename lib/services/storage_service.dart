import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper. Entitlement/trial functionality removed.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  // iOS/Android için secure
  static const _sec = FlutterSecureStorage();

  static const _kUserId = 'userId';

  Future<void> saveUserId(String userId) =>
      _sec.write(key: _kUserId, value: userId);
  Future<String?> getUserId() => _sec.read(key: _kUserId);

  Future<void> clearAll() async {
    await _sec.deleteAll();
  }
}
