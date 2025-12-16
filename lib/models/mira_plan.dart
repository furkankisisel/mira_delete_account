import 'package:in_app_purchase/in_app_purchase.dart';

/// Represents a Mira premium subscription plan.
/// Each plan maps to a specific base plan ID in Google Play Console.
class MiraPlan {
  /// Unique identifier for this plan.
  /// Either "mira-12" (monthly) or "mira-yearly" (yearly).
  final String id;

  /// Display label for the UI (e.g., "Aylık Premium (14 gün ücretsiz)").
  final String label;

  /// Billing period: "monthly" or "yearly".
  final String billingPeriod;

  /// Trial duration, typically 14 days.
  final Duration? trial;

  /// The ProductDetails from in_app_purchase package.
  final ProductDetails productDetails;

  /// Offer token for Android, if applicable for this plan.
  /// Used when calling buyNonConsumable.
  final String? offerToken;

  /// Base plan ID from Google Play Console.
  final String basePlanId;

  /// Formatted price string (e.g., "$9.99").
  /// Derived from the product details.
  final String formattedPrice;

  MiraPlan({
    required this.id,
    required this.label,
    required this.billingPeriod,
    required this.trial,
    required this.productDetails,
    required this.basePlanId,
    required this.formattedPrice,
    this.offerToken,
  });

  @override
  String toString() =>
      'MiraPlan(id=$id, label=$label, billingPeriod=$billingPeriod, price=$formattedPrice)';
}
