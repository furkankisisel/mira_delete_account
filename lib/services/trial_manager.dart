import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import 'storage_service.dart';

/// Trial yaşam döngüsü yöneticisi
class TrialManager {
  TrialManager._();
  static final TrialManager instance = TrialManager._();

  final _entitlementCtrl = StreamController<Entitlement>.broadcast();
  Stream<Entitlement> get entitlementStream => _entitlementCtrl.stream;

  Future<void> initialize() async {
    // Kullanıcı id yoksa yalnızca geliştirme veya local-stub durumunda mock id ata.
    // Prod/release ortamında otomatik mock-user atamayız çünkü bu, herkesin
    // aynı userId ile backend stub'dan premium almasına neden olabilir.
    final userId = await StorageService.instance.getUserId();
    final isLocalStub = AppConstants.backendBaseUrl.contains('localhost');
    if (userId == null && (kDebugMode || isLocalStub)) {
      await StorageService.instance.saveUserId('mock-user');
    }
    // Entitlement okunur ve yayınlanır
    final ent = await StorageService.instance.getEntitlement();
    _entitlementCtrl.add(ent);
  }

  Future<void> startTrialIfNeeded() async {
    // Otomatik trial başlatma kapatıldı.
    // Trial başlatımı artık kullanıcı onayı ile `startTrialExplicitly()`
    // çağrısı ile yapılmalıdır. Bu, kullanıcı etkileşimi olmadan premium
    // erişiminin kazanılmasını engeller.
    if (kDebugMode) {
      // Geliştirme sırasında yine de eski davranışı görmek isterseniz
      // manuel olarak startTrialExplicitly() çağırabilirsiniz.
      debugPrint(
        'TrialManager.startTrialIfNeeded: automatic trial start is disabled.',
      );
    }
    return;
  }

  /// Start a trial when the user explicitly requests it (e.g. taps "Start trial").
  /// This method preserves previous behavior but is only invoked when the app
  /// code calls it (user consent flow). It writes trial start and entitlement
  /// into secure storage and notifies listeners.
  Future<void> startTrialExplicitly() async {
    final ent = await StorageService.instance.getEntitlement();
    if (ent != Entitlement.none) return; // already trial/premium

    final start = await StorageService.instance.getTrialStart();
    if (start == null) {
      await StorageService.instance.saveTrialStart(DateTime.now());
      await StorageService.instance.saveEntitlement(Entitlement.trial);
      _entitlementCtrl.add(Entitlement.trial);
    }
  }

  Future<bool> get isTrialActive async {
    final ent = await StorageService.instance.getEntitlement();
    if (ent != Entitlement.trial) return false;
    final start = await StorageService.instance.getTrialStart();
    if (start == null) return false;
    final expiry = start.add(Duration(days: AppConstants.trialDays));
    return DateTime.now().isBefore(expiry);
  }

  Future<bool> get isInGraceWindow async {
    final start = await StorageService.instance.getTrialStart();
    if (start == null) return false;
    final trialEnd = start.add(Duration(days: AppConstants.trialDays));
    final graceEnd = trialEnd.add(Duration(days: AppConstants.graceDays));
    final now = DateTime.now();
    return now.isAfter(trialEnd) && now.isBefore(graceEnd);
  }

  Future<void> endTrialIfExpired() async {
    if (!await isTrialActive) {
      // Trial bitti: entitlement none yap (satın alma yoksa)
      final ent = await StorageService.instance.getEntitlement();
      if (ent == Entitlement.trial) {
        await StorageService.instance.saveEntitlement(Entitlement.none);
        _entitlementCtrl.add(Entitlement.none);
        // Client-side temizlik (cache vs) burada tetiklenebilir
      }
    }
  }

  /// Trial verisi üretirken bu flag'in kullanılmasını sağlar
  bool tagTrialData(Entitlement currentEntitlement) =>
      currentEntitlement == Entitlement.trial;

  /// Dış dünyadan entitlement güncellemesi yapmak için tek yer.
  /// Hem storage'a yazar hem de stream'e yayınlar.
  Future<void> setEntitlement(Entitlement ent) async {
    await StorageService.instance.saveEntitlement(ent);
    _entitlementCtrl.add(ent);
  }

  /// DEV-ONLY: Create a test premium account locally.
  ///
  /// This helper writes a test userId and grants premium entitlement. It is
  /// intentionally guarded so it only runs in debug mode or when the backend
  /// base URL points at localhost (local stub). Do NOT call this from production
  /// code or expose it in release builds.
  Future<void> createTestPremiumAccount({
    String userId = 'test-play-review',
  }) async {
    final isLocalStub = AppConstants.backendBaseUrl.contains('localhost');
    if (!(kDebugMode || isLocalStub)) {
      debugPrint('createTestPremiumAccount: blocked (not debug or local stub)');
      return;
    }

    await StorageService.instance.saveUserId(userId);
    await StorageService.instance.saveEntitlement(Entitlement.premium);
    _entitlementCtrl.add(Entitlement.premium);
    debugPrint(
      'createTestPremiumAccount: created $userId with PREMIUM entitlement',
    );
  }
}
