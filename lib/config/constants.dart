/// App-wide constants.
class AppConstants {
  // Backend URL.
  static const String backendBaseUrl =
      'https://us-central1-mira-1fdc3.cloudfunctions.net';

  // ============= Subscription / IAP Configuration =============
  static const String packageName = 'com.koralabs.mira';
  static const String subscriptionProductId = 'mira_plus';

  // Product IDs (from Google Play Console) - for separate products
  static const String monthlyProductId = 'mira_month';
  static const String yearlyProductId = 'mira_year';

  // Base plan IDs (from Google Play Console) - for single subscription with multiple plans
  static const String monthlyBasePlanId = 'mira_month';
  static const String yearlyBasePlanId = 'mira_year';

  // Entitlement key
  static const String premiumEntitlementId = 'premium';

  // Trial duration
  static const int trialDays = 14;
}
