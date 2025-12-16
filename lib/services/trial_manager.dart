// Trial/entitlement system removed. This file contains a minimal stub so
// source files that still import it will fail fast and are easy to locate.

class TrialManager {
  TrialManager._();
  static final TrialManager instance = TrialManager._();

  Never _unsupported() =>
      throw UnsupportedError('TrialManager has been removed');

  Future<void> initialize() async => _unsupported();
  Future<void> setEntitlement(Object ent) async => _unsupported();
  Future<void> startTrialExplicitly() async => _unsupported();
  Future<void> endTrialIfExpired() async => _unsupported();
  Future<bool> get isTrialActive async => _unsupported();
}
