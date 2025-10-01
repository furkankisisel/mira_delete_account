import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desteklenen diller
enum SupportedLanguage {
  turkish('tr', 'Türkçe', '🇹🇷'),
  english('en', 'English', '🇺🇸'),
  german('de', 'Deutsch', '🇩🇪'),
  french('fr', 'Français', '🇫🇷'),
  spanish('es', 'Español', '🇪🇸'),
  italian('it', 'Italiano', '🇮🇹'),
  portuguese('pt', 'Português', '🇵🇹'),
  russian('ru', 'Русский', '🇷🇺'),
  japanese('ja', '日本語', '🇯🇵'),
  korean('ko', '한국어', '🇰🇷'),
  chinese('zh', '中文', '🇨🇳'),
  arabic('ar', 'العربية', '🇸🇦'),
  hindi('hi', 'हिन्दी', '🇮🇳'),
  dutch('nl', 'Nederlands', '🇳🇱');

  const SupportedLanguage(this.code, this.displayName, this.flag);

  final String code;
  final String displayName;
  final String flag;

  /// Varsayılan dil
  static const SupportedLanguage defaultLanguage = SupportedLanguage.turkish;

  /// Locale'e dönüştür
  Locale get locale => Locale(code);

  /// Code'dan dili bul
  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => defaultLanguage,
    );
  }

  /// Locale'den dili bul
  static SupportedLanguage fromLocale(Locale locale) {
    return fromCode(locale.languageCode);
  }
}

/// Dil yönetimi sınıfı
class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _isSystemLanguageKey = 'is_system_language';

  SupportedLanguage _currentLanguage = SupportedLanguage.defaultLanguage;
  bool _isSystemLanguage = true;

  /// Mevcut dil
  SupportedLanguage get currentLanguage => _currentLanguage;

  /// Mevcut locale
  Locale get currentLocale => _currentLanguage.locale;

  /// Sistem dili kullanılıyor mu?
  bool get isSystemLanguage => _isSystemLanguage;

  /// Desteklenen dillerin listesi
  List<SupportedLanguage> get supportedLanguages => SupportedLanguage.values;

  /// Desteklenen locale'ların listesi
  List<Locale> get supportedLocales =>
      supportedLanguages.map((lang) => lang.locale).toList();

  /// LanguageManager'ı başlat
  Future<void> initialize() async {
    await _loadLanguagePreferences();
    detectSystemLanguage();
  }

  /// Kaydedilmiş dil tercihlerini yükle
  Future<void> _loadLanguagePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSystemLanguage = prefs.getBool(_isSystemLanguageKey) ?? true;

      if (!_isSystemLanguage) {
        final languageCode = prefs.getString(_languageKey);
        if (languageCode != null) {
          _currentLanguage = SupportedLanguage.fromCode(languageCode);
        }
      }
    } catch (e) {
      // Hata durumunda varsayılan değerleri kullan
      _isSystemLanguage = true;
      _currentLanguage = SupportedLanguage.defaultLanguage;
    }
  }

  /// Dil tercihlerini kaydet
  Future<void> _saveLanguagePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSystemLanguageKey, _isSystemLanguage);
      if (!_isSystemLanguage) {
        await prefs.setString(_languageKey, _currentLanguage.code);
      }
    } catch (e) {
      // Kaydetme hatası - kullanıcıya bildir veya sessizce yoksay
      debugPrint('Language preference save error: $e');
    }
  }

  /// Sistem dilini kontrol et ve uygun dili seç
  void detectSystemLanguage() {
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    if (systemLocales.isNotEmpty) {
      final detectedLanguage = SupportedLanguage.fromLocale(
        systemLocales.first,
      );

      if (_isSystemLanguage) {
        _currentLanguage = detectedLanguage;
        notifyListeners();
      }
    }
  }

  /// Dil değiştir (manuel seçim)
  Future<void> changeLanguage(SupportedLanguage language) async {
    if (_currentLanguage != language || _isSystemLanguage) {
      _currentLanguage = language;
      _isSystemLanguage = false;
      await _saveLanguagePreferences();
      notifyListeners();
    }
  }

  /// Sistem dilini kullan
  Future<void> useSystemLanguage() async {
    _isSystemLanguage = true;
    await _saveLanguagePreferences();
    detectSystemLanguage();
    notifyListeners();
  }
}
