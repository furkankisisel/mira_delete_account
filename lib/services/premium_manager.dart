import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the premium entitlement status for the user.
/// This is a singleton that acts as the single source of truth for premium status.
///
/// Features:
/// - Loads/saves premium status from SharedPreferences
/// - Provides reactive stream for UI updates
/// - Thread-safe singleton pattern
class PremiumManager {
  PremiumManager._();
  static final PremiumManager instance = PremiumManager._();

  static const String _premiumStatusKey = 'premium_status';
  static const String _premiumExpiryKey = 'premium_expiry_timestamp';
  static const String _promoCodeUsedKey = 'promo_code_used';

  // Valid promo codes for unlimited premium access
  static const List<String> _validPromoCodes = ['OZELKULLANICI'];

  /// Whether the user currently has premium.
  bool _isPremium = false;
  bool get isPremium => _checkPremiumValidity();

  /// Expiry timestamp (milliseconds since epoch)
  int? _expiryTimestamp;
  DateTime? get expiryDate => _expiryTimestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(_expiryTimestamp!)
      : null;

  /// Whether a promo code was used for unlimited access
  String? _usedPromoCode;
  String? get usedPromoCode => _usedPromoCode;

  /// Stream that emits true/false when premium status changes.
  final StreamController<bool> _premiumStatusStream =
      StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusStream.stream;

  /// Check if premium is still valid (not expired)
  bool _checkPremiumValidity() {
    if (!_isPremium) return false;

    if (_expiryTimestamp == null) {
      // No expiry set, consider it valid (legacy support)
      return _isPremium;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final isValid = now < _expiryTimestamp!;

    if (!isValid && _isPremium) {
      // Premium expired, update status
      debugPrint('[Premium] Subscription expired');
      _isPremium = false;
      _premiumStatusStream.add(false);
      _savePremiumStatus();
    }

    return isValid;
  }

  /// Initialize the premium manager by loading status from persistent storage.
  /// Call this during app startup.
  Future<void> init() async {
    try {
      await _loadPremiumStatus();
      final isValid = _checkPremiumValidity();
      debugPrint(
        '[Premium] Initialized. isPremium=$isValid, expires=$expiryDate, promoCode=$_usedPromoCode',
      );
      _premiumStatusStream.add(isValid);
    } catch (e) {
      debugPrint('[Premium] Error initializing: $e');
      _isPremium = false;
    }
  }

  /// Update premium entitlement status.
  /// Saves to SharedPreferences and notifies listeners.
  /// [value] - premium status
  /// [expiryDate] - optional expiry date for the subscription
  Future<void> setPremium(bool value, {DateTime? expiryDate}) async {
    final wasValid = _checkPremiumValidity();
    _isPremium = value;

    if (expiryDate != null) {
      _expiryTimestamp = expiryDate.millisecondsSinceEpoch;
    } else if (value) {
      // If setting premium without expiry, set a default far future date
      _expiryTimestamp = DateTime.now()
          .add(const Duration(days: 365 * 10))
          .millisecondsSinceEpoch;
    } else {
      _expiryTimestamp = null;
    }

    final isValid = _checkPremiumValidity();

    if (wasValid != isValid) {
      _premiumStatusStream.add(isValid);
    }

    try {
      await _savePremiumStatus();
      debugPrint(
        '[Premium] Status set to $value, expires=$expiryDate, persisted',
      );
    } catch (e) {
      debugPrint('[Premium] Error persisting status: $e');
    }
  }

  /// Save premium status to SharedPreferences.
  Future<void> _savePremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumStatusKey, _isPremium);
      if (_expiryTimestamp != null) {
        await prefs.setInt(_premiumExpiryKey, _expiryTimestamp!);
      } else {
        await prefs.remove(_premiumExpiryKey);
      }
      if (_usedPromoCode != null) {
        await prefs.setString(_promoCodeUsedKey, _usedPromoCode!);
      } else {
        await prefs.remove(_promoCodeUsedKey);
      }
    } catch (e) {
      debugPrint('[Premium] Error saving to SharedPreferences: $e');
      rethrow;
    }
  }

  /// Load premium status from SharedPreferences.
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumStatusKey) ?? false;
      _expiryTimestamp = prefs.getInt(_premiumExpiryKey);
      _usedPromoCode = prefs.getString(_promoCodeUsedKey);
      debugPrint(
        '[Premium] Loaded from storage: isPremium=$_isPremium, expiry=$_expiryTimestamp, promoCode=$_usedPromoCode',
      );
    } catch (e) {
      debugPrint('[Premium] Error loading from SharedPreferences: $e');
      _isPremium = false;
      _expiryTimestamp = null;
      _usedPromoCode = null;
    }
  }

  /// Activate premium using a promo code.
  /// Returns true if the code is valid and premium was activated.
  Future<bool> activatePromoCode(String code) async {
    final trimmedCode = code.trim().toUpperCase();

    if (!_validPromoCodes.contains(trimmedCode)) {
      debugPrint('[Premium] Invalid promo code: $code');
      return false;
    }

    // Check if already used
    if (_usedPromoCode != null) {
      debugPrint('[Premium] Promo code already used: $_usedPromoCode');
      return false;
    }

    // Activate unlimited premium (10 years expiry)
    _usedPromoCode = trimmedCode;
    await setPremium(
      true,
      expiryDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    debugPrint('[Premium] Promo code activated: $trimmedCode');
    return true;
  }

  /// Check if a promo code has been used
  bool get hasUsedPromoCode => _usedPromoCode != null;

  /// Dispose resources.
  Future<void> dispose() async {
    await _premiumStatusStream.close();
    debugPrint('[Premium] Disposed');
  }
}
