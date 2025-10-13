/// Uygulama genel sabitleri ve ürün kimlikleri
class AppConstants {
  // Play Console'daki Ana Abonelik Ürünü Kimliği (Subscription ID)
  // Ekran görüntünüzden: "mira_plus"
  static const String subscriptionProductId = 'mira_plus';

  // Play Console'daki Temel Plan Kimlikleri (Base Plan IDs)
  // Artık sadece plan kimliğini kullanıyoruz, Ana Ürün ID'si yukarıda tanımlı.
  static const String productMonthlyBasePlanId = 'mira-12';
  static const String productYearlyBasePlanId = 'mira-yearly';

  // IAP ürün kimlikleri (Eğer eski kodunuz bu formatı zorluyorsa bu şekilde de kullanılabilir)
  // Ancak Flutter/Google IAP kütüphaneleri genellikle Subscription ID ve Base Plan ID'yi ayrı ayrı ister.
  // Bu değişkenler eski kütüphane/mantık için tutulabilir, ancak yeni entegrasyonda yukarıdakiler kullanılmalı.
  static const String productMonthly = 'mira_plus.mira-12';
  static const String productYearly = 'mira_plus.mira-yearly';

  // Trial süresi (gün)
  static const int trialDays = 14;
  // Trial sonrası grace period (gün)
  static const int graceDays = 7;

  // Backend URL (stub)
  static const String backendBaseUrl = 'http://localhost:3000';
}

/// Entitlement tipleri
enum Entitlement { none, trial, premium }
