import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

/// Basit secure storage sarmalayıcı
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  // iOS/Android için secure
  static const _sec = FlutterSecureStorage();

  static const _kUserId = 'userId';
  static const _kEntitlement = 'entitlement';
  static const _kTrialStart = 'trialStart';

  Future<void> saveUserId(String userId) =>
      _sec.write(key: _kUserId, value: userId);
  Future<String?> getUserId() => _sec.read(key: _kUserId);

  Future<void> saveEntitlement(Entitlement e) =>
      _sec.write(key: _kEntitlement, value: e.name);
  Future<Entitlement> getEntitlement() async {
    final v = await _sec.read(key: _kEntitlement);
    return Entitlement.values.firstWhere(
      (e) => e.name == v,
      orElse: () => Entitlement.none,
    );
  }

  Future<void> saveTrialStart(DateTime dt) =>
      _sec.write(key: _kTrialStart, value: dt.toIso8601String());
  Future<DateTime?> getTrialStart() async {
    final v = await _sec.read(key: _kTrialStart);
    return v == null ? null : DateTime.tryParse(v);
  }

  Future<void> clearAll() async {
    await _sec.deleteAll();
  }
}
