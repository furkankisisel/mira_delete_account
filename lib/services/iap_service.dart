import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../config/constants.dart';
import '../models/mira_plan.dart';
import 'premium_manager.dart';

class IAPService {
  IAPService._();
  static final IAPService instance = IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;

  final List<MiraPlan> _plans = [];
  List<MiraPlan> get plans => _plans;

  bool _isReady = false;
  bool get isReady => _isReady;

  final StreamController<PurchaseDetails> _purchaseUpdates =
      StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseUpdates.stream;

  final StreamController<bool> _premiumStatusStream =
      StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusStream.stream;

  Future<void> init() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[IAP] Mağaza kullanılamıyor.');
      _isReady = false;
      return;
    }

    _isReady = true;
    _purchaseStreamSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (error) => debugPrint('[IAP] Stream Hatası: $error'),
    );
  }

  /// Ürünleri Google Play'den yükler
  Future<void> loadProducts() async {
    try {
      // Artık iki ayrı ID sorguluyoruz
      final Set<String> ids = {
        AppConstants.monthlyProductId, // mira_month
        AppConstants.yearlyProductId, // mira_year
      };

      final ProductDetailsResponse response = await _iap.queryProductDetails(
        ids,
      );

      if (response.error != null) {
        debugPrint('[IAP] Ürün çekme hatası: ${response.error}');
        return;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('[IAP] Ürün bulunamadı. ID\'leri kontrol edin: $ids');
        return;
      }

      _plans.clear();

      for (final product in response.productDetails) {
        debugPrint('[IAP] Ürün yüklendi: ${product.id} - ${product.price}');

        // ID'ye göre hangisi olduğunu anlıyoruz
        final bool isMonthly = product.id == AppConstants.monthlyProductId;

        final plan = MiraPlan(
          id: product.id,
          label: isMonthly ? 'Monthly Premium' : 'Yearly Premium',
          billingPeriod: isMonthly ? 'monthly' : 'yearly',
          trial: const Duration(days: AppConstants.trialDays),
          productDetails: product,
          basePlanId: product.id,
          formattedPrice: product.price, // Direkt kendi fiyatı
          offerToken: null,
        );
        _plans.add(plan);
      }

      // Listeyi sıralayalım (Önce aylık, sonra yıllık görünsün)
      _plans.sort((a, b) => a.billingPeriod == 'monthly' ? -1 : 1);
    } catch (e) {
      debugPrint('[IAP] Yükleme hatası: $e');
    }
  }

  Future<void> buyPlan(MiraPlan plan) async {
    if (!_isReady) await init();

    debugPrint('[IAP] Satın alınıyor: ${plan.id}');

    // Ayrı ürünler olduğu için PurchaseParam yeterlidir
    final PurchaseParam purchaseParam;

    if (Platform.isAndroid && plan.productDetails is GooglePlayProductDetails) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: plan.productDetails as GooglePlayProductDetails,
      );
    } else {
      purchaseParam = PurchaseParam(productDetails: plan.productDetails);
    }

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        debugPrint('[IAP] Başarılı işlem: ${purchase.productID}');

        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }

        // Calculate expiry date based on product type
        DateTime? expiryDate;
        if (purchase.productID == AppConstants.monthlyProductId) {
          // Monthly subscription: 1 month + 14 day trial
          expiryDate = DateTime.now().add(
            const Duration(days: 30 + AppConstants.trialDays),
          );
        } else if (purchase.productID == AppConstants.yearlyProductId) {
          // Yearly subscription: 1 year + 14 day trial
          expiryDate = DateTime.now().add(
            const Duration(days: 365 + AppConstants.trialDays),
          );
        }

        PremiumManager.instance.setPremium(true, expiryDate: expiryDate);
        _premiumStatusStream.add(true);

        debugPrint('[IAP] Premium activated until: $expiryDate');
      }
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _purchaseStreamSubscription.cancel();
    _purchaseUpdates.close();
    _premiumStatusStream.close();
  }
}
