# IAP + Trial Mimari Özeti

Bu doküman, Flutter istemcisi ile Node.js (Express) stub backend arasındaki abonelik (IAP) ve deneme (trial) akışını anlatır.

## Ürünler
- Aylık: `com.example.app.premium.monthly` (14 gün trial)
- Yıllık: `com.example.app.premium.yearly` (14 gün trial)

## Flutter Tarafı
- `lib/config/constants.dart`: Ürün kimlikleri, trial/grace günleri, backend URL.
- `lib/services/storage_service.dart`: Secure Storage sarmalayıcı (userId, entitlement, trialStart).
- `lib/services/trial_manager.dart`: Trial başlangıcı, bitiş kontrolü, entitlement yayınlama.
- `lib/services/iap_service.dart`: in_app_purchase üzerinden ürün sorgu, satın alma, restore, purchaseStream, acknowledge ve backend `/verifyPurchase` çağrısı.
- `lib/ui/subscription_page.dart`: Plan kartları, satın al/restore/durumu yenile UI.

### Trial Verisi İşaretleme
Trial sırasında oluşturulan tüm veriler `isTrialGenerated: true` şeklinde işaretlenmelidir. Örnek veri modelleri `lib/models/*` altında bu alanı içerir.

### Cleanup Politikası
- Trial bitip kullanıcı satın almadıysa: 7 günlük grace süresi sonunda server `/cleanupTrialData` ilgili kullanıcı için hard-delete yapar.
- Client, açılışta `/checkEntitlements` çağırır ve `TrialManager.endTrialIfExpired()` ile local UI temizliği yapar (cache/flag vs.).

## Backend Stub
- `backend_stub/index.js`: Basit Express sunucu.
  - `POST /verifyPurchase`: Gerçekte Google/Apple API çağrılmalı. Stub her zaman premium verir ve `isTrialGenerated=true` kayıtları kalıcıya çevirir.
  - `POST /checkEntitlements`: Kullanıcının güncel entitlement durumunu döner.
  - `POST /cleanupTrialData`: 14+7 günden eski trial verilerini hard-delete eder.
  - `POST /webhook`: Refund/cancel event'lerinde entitlement'ı `none` yapar.

### Gerçek Doğrulama Notları
- Android: Google Play Developer API - Purchases.subscriptions
- iOS: App Store Server API - `getSubscriptionStatus`/`verifyTransaction`
- Kimlik bilgileri kodda yer almaz; ortam değişkenleri veya gizli yönetimiyle sağlanır.

## Test ve Sandbox
- Apple Sandbox ve Google Play test hesapları kullanın. Ürün kimlikleri ve trial konfigürasyonu store konsollarından yapılır.
- Manuel Senaryolar:
  1. Trial başlat, veri oluştur, trial bitince satın alma yoksa 7 gün sonra silinmesini doğrula.
  2. Trial sırasında satın al, verilerin korunduğunu ve `isTrialGenerated=false` olduğunu doğrula.
  3. Restore satın alma akışı.
  4. Refund webhook olayıyla entitlement iptal akışı.
- Otomatik Test:
  - `trial_manager_test.dart`: basit yaşam döngü kontrolü.
  - `iap_service_test.dart`: mock tabanlı akış (placeholder).

## Çalıştırma
Flutter tarafı:
```bash
flutter pub get
flutter run
```
Backend stub:
```bash
cd backend_stub
npm install
npm start
```

> Not: Backend URL `lib/config/constants.dart` içinde `http://localhost:3000` olarak ayarlı. Cihaz/emülatörden erişim için platforma göre `10.0.2.2` (Android Emulator) ya da yerel IP gerekebilir.
