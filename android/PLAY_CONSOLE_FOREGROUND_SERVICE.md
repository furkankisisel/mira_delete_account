# Play Console — Foreground Service Açıklaması (mira)

Bu belge, Google Play inceleyicilerine uygulamamızın neden bir Foreground Service kullandığını ve hangi manifest girdilerinin gönderildiğini açık, kısa ve doğrulanabilir şekilde anlatmak için hazırlanmıştır. İlgili paket: `com.koralabs.mira`.

## Özet
- Kullanılan özellik: Zamanlayıcı / Alışkanlık takibi (Timer)
- Amaç: Kullanıcı bir zamanlayıcı başlattığında, zamanlayıcının uygulama arka planda veya cihaz kilitliyken güvenilir şekilde çalışmaya devam etmesi; ayrıca kullanıcının bildirimden doğrudan `pause/resume/stop` kontrollerine erişebilmesi.
- Erişim: Foreground service sadece zamanlayıcı çalışırken etkindir. Servis, cihaz konumu, SMS, mikrofon, rehber veya çağrı geçmişi gibi hassas verilere erişmez.

## Hangi kod/komponent bunu başlatır
- Kaynak dosyası: `lib/core/timer/timer_controller.dart` (uygulamada zamanlayıcı başlatıldığında background service çağrısı yapılır).
- Kullanılan plugin: `flutter_background_service` / `flutter_background_service_android`. Plugin servis tanımını ve gerekli manifest ögelerini merge aşamasında ekler.

## Manifest girdileri (merged manifest'ten alınacak kısımlar)
Lütfen Play Console'a upload ederken veya reviewer notuna eklerken merged manifest içeriğini gösterin. Örnek parçalar:

Kullanılan izinler:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<!-- API 34+ ve bazı OEM gereksinimleri için subtype açıklayıcı izin (opsiyonel/ek açıklama dahil) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
```

Servis tanımı (merged manifest'te görünür):

```xml
<service
    android:name="id.flutter.flutter_background_service.BackgroundService"
    android:foregroundServiceType="specialUse"
    android:exported="false">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="Timer tracking for habit formation" />
</service>
```

Not: Plugin ayrıca zamanlayıcı bildirimleri, boot sonrası yeniden planlama ve alarm alıcıları (receivers) ekleyebilir; bu yalnızca bildirimlerin yeniden planlanması ve zamanlayıcı durumunun korunması içindir.

## Play İnceleyicisi için Kısa Doğrulama Adımları
1. Uygulamayı açın (paket: `com.koralabs.mira`).
2. Zamanlayıcı/Alışkanlık ekranından yeni bir zamanlayıcı başlatın.
3. Uygulamayı arka plana atın veya ekranı kilitleyin. Zamanlayıcının çalışmaya devam ettiğini doğrulayın.
4. Bildirim alanında uygulamaya ait kalıcı bir bildirim görünür olmalı. Bildirimde `Pause`/`Resume`/`Stop` kontrollerini kullanın ve zamanlayıcının buna göre tepki verdiğini kontrol edin.
5. Cihaz yeniden başlatıldıktan sonra (opsiyonel, eğer cron/boot receiver gönderilmişse) zamanlayıcı bildiriminin/planlamasının uygun şekilde yeniden hazırlandığını kontrol edin.

## Gizlilik ve Veri
- Zamanlayıcı durumu yerel olarak saklanır (örneğin `flutter_secure_storage`).
- Foreground service, timer mantığını yürütmek ve bildirim kontrollerini sağlamak için kullanılır; ağ üzerinden veri iletimi yalnızca kullanıcı bir satın alma işlemi gerçekleştirdiğinde veya uygulama açıkken normal arka plan senkronizasyonu olduğunda yapılır.
- Servis, konum, mikrofon, rehber, SMS veya çağrı kayıtları gibi hassas kaynaklara erişmez.

## Eğer Play ek açıklama isterse
- Bizim önerimiz: Bu açıklamayı kullanın ve isteğe bağlı olarak kısa bir video/screen recording ekleyin: zamanlayıcı başlatma → uygulamayı arka plana alma → bildirim aracılığıyla pause/resume/stop gösterimi.
- Eğer Play `FOREGROUND_SERVICE_SPECIAL_USE` izinini sorun ederse, bu izin plugin tarafından `foregroundServiceType="specialUse"` olarak eklenmektedir ve yalnızca servis alt-türünü belirtmek için kullanılır. İstenirse biz bu izin/atribütü kaldırıp daha genel bir `foregroundServiceType` kullanacak şekilde manifesti değiştirebiliriz.

## İptal / Alternatif değişiklik önerisi
- İsteğe bağlı olarak, `android:foregroundServiceType="specialUse"` ve `android.permission.FOREGROUND_SERVICE_SPECIAL_USE` manifest girdisi kaldırılabilir veya daha genel bir tip (`mediaPlayback`, `connectedDevice` veya hiç tip belirtilmeden) ile değiştirilerek Play tarafındaki inceleme sürecini kolaylaştırabiliriz. Bu değişikliği yapmamı isterseniz, plugin kaynak ve manifest birleşimi kontrol edilerek güvenli bir patch hazırlayıp sunarım.

---
Bu dosyayı repoya ekledim. Eğer metni daha kısa veya daha ayrıntılı istiyorsanız söyleyin; Play Console için doğrudan kopyalanabilir Türkçe metin gerektiği şekilde daraltabilirim.
