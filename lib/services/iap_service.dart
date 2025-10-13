import 'dart:async';
import 'dart:io' show Platform;
import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import 'storage_service.dart';
import 'trial_manager.dart';

/// IAP servis: ürün sorgu, satın alma, restore ve doğrulama
class IAPService {
  IAPService._({http.Client? httpClient}) : _http = httpClient ?? http.Client();
  static final IAPService instance = IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  final http.Client _http;

  final StreamController<PurchaseDetails> _purchaseEvents =
      StreamController.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseEvents.stream;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // Ürünleri sorgula
    await queryProducts();

    // Satın alma stream'i dinle
    _sub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final p in purchases) {
          _purchaseEvents.add(p);
          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            await _verifyAndAcknowledge(p);
          } else if (p.status == PurchaseStatus.error) {
            // Hata durumunu logla/handle et
          }
        }
      },
      onDone: () => _sub?.cancel(),
      onError: (e) {},
    );

    // Uygulama açılışında server'dan güncel entitlement'ı çek
    await refreshEntitlementsFromServer();
  }

  Future<void> queryProducts() async {
    final ids = {AppConstants.productMonthly, AppConstants.productYearly};
    final response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
  }

  Future<bool> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restore() async => _iap.restorePurchases();

  Future<void> dispose() async {
    await _sub?.cancel();
    await _purchaseEvents.close();
  }

  Future<void> _verifyAndAcknowledge(PurchaseDetails p) async {
    // Platform ve receipt bilgisi
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final receipt = p.verificationData.serverVerificationData;
    final userId = await StorageService.instance.getUserId() ?? 'mock-user';

    // Backend doğrulaması
    final uri = Uri.parse('${AppConstants.backendBaseUrl}/verifyPurchase');
    try {
      final res = await _http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'platform': platform,
          'productId': p.productID,
          'receipt': receipt,
        }),
      );
      if (res.statusCode == 200) {
        await TrialManager.instance.setEntitlement(Entitlement.premium);
      }
    } catch (_) {}

    // Acknowledge / complete purchase
    if (p.pendingCompletePurchase) {
      await _iap.completePurchase(p);
    }
  }

  Future<Entitlement> refreshEntitlementsFromServer() async {
    final userId = await StorageService.instance.getUserId() ?? 'mock-user';
    final uri = Uri.parse('${AppConstants.backendBaseUrl}/checkEntitlements');
    try {
      final res = await _http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final entStr = (data['entitlement'] as String?) ?? 'none';
        final ent = Entitlement.values.firstWhere(
          (e) => e.name == entStr,
          orElse: () => Entitlement.none,
        );
        await TrialManager.instance.setEntitlement(ent);
        return ent;
      }
    } catch (_) {}
    return StorageService.instance.getEntitlement();
  }

  /// Trial bitmiş ve satın alma yoksa, client-side temizlik ve UI güncelleme
  Future<void> clientCleanupIfNeeded() async {
    await TrialManager.instance.endTrialIfExpired();
  }
}
