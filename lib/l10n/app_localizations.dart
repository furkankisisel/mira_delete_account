import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account;

  /// No description provided for @achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar'**
  String get achievements;

  /// No description provided for @activeDays.
  ///
  /// In tr, this message translates to:
  /// **'Aktif günler'**
  String get activeDays;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @addHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Ekle'**
  String get addHabit;

  /// No description provided for @addImage.
  ///
  /// In tr, this message translates to:
  /// **'Resim Ekle'**
  String get addImage;

  /// No description provided for @addNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Ekle'**
  String get addNew;

  /// No description provided for @addNewHabit.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Alışkanlık Ekle'**
  String get addNewHabit;

  /// No description provided for @addSpecialDays.
  ///
  /// In tr, this message translates to:
  /// **'Özel Günler Ekle'**
  String get addSpecialDays;

  /// No description provided for @addText.
  ///
  /// In tr, this message translates to:
  /// **'Metin Ekle'**
  String get addText;

  /// No description provided for @advancedHabit.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Alışkanlık'**
  String get advancedHabit;

  /// No description provided for @allLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get allLabel;

  /// No description provided for @alsoDeleteLinkedHabits.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı alışkanlıkları da sil'**
  String get alsoDeleteLinkedHabits;

  /// No description provided for @amountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get amountLabel;

  /// No description provided for @socialFeedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get socialFeedTitle;

  /// No description provided for @spendingAdvisorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Danışmanı'**
  String get spendingAdvisorTitle;

  /// No description provided for @spendingAdvisorSafe.
  ///
  /// In tr, this message translates to:
  /// **'Günde {amount} harcayabilirsiniz.'**
  String spendingAdvisorSafe(Object amount);

  /// No description provided for @spendingAdvisorWarning.
  ///
  /// In tr, this message translates to:
  /// **'Limitinizde kalmak için günlük harcamayı {amount} azaltın.'**
  String spendingAdvisorWarning(Object amount);

  /// No description provided for @spendingAdvisorOnTrack.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Bütçenizle tam uyumlusunuz.'**
  String get spendingAdvisorOnTrack;

  /// No description provided for @spendingAdvisorOverBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçeyi aştınız. Harcamalarınızı durdurun.'**
  String get spendingAdvisorOverBudget;

  /// No description provided for @spendingAdvisorNoBudget.
  ///
  /// In tr, this message translates to:
  /// **'Tavsiye almak için bir bütçe belirleyin.'**
  String get spendingAdvisorNoBudget;

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mira'**
  String get appTitle;

  /// No description provided for @appearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim ayarları'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim tercihlerini yapılandırın'**
  String get notificationSettingsSubtitle;

  /// No description provided for @enableNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri Etkinleştir'**
  String get enableNotifications;

  /// No description provided for @notificationsMasterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm uygulama bildirimlerini kontrol et'**
  String get notificationsMasterSubtitle;

  /// No description provided for @notificationTypes.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Türleri'**
  String get notificationTypes;

  /// No description provided for @habitReminders.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Hatırlatıcıları'**
  String get habitReminders;

  /// No description provided for @habitRemindersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklarınız için günlük hatırlatıcılar'**
  String get habitRemindersSubtitle;

  /// No description provided for @notificationBehavior.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Davranışı'**
  String get notificationBehavior;

  /// No description provided for @sound.
  ///
  /// In tr, this message translates to:
  /// **'Ses'**
  String get sound;

  /// No description provided for @soundSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlerle birlikte ses çal'**
  String get soundSubtitle;

  /// No description provided for @vibration.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlerle birlikte titreşim'**
  String get vibrationSubtitle;

  /// No description provided for @systemInfo.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Bilgisi'**
  String get systemInfo;

  /// No description provided for @timezone.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Dilimi'**
  String get timezone;

  /// No description provided for @notificationPermission.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim İzni'**
  String get notificationPermission;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In tr, this message translates to:
  /// **'Kesin Alarm İzni (Android 12+)'**
  String get exactAlarmPermission;

  /// No description provided for @granted.
  ///
  /// In tr, this message translates to:
  /// **'Verildi'**
  String get granted;

  /// No description provided for @notGranted.
  ///
  /// In tr, this message translates to:
  /// **'Verilmedi'**
  String get notGranted;

  /// No description provided for @importantNotice.
  ///
  /// In tr, this message translates to:
  /// **'Önemli Uyarı'**
  String get importantNotice;

  /// No description provided for @notificationTroubleshooting.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlerin düzgün çalışması için:\n\n• Pil optimizasyonunu KAPATIN (Ayarlar → Uygulamalar → Mira → Pil → Sınırsız)\n• Arka planda çalışmaya İZİN VERİN\n• Bildirim izinlerinin AÇIK olduğundan emin olun\n• \'Rahatsız etmeyin\' modunu kontrol edin'**
  String get notificationTroubleshooting;

  /// No description provided for @approxVisionDurationDays.
  ///
  /// In tr, this message translates to:
  /// **'Bu vizyon yaklaşık {days} gün sürer'**
  String approxVisionDurationDays(Object days);

  /// No description provided for @assetsReloadHint.
  ///
  /// In tr, this message translates to:
  /// **'Bazı varlıkların yüklenmesi için uygulamanın tamamen yeniden başlatılması gerekebilir.'**
  String get assetsReloadHint;

  /// No description provided for @atLeast.
  ///
  /// In tr, this message translates to:
  /// **'En Az'**
  String get atLeast;

  /// No description provided for @atMost.
  ///
  /// In tr, this message translates to:
  /// **'En Çok'**
  String get atMost;

  /// No description provided for @backgroundPlate.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan plakası'**
  String get backgroundPlate;

  /// No description provided for @badgeActive100dDesc.
  ///
  /// In tr, this message translates to:
  /// **'100 farklı günde aktif ol'**
  String get badgeActive100dDesc;

  /// No description provided for @badgeActive100dTitle.
  ///
  /// In tr, this message translates to:
  /// **'100 Gün Aktif'**
  String get badgeActive100dTitle;

  /// No description provided for @badgeActive30dDesc.
  ///
  /// In tr, this message translates to:
  /// **'30 farklı günde aktif ol'**
  String get badgeActive30dDesc;

  /// No description provided for @badgeActive30dTitle.
  ///
  /// In tr, this message translates to:
  /// **'30 Gün Aktif'**
  String get badgeActive30dTitle;

  /// No description provided for @badgeActive7dDesc.
  ///
  /// In tr, this message translates to:
  /// **'7 farklı günde aktif ol'**
  String get badgeActive7dDesc;

  /// No description provided for @badgeActive7dTitle.
  ///
  /// In tr, this message translates to:
  /// **'7 Gün Aktif'**
  String get badgeActive7dTitle;

  /// No description provided for @badgeCategoryActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite'**
  String get badgeCategoryActivity;

  /// No description provided for @badgeCategoryFinance.
  ///
  /// In tr, this message translates to:
  /// **'Finans'**
  String get badgeCategoryFinance;

  /// No description provided for @badgeCategoryHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık'**
  String get badgeCategoryHabit;

  /// No description provided for @badgeCategoryLevel.
  ///
  /// In tr, this message translates to:
  /// **'Seviye'**
  String get badgeCategoryLevel;

  /// No description provided for @badgeCategoryVision.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon'**
  String get badgeCategoryVision;

  /// No description provided for @badgeCategoryXp.
  ///
  /// In tr, this message translates to:
  /// **'XP'**
  String get badgeCategoryXp;

  /// No description provided for @badgeFin100Desc.
  ///
  /// In tr, this message translates to:
  /// **'100 işlem kaydet'**
  String get badgeFin100Desc;

  /// No description provided for @badgeFin100Title.
  ///
  /// In tr, this message translates to:
  /// **'Finansçı 100'**
  String get badgeFin100Title;

  /// No description provided for @badgeFin10Desc.
  ///
  /// In tr, this message translates to:
  /// **'10 işlem kaydet'**
  String get badgeFin10Desc;

  /// No description provided for @badgeFin10Title.
  ///
  /// In tr, this message translates to:
  /// **'Finansçı 10'**
  String get badgeFin10Title;

  /// No description provided for @badgeFin250Desc.
  ///
  /// In tr, this message translates to:
  /// **'250 işlem kaydet'**
  String get badgeFin250Desc;

  /// No description provided for @badgeFin250Title.
  ///
  /// In tr, this message translates to:
  /// **'Finansçı 250'**
  String get badgeFin250Title;

  /// No description provided for @badgeFin50Desc.
  ///
  /// In tr, this message translates to:
  /// **'50 işlem kaydet'**
  String get badgeFin50Desc;

  /// No description provided for @badgeFin50Title.
  ///
  /// In tr, this message translates to:
  /// **'Finansçı 50'**
  String get badgeFin50Title;

  /// No description provided for @badgeHabit100Desc.
  ///
  /// In tr, this message translates to:
  /// **'Toplamda 100 alışkanlık tamamla'**
  String get badgeHabit100Desc;

  /// No description provided for @badgeHabit100Title.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık 100'**
  String get badgeHabit100Title;

  /// No description provided for @badgeHabit10Desc.
  ///
  /// In tr, this message translates to:
  /// **'Toplamda 10 alışkanlık tamamla'**
  String get badgeHabit10Desc;

  /// No description provided for @badgeHabit10Title.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık 10'**
  String get badgeHabit10Title;

  /// No description provided for @badgeHabit200Desc.
  ///
  /// In tr, this message translates to:
  /// **'Toplamda 200 alışkanlık tamamla'**
  String get badgeHabit200Desc;

  /// No description provided for @badgeHabit200Title.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık 200'**
  String get badgeHabit200Title;

  /// No description provided for @badgeHabit50Desc.
  ///
  /// In tr, this message translates to:
  /// **'Toplamda 50 alışkanlık tamamla'**
  String get badgeHabit50Desc;

  /// No description provided for @badgeHabit50Title.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık 50'**
  String get badgeHabit50Title;

  /// No description provided for @badgeLevel10Desc.
  ///
  /// In tr, this message translates to:
  /// **'10. seviyeye ulaş'**
  String get badgeLevel10Desc;

  /// No description provided for @badgeLevel10Title.
  ///
  /// In tr, this message translates to:
  /// **'Seviye 10'**
  String get badgeLevel10Title;

  /// No description provided for @badgeLevel20Desc.
  ///
  /// In tr, this message translates to:
  /// **'20. seviyeye ulaş'**
  String get badgeLevel20Desc;

  /// No description provided for @badgeLevel20Title.
  ///
  /// In tr, this message translates to:
  /// **'Seviye 20'**
  String get badgeLevel20Title;

  /// No description provided for @badgeLevel5Desc.
  ///
  /// In tr, this message translates to:
  /// **'5. seviyeye ulaş'**
  String get badgeLevel5Desc;

  /// No description provided for @badgeLevel5Title.
  ///
  /// In tr, this message translates to:
  /// **'Seviye 5'**
  String get badgeLevel5Title;

  /// No description provided for @badgeVision10Desc.
  ///
  /// In tr, this message translates to:
  /// **'10 vizyon oluştur'**
  String get badgeVision10Desc;

  /// No description provided for @badgeVision10Title.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon Büyükustası'**
  String get badgeVision10Title;

  /// No description provided for @badgeVision1Desc.
  ///
  /// In tr, this message translates to:
  /// **'İlk vizyonunu oluştur'**
  String get badgeVision1Desc;

  /// No description provided for @badgeVision1Title.
  ///
  /// In tr, this message translates to:
  /// **'Vizyoner'**
  String get badgeVision1Title;

  /// No description provided for @badgeVision5Desc.
  ///
  /// In tr, this message translates to:
  /// **'5 vizyon oluştur'**
  String get badgeVision5Desc;

  /// No description provided for @badgeVision5Title.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon Ustası'**
  String get badgeVision5Title;

  /// No description provided for @badgeVisionHabits3Desc.
  ///
  /// In tr, this message translates to:
  /// **'Bir vizyona 3+ alışkanlık bağla'**
  String get badgeVisionHabits3Desc;

  /// No description provided for @badgeVisionHabits3Title.
  ///
  /// In tr, this message translates to:
  /// **'Bağlayıcı'**
  String get badgeVisionHabits3Title;

  /// No description provided for @badgeXp1000Desc.
  ///
  /// In tr, this message translates to:
  /// **'Toplam 1000 XP kazan'**
  String get badgeXp1000Desc;

  /// No description provided for @badgeXp1000Title.
  ///
  /// In tr, this message translates to:
  /// **'1000 XP'**
  String get badgeXp1000Title;

  /// No description provided for @badgeXp500Desc.
  ///
  /// In tr, this message translates to:
  /// **'Toplam 500 XP kazan'**
  String get badgeXp500Desc;

  /// No description provided for @badgeXp500Title.
  ///
  /// In tr, this message translates to:
  /// **'500 XP'**
  String get badgeXp500Title;

  /// No description provided for @between1And360.
  ///
  /// In tr, this message translates to:
  /// **'1 ile 360 arasında'**
  String get between1And360;

  /// No description provided for @bio.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In tr, this message translates to:
  /// **'Kendiniz hakkında kısa bir biyografi'**
  String get bioHint;

  /// No description provided for @breakTime.
  ///
  /// In tr, this message translates to:
  /// **'Mola'**
  String get breakTime;

  /// No description provided for @breakdownByCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriye göre döküm'**
  String get breakdownByCategory;

  /// No description provided for @bringForward.
  ///
  /// In tr, this message translates to:
  /// **'Öne getir'**
  String get bringForward;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @categoryName.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Adı'**
  String get categoryName;

  /// No description provided for @chooseBestCategory.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığınız için en iyi kategoriyi seçin'**
  String get chooseBestCategory;

  /// No description provided for @chooseColor.
  ///
  /// In tr, this message translates to:
  /// **'Renk Seç:'**
  String get chooseColor;

  /// No description provided for @chooseEmoji.
  ///
  /// In tr, this message translates to:
  /// **'Emoji Seç:'**
  String get chooseEmoji;

  /// No description provided for @clearHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişi Temizle'**
  String get clearHistory;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @colorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Renk'**
  String get colorLabel;

  /// No description provided for @colorTheme.
  ///
  /// In tr, this message translates to:
  /// **'Renk teması'**
  String get colorTheme;

  /// No description provided for @countdownConfigureTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri Sayımı Yapılandır'**
  String get countdownConfigureTitle;

  /// No description provided for @create.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get create;

  /// No description provided for @createAdvancedHabit.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Alışkanlık Oluştur'**
  String get createAdvancedHabit;

  /// No description provided for @createDailyTask.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Görev Oluştur'**
  String get createDailyTask;

  /// No description provided for @createHabitTemplateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Şablonu Oluştur'**
  String get createHabitTemplateTitle;

  /// No description provided for @createList.
  ///
  /// In tr, this message translates to:
  /// **'Liste Oluştur'**
  String get createList;

  /// No description provided for @createNewCategory.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori Oluştur'**
  String get createNewCategory;

  /// No description provided for @createVision.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon Oluştur'**
  String get createVision;

  /// No description provided for @createVisionTemplateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon Şablonu Oluştur'**
  String get createVisionTemplateTitle;

  /// No description provided for @customCategories.
  ///
  /// In tr, this message translates to:
  /// **'Özel Kategoriler'**
  String get customCategories;

  /// No description provided for @customEmojiHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: ✨'**
  String get customEmojiHint;

  /// No description provided for @customEmojiOptional.
  ///
  /// In tr, this message translates to:
  /// **'Özel emoji (isteğe bağlı)'**
  String get customEmojiOptional;

  /// No description provided for @reminder.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı'**
  String get reminder;

  /// No description provided for @enableReminder.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcıyı Etkinleştir'**
  String get enableReminder;

  /// No description provided for @selectTime.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Seç'**
  String get selectTime;

  /// No description provided for @customFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Özel'**
  String get customFrequency;

  /// No description provided for @daily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @dailyCheck.
  ///
  /// In tr, this message translates to:
  /// **'Günlük kontrol'**
  String get dailyCheck;

  /// No description provided for @dailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Günlük limit'**
  String get dailyLimit;

  /// No description provided for @dailyTask.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Görev'**
  String get dailyTask;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık tema'**
  String get darkTheme;

  /// No description provided for @dashboard.
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get dashboard;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @dayRangeShort.
  ///
  /// In tr, this message translates to:
  /// **'Gün {start}–{end}'**
  String dayRangeShort(Object end, Object start);

  /// No description provided for @dayShort.
  ///
  /// In tr, this message translates to:
  /// **'Gün {day}'**
  String dayShort(Object day);

  /// No description provided for @daysAverageShort.
  ///
  /// In tr, this message translates to:
  /// **'{days}g ort.'**
  String daysAverageShort(Object days);

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @deleteCategoryConfirmNamed.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" kategorisini sil?'**
  String deleteCategoryConfirmNamed(Object name);

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi sil'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCustomCategoryConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu özel kategoriyi sil?'**
  String get deleteCustomCategoryConfirm;

  /// No description provided for @deleteEntryConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu kaydı silmek istediğinden emin misin?'**
  String get deleteEntryConfirm;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" kaydını sil?'**
  String deleteTransactionConfirm(Object title);

  /// No description provided for @deleteVisionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu vizyonu sil?'**
  String get deleteVisionMessage;

  /// No description provided for @deleteVisionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonu sil'**
  String get deleteVisionTitle;

  /// No description provided for @descHint.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığınızla ilgili ayrıntılar (isteğe bağlı)'**
  String get descHint;

  /// No description provided for @difficulty.
  ///
  /// In tr, this message translates to:
  /// **'Zorluk Seviyesi'**
  String get difficulty;

  /// No description provided for @duration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get duration;

  /// No description provided for @durationAutoLabel.
  ///
  /// In tr, this message translates to:
  /// **'Süre (otomatik)'**
  String get durationAutoLabel;

  /// No description provided for @durationSelection.
  ///
  /// In tr, this message translates to:
  /// **'Süre seçimi'**
  String get durationSelection;

  /// No description provided for @durationType.
  ///
  /// In tr, this message translates to:
  /// **'Süre Tipi'**
  String get durationType;

  /// No description provided for @earthTheme.
  ///
  /// In tr, this message translates to:
  /// **'Toprak'**
  String get earthTheme;

  /// No description provided for @earthThemeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Toprak renkleri'**
  String get earthThemeDesc;

  /// No description provided for @easy.
  ///
  /// In tr, this message translates to:
  /// **'Kolay'**
  String get easy;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @editCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi Düzenle'**
  String get editCategory;

  /// No description provided for @editHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığı Düzenle'**
  String get editHabit;

  /// No description provided for @education.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim'**
  String get education;

  /// No description provided for @emojiLabel.
  ///
  /// In tr, this message translates to:
  /// **'Emoji'**
  String get emojiLabel;

  /// No description provided for @endDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Tarihi'**
  String get endDate;

  /// No description provided for @endDayOptionalLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş günü (isteğe bağlı)'**
  String get endDayOptionalLabel;

  /// No description provided for @enterMonthlyPlanToComputeDailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Günlük bir limit hesaplamak için aylık bir plan girin.'**
  String get enterMonthlyPlanToComputeDailyLimit;

  /// No description provided for @enterNameAndDesc.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığınızın adını ve açıklamasını girin'**
  String get enterNameAndDesc;

  /// No description provided for @enterYourName.
  ///
  /// In tr, this message translates to:
  /// **'Adınızı girin'**
  String get enterYourName;

  /// No description provided for @entries.
  ///
  /// In tr, this message translates to:
  /// **'Girişler'**
  String get entries;

  /// No description provided for @everyNDaysQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Kaç günde bir?'**
  String get everyNDaysQuestion;

  /// No description provided for @everyday.
  ///
  /// In tr, this message translates to:
  /// **'Her Gün'**
  String get everyday;

  /// No description provided for @exact.
  ///
  /// In tr, this message translates to:
  /// **'Tam'**
  String get exact;

  /// No description provided for @examplePrefix.
  ///
  /// In tr, this message translates to:
  /// **'Örnek: {example}'**
  String examplePrefix(Object example);

  /// No description provided for @expenseDelta.
  ///
  /// In tr, this message translates to:
  /// **'Gider Δ'**
  String get expenseDelta;

  /// No description provided for @expenseDistributionPie.
  ///
  /// In tr, this message translates to:
  /// **'Gider dağılımı (pasta)'**
  String get expenseDistributionPie;

  /// No description provided for @expenseEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gideri Düzenle'**
  String get expenseEditTitle;

  /// No description provided for @expenseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get expenseLabel;

  /// No description provided for @expenseNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Gider'**
  String get expenseNewTitle;

  /// No description provided for @failedToLoad.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi: {error}'**
  String failedToLoad(Object error);

  /// No description provided for @filterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filterTitle;

  /// No description provided for @finance.
  ///
  /// In tr, this message translates to:
  /// **'Finans'**
  String get finance;

  /// No description provided for @financeAnalysisTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finans Analizi · {month}'**
  String financeAnalysisTitle(Object month);

  /// No description provided for @financeLast7Days.
  ///
  /// In tr, this message translates to:
  /// **'Finans · Son 7 gün'**
  String get financeLast7Days;

  /// No description provided for @finish.
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get finish;

  /// No description provided for @historyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get historyTitle;

  /// No description provided for @fitness.
  ///
  /// In tr, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @fixedDuration.
  ///
  /// In tr, this message translates to:
  /// **'Sabit'**
  String get fixedDuration;

  /// No description provided for @font.
  ///
  /// In tr, this message translates to:
  /// **'Yazı Tipi'**
  String get font;

  /// No description provided for @forestTheme.
  ///
  /// In tr, this message translates to:
  /// **'Orman'**
  String get forestTheme;

  /// No description provided for @forestThemeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Doğal yeşil tema'**
  String get forestThemeDesc;

  /// No description provided for @forever.
  ///
  /// In tr, this message translates to:
  /// **'Sonsuza kadar'**
  String get forever;

  /// No description provided for @frequency.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık'**
  String get frequency;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'Tam Ad'**
  String get fullName;

  /// No description provided for @fullScreen.
  ///
  /// In tr, this message translates to:
  /// **'Tam ekran'**
  String get fullScreen;

  /// No description provided for @gallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @general.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get general;

  /// No description provided for @generalNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Genel bildirimler'**
  String get generalNotifications;

  /// No description provided for @glasses.
  ///
  /// In tr, this message translates to:
  /// **'Bardak'**
  String get glasses;

  /// No description provided for @goldenTheme.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get goldenTheme;

  /// No description provided for @goldenThemeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak altın tema'**
  String get goldenThemeDesc;

  /// No description provided for @greetingAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'Tünaydın'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi akşamlar'**
  String get greetingEvening;

  /// No description provided for @greetingMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get greetingMorning;

  /// No description provided for @habit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık'**
  String get habit;

  /// No description provided for @habitDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get habitDescription;

  /// No description provided for @habitDetails.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Detayları'**
  String get habitDetails;

  /// No description provided for @habitName.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Adı'**
  String get habitName;

  /// No description provided for @habitOfThisVision.
  ///
  /// In tr, this message translates to:
  /// **'Bu vizyonun alışkanlığı'**
  String get habitOfThisVision;

  /// No description provided for @habits.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklar'**
  String get habits;

  /// No description provided for @hard.
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get hard;

  /// No description provided for @headerFocusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Odak'**
  String get headerFocusLabel;

  /// No description provided for @headerFocusReady.
  ///
  /// In tr, this message translates to:
  /// **'Hazır'**
  String get headerFocusReady;

  /// No description provided for @headerHabitsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık'**
  String get headerHabitsLabel;

  /// No description provided for @health.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get health;

  /// No description provided for @hours.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get hours;

  /// No description provided for @howOftenDoHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığınızı ne sıklıkla yapacağınıza karar verin'**
  String get howOftenDoHabit;

  /// No description provided for @howToEarn.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl kazanılır'**
  String get howToEarn;

  /// No description provided for @howToTrackHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığınızın nasıl izleneceğini seçin'**
  String get howToTrackHabit;

  /// No description provided for @ifCondition.
  ///
  /// In tr, this message translates to:
  /// **'Eğer'**
  String get ifCondition;

  /// No description provided for @importFromLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıdan içe aktar'**
  String get importFromLink;

  /// No description provided for @incomeDelta.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Δ'**
  String get incomeDelta;

  /// No description provided for @incomeEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geliri Düzenle'**
  String get incomeEditTitle;

  /// No description provided for @incomeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get incomeLabel;

  /// No description provided for @incomeNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Gelir'**
  String get incomeNewTitle;

  /// No description provided for @input.
  ///
  /// In tr, this message translates to:
  /// **'Giriş'**
  String get input;

  /// No description provided for @invalidLink.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz bağlantı.'**
  String get invalidLink;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageSelection.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçimi'**
  String get languageSelection;

  /// No description provided for @levelLabel.
  ///
  /// In tr, this message translates to:
  /// **'Seviye {level}'**
  String levelLabel(Object level);

  /// No description provided for @levelShort.
  ///
  /// In tr, this message translates to:
  /// **'S{level}'**
  String levelShort(Object level);

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık tema'**
  String get lightTheme;

  /// No description provided for @linkHabits.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıkları bağla'**
  String get linkHabits;

  /// No description provided for @listLabel.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get listLabel;

  /// No description provided for @loadingHabits.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklar yükleniyor...'**
  String get loadingHabits;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get logout;

  /// No description provided for @manageLists.
  ///
  /// In tr, this message translates to:
  /// **'Listeleri yönet'**
  String get manageLists;

  /// No description provided for @medium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get medium;

  /// No description provided for @mindfulness.
  ///
  /// In tr, this message translates to:
  /// **'Farkındalık'**
  String get mindfulness;

  /// No description provided for @minutes.
  ///
  /// In tr, this message translates to:
  /// **'Dakika'**
  String get minutes;

  /// No description provided for @minutesSuffixShort.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minutesSuffixShort;

  /// No description provided for @monthCount.
  ///
  /// In tr, this message translates to:
  /// **'Ay sayısı'**
  String get monthCount;

  /// No description provided for @monthCountHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: 12'**
  String get monthCountHint;

  /// No description provided for @monthSuffixShort.
  ///
  /// In tr, this message translates to:
  /// **'ay'**
  String get monthSuffixShort;

  /// No description provided for @monthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get monthly;

  /// No description provided for @monthlyTrend.
  ///
  /// In tr, this message translates to:
  /// **'Aylık trend'**
  String get monthlyTrend;

  /// No description provided for @mood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali'**
  String get mood;

  /// No description provided for @moodBad.
  ///
  /// In tr, this message translates to:
  /// **'Kötü'**
  String get moodBad;

  /// No description provided for @moodGood.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get moodGood;

  /// No description provided for @moodGreat.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get moodGreat;

  /// No description provided for @moodOk.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get moodOk;

  /// No description provided for @moodTerrible.
  ///
  /// In tr, this message translates to:
  /// **'Berbat'**
  String get moodTerrible;

  /// No description provided for @mtdAverageShort.
  ///
  /// In tr, this message translates to:
  /// **'AYB ort.'**
  String get mtdAverageShort;

  /// No description provided for @multiple.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu'**
  String get multiple;

  /// No description provided for @mysticTheme.
  ///
  /// In tr, this message translates to:
  /// **'Mistik'**
  String get mysticTheme;

  /// No description provided for @mysticThemeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Mistik mor tema'**
  String get mysticThemeDesc;

  /// No description provided for @nDaysLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String nDaysLabel(Object count);

  /// No description provided for @nameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Günlük antrenman'**
  String get nameHint;

  /// No description provided for @newCategory.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kategori'**
  String get newCategory;

  /// No description provided for @newHabits.
  ///
  /// In tr, this message translates to:
  /// **'Yeni alışkanlıklar'**
  String get newHabits;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @nextLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki'**
  String get nextLabel;

  /// No description provided for @nextYear.
  ///
  /// In tr, this message translates to:
  /// **'Gelecek yıl'**
  String get nextYear;

  /// No description provided for @noDataLast7Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 gün için veri yok'**
  String get noDataLast7Days;

  /// No description provided for @noDataThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için veri yok'**
  String get noDataThisMonth;

  /// No description provided for @noEndDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihi yok'**
  String get noEndDate;

  /// No description provided for @noEndDayDefaultsDaily.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş günü belirlenmediğinde, bu alışkanlık varsayılan olarak her gün görünecektir.'**
  String get noEndDayDefaultsDaily;

  /// No description provided for @noEntriesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz giriş yok'**
  String get noEntriesYet;

  /// No description provided for @noExpenseInThisCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride hiç harcama yok'**
  String get noExpenseInThisCategory;

  /// No description provided for @noExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Harcama yok'**
  String get noExpenses;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay hiç harcama yok'**
  String get noExpensesThisMonth;

  /// No description provided for @noHabitsAddedYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz alışkanlık eklenmedi.'**
  String get noHabitsAddedYet;

  /// No description provided for @noIncomeThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay hiç gelir yok'**
  String get noIncomeThisMonth;

  /// No description provided for @noLinkedHabitsInVision.
  ///
  /// In tr, this message translates to:
  /// **'Bu vizyona bağlı alışkanlık yok.'**
  String get noLinkedHabitsInVision;

  /// No description provided for @noReadyVisionsFound.
  ///
  /// In tr, this message translates to:
  /// **'Hazır vizyon bulunamadı.'**
  String get noReadyVisionsFound;

  /// No description provided for @noRecordsThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için kayıt yok'**
  String get noRecordsThisMonth;

  /// No description provided for @notAddedYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz eklenmedi.'**
  String get notAddedYet;

  /// No description provided for @notUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilidi açılmadı'**
  String get notUnlocked;

  /// No description provided for @noteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı)'**
  String get noteOptional;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @numberLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sayı'**
  String get numberLabel;

  /// No description provided for @numericExample.
  ///
  /// In tr, this message translates to:
  /// **'Günde 8 bardak su iç'**
  String get numericExample;

  /// No description provided for @numericSettings.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal Hedef Ayarları'**
  String get numericSettings;

  /// No description provided for @numericalDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal hedef takibi'**
  String get numericalDescription;

  /// No description provided for @numericalGoalShort.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal hedef'**
  String get numericalGoalShort;

  /// No description provided for @numericalType.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal Değer'**
  String get numericalType;

  /// No description provided for @oceanTheme.
  ///
  /// In tr, this message translates to:
  /// **'Okyanus'**
  String get oceanTheme;

  /// No description provided for @oceanThemeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sakin mavi tema'**
  String get oceanThemeDesc;

  /// No description provided for @onDailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Günlük limitinizdesiniz.'**
  String get onDailyLimit;

  /// No description provided for @onPeriodic.
  ///
  /// In tr, this message translates to:
  /// **'Belirli aralıklarla'**
  String get onPeriodic;

  /// No description provided for @onSpecificMonthDays.
  ///
  /// In tr, this message translates to:
  /// **'Ayın belirli günlerinde'**
  String get onSpecificMonthDays;

  /// No description provided for @onSpecificWeekdays.
  ///
  /// In tr, this message translates to:
  /// **'Haftanın belirli günlerinde'**
  String get onSpecificWeekdays;

  /// No description provided for @onSpecificYearDays.
  ///
  /// In tr, this message translates to:
  /// **'Yılın belirli günlerinde'**
  String get onSpecificYearDays;

  /// No description provided for @once.
  ///
  /// In tr, this message translates to:
  /// **'Bir kez'**
  String get once;

  /// No description provided for @other.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get other;

  /// No description provided for @outline.
  ///
  /// In tr, this message translates to:
  /// **'Anahat'**
  String get outline;

  /// No description provided for @outlineColor.
  ///
  /// In tr, this message translates to:
  /// **'Anahat rengi'**
  String get outlineColor;

  /// No description provided for @pages.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa'**
  String get pages;

  /// No description provided for @pause.
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get pause;

  /// No description provided for @periodicSelection.
  ///
  /// In tr, this message translates to:
  /// **'Periyodik Seçim'**
  String get periodicSelection;

  /// No description provided for @pickTodaysMood.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün ruh halini seç'**
  String get pickTodaysMood;

  /// No description provided for @plannedMonthlySpend.
  ///
  /// In tr, this message translates to:
  /// **'Planlanan aylık harcama'**
  String get plannedMonthlySpend;

  /// No description provided for @plateColor.
  ///
  /// In tr, this message translates to:
  /// **'Plaka rengi'**
  String get plateColor;

  /// No description provided for @previous.
  ///
  /// In tr, this message translates to:
  /// **'Önceki'**
  String get previous;

  /// No description provided for @previousYear.
  ///
  /// In tr, this message translates to:
  /// **'Geçen yıl'**
  String get previousYear;

  /// No description provided for @privacySecurity.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve güvenlik'**
  String get privacySecurity;

  /// No description provided for @productivity.
  ///
  /// In tr, this message translates to:
  /// **'Üretkenlik'**
  String get productivity;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @profileInfo.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgileri'**
  String get profileInfo;

  /// No description provided for @profileUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi'**
  String get profileUpdated;

  /// No description provided for @readyVisionsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hazır vizyonlar yüklenemedi.'**
  String get readyVisionsLoadFailed;

  /// No description provided for @recurringMonthlyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen tarihte her ay otomatik olarak ekle'**
  String get recurringMonthlyDesc;

  /// No description provided for @recurringMonthlyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yinelenen (aylık)'**
  String get recurringMonthlyTitle;

  /// No description provided for @reload.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Yükle'**
  String get reload;

  /// No description provided for @remainingToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün kalan'**
  String get remainingToday;

  /// No description provided for @reminderFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Sıklığı'**
  String get reminderFrequency;

  /// No description provided for @reminderSettings.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı Ayarları'**
  String get reminderSettings;

  /// No description provided for @reminderTime.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Zamanı'**
  String get reminderTime;

  /// No description provided for @repeatEveryDay.
  ///
  /// In tr, this message translates to:
  /// **'Her gün tekrarlanır'**
  String get repeatEveryDay;

  /// No description provided for @repeatEveryNDays.
  ///
  /// In tr, this message translates to:
  /// **'Her N Günde Bir Tekrarla'**
  String get repeatEveryNDays;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get reset;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @ruleEnteredDurationAtLeast.
  ///
  /// In tr, this message translates to:
  /// **'Kural: Girilen süre ≥ {target}'**
  String ruleEnteredDurationAtLeast(Object target);

  /// No description provided for @ruleEnteredDurationAtMost.
  ///
  /// In tr, this message translates to:
  /// **'Kural: Girilen süre ≤ {target}'**
  String ruleEnteredDurationAtMost(Object target);

  /// No description provided for @ruleEnteredDurationExactly.
  ///
  /// In tr, this message translates to:
  /// **'Kural: Girilen süre = {target}'**
  String ruleEnteredDurationExactly(Object target);

  /// No description provided for @ruleEnteredValueAtLeast.
  ///
  /// In tr, this message translates to:
  /// **'Kural: Girilen değer ≥ {target}'**
  String ruleEnteredValueAtLeast(Object target);

  /// No description provided for @ruleEnteredValueAtMost.
  ///
  /// In tr, this message translates to:
  /// **'Kural: Girilen değer ≤ {target}'**
  String ruleEnteredValueAtMost(Object target);

  /// No description provided for @ruleEnteredValueExactly.
  ///
  /// In tr, this message translates to:
  /// **'Kural: Girilen değer = {target}'**
  String ruleEnteredValueExactly(Object target);

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get saved;

  /// No description provided for @savingsBudgetPlan.
  ///
  /// In tr, this message translates to:
  /// **'Tasarruf / Bütçe Planı'**
  String get savingsBudgetPlan;

  /// No description provided for @scheduleHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığınızın programını ayarlayın'**
  String get scheduleHabit;

  /// No description provided for @scheduleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Program'**
  String get scheduleLabel;

  /// No description provided for @schedulingOptions.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlama Seçenekleri'**
  String get schedulingOptions;

  /// No description provided for @seconds.
  ///
  /// In tr, this message translates to:
  /// **'Saniye'**
  String get seconds;

  /// No description provided for @select.
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Seç'**
  String get selectAll;

  /// No description provided for @selectCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seç'**
  String get selectCategory;

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seç'**
  String get selectDate;

  /// No description provided for @selectEndDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihini seç'**
  String get selectEndDate;

  /// No description provided for @selectFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık Seç'**
  String get selectFrequency;

  /// No description provided for @selectHabitType.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Türü Seç'**
  String get selectHabitType;

  /// No description provided for @sendBackward.
  ///
  /// In tr, this message translates to:
  /// **'Geriye gönder'**
  String get sendBackward;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @shareAsLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı olarak paylaş'**
  String get shareAsLink;

  /// No description provided for @shareLinkCopied.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım bağlantısı panoya kopyalandı.'**
  String get shareLinkCopied;

  /// No description provided for @shareVision.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonu paylaş'**
  String get shareVision;

  /// No description provided for @social.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal'**
  String get social;

  /// No description provided for @soundAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Sesli uyarılar'**
  String get soundAlerts;

  /// No description provided for @specificDaysOfMonth.
  ///
  /// In tr, this message translates to:
  /// **'Ayın Belirli Günleri'**
  String get specificDaysOfMonth;

  /// No description provided for @specificDaysOfWeek.
  ///
  /// In tr, this message translates to:
  /// **'Haftanın Belirli Günleri'**
  String get specificDaysOfWeek;

  /// No description provided for @specificDaysOfYear.
  ///
  /// In tr, this message translates to:
  /// **'Yılın Belirli Günleri'**
  String get specificDaysOfYear;

  /// No description provided for @spendingLessThanDailyAvg.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Günlük ortalamadan {amount} daha az harcıyorsunuz.'**
  String spendingLessThanDailyAvg(Object amount);

  /// No description provided for @spendingMoreThanDailyAvg.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı! Günlük ortalamadan {amount} daha fazla harcıyorsunuz.'**
  String spendingMoreThanDailyAvg(Object amount);

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başlat'**
  String get start;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Tarihi'**
  String get startDate;

  /// No description provided for @startDayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç günü (1-365)'**
  String get startDayLabel;

  /// No description provided for @statusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get statusLabel;

  /// No description provided for @step.
  ///
  /// In tr, this message translates to:
  /// **'Adım'**
  String get step;

  /// No description provided for @stepOf.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String stepOf(Object current, Object total);

  /// No description provided for @steps.
  ///
  /// In tr, this message translates to:
  /// **'Adımlar'**
  String get steps;

  /// No description provided for @streakDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} Günlük Seri'**
  String streakDays(Object count);

  /// No description provided for @streakIndicator.
  ///
  /// In tr, this message translates to:
  /// **'Seri göstergesi'**
  String get streakIndicator;

  /// No description provided for @streakIndicatorDesc.
  ///
  /// In tr, this message translates to:
  /// **'Alev ve buz efektlerini göster'**
  String get streakIndicatorDesc;

  /// No description provided for @successfulDaysCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Başarılı Gün'**
  String successfulDaysCount(Object count);

  /// No description provided for @systemTheme.
  ///
  /// In tr, this message translates to:
  /// **'Sistem teması'**
  String get systemTheme;

  /// No description provided for @targetDurationMinutes.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Süre (dakika)'**
  String get targetDurationMinutes;

  /// No description provided for @targetShort.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {value}'**
  String targetShort(Object value);

  /// No description provided for @targetType.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tipi'**
  String get targetType;

  /// No description provided for @targetValue.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Değer'**
  String get targetValue;

  /// No description provided for @targetValueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Değer'**
  String get targetValueLabel;

  /// No description provided for @taskDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (İsteğe Bağlı)'**
  String get taskDescription;

  /// No description provided for @taskTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görev Başlığı'**
  String get taskTitle;

  /// No description provided for @templateDetailsNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Şablon ayrıntıları bulunamadı'**
  String get templateDetailsNotFound;

  /// No description provided for @templatesTabManual.
  ///
  /// In tr, this message translates to:
  /// **'Manuel'**
  String get templatesTabManual;

  /// No description provided for @templatesTabReady.
  ///
  /// In tr, this message translates to:
  /// **'Hazır'**
  String get templatesTabReady;

  /// No description provided for @enterPromoCode.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir promosyon kodu girin'**
  String get enterPromoCode;

  /// No description provided for @promoCodeSuccess.
  ///
  /// In tr, this message translates to:
  /// **'🎉 Promosyon kodu başarıyla uygulandı! Premium erişiminiz aktifleştirildi.'**
  String get promoCodeSuccess;

  /// No description provided for @promoCodeAlreadyUsed.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesapta daha önce bir promosyon kodu kullanılmış.'**
  String get promoCodeAlreadyUsed;

  /// No description provided for @promoCodeInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz promosyon kodu. Lütfen kontrol edip tekrar deneyin.'**
  String get promoCodeInvalid;

  /// No description provided for @errorPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Hata: '**
  String get errorPrefix;

  /// No description provided for @promoCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Promosyon Kodu'**
  String get promoCodeLabel;

  /// No description provided for @promoCodeActiveMessage.
  ///
  /// In tr, this message translates to:
  /// **'Premium erişiminiz promosyon kodu ile aktifleştirildi ✨'**
  String get promoCodeActiveMessage;

  /// No description provided for @promoCodeHint.
  ///
  /// In tr, this message translates to:
  /// **'Promosyon kodunuzu girin'**
  String get promoCodeHint;

  /// No description provided for @applying.
  ///
  /// In tr, this message translates to:
  /// **'Uygulanıyor...'**
  String get applying;

  /// No description provided for @applyCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Uygula'**
  String get applyCode;

  /// No description provided for @visionSettingsTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Serbest pano ayarları'**
  String get visionSettingsTooltip;

  /// No description provided for @visionBoardViewTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Pano görünümü'**
  String get visionBoardViewTooltip;

  /// No description provided for @visionFreeformTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Serbest pano'**
  String get visionFreeformTooltip;

  /// No description provided for @filterTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filterTooltip;

  /// No description provided for @selectMonthTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Ay seç'**
  String get selectMonthTooltip;

  /// No description provided for @analysisTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get analysisTooltip;

  /// No description provided for @shareBoard.
  ///
  /// In tr, this message translates to:
  /// **'Panoyu paylaş'**
  String get shareBoard;

  /// No description provided for @roundCorners.
  ///
  /// In tr, this message translates to:
  /// **'Köşeleri yuvarlat'**
  String get roundCorners;

  /// No description provided for @showText.
  ///
  /// In tr, this message translates to:
  /// **'Yazıları göster'**
  String get showText;

  /// No description provided for @showProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemeyi göster'**
  String get showProgress;

  /// No description provided for @myBoard.
  ///
  /// In tr, this message translates to:
  /// **'Panom'**
  String get myBoard;

  /// No description provided for @textLabel.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get textLabel;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeDetails.
  ///
  /// In tr, this message translates to:
  /// **'Tema Detayları'**
  String get themeDetails;

  /// No description provided for @themeSelection.
  ///
  /// In tr, this message translates to:
  /// **'Tema Seçimi'**
  String get themeSelection;

  /// No description provided for @thisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay'**
  String get thisMonth;

  /// No description provided for @timerCreateTimerHabitFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce bir zamanlayıcı alışkanlığı oluşturun'**
  String get timerCreateTimerHabitFirst;

  /// No description provided for @timerDescription.
  ///
  /// In tr, this message translates to:
  /// **'Zaman tabanlı takip'**
  String get timerDescription;

  /// No description provided for @timerExample.
  ///
  /// In tr, this message translates to:
  /// **'30 dakikalık bir antrenman yap'**
  String get timerExample;

  /// No description provided for @timerHabitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlayıcı Alışkanlığı'**
  String get timerHabitLabel;

  /// No description provided for @timerPendingDurationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen süre: {duration}'**
  String timerPendingDurationLabel(Object duration);

  /// No description provided for @timerPendingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede: {duration}'**
  String timerPendingLabel(Object duration);

  /// No description provided for @timerPomodoroBreakPhase.
  ///
  /// In tr, this message translates to:
  /// **'Mola'**
  String get timerPomodoroBreakPhase;

  /// No description provided for @timerPomodoroCompletedWork.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan Çalışma: {count}'**
  String timerPomodoroCompletedWork(Object count);

  /// No description provided for @timerPomodoroLongBreakIntervalLabel.
  ///
  /// In tr, this message translates to:
  /// **'Uzun Mola Döngüsü (örn. 4)'**
  String get timerPomodoroLongBreakIntervalLabel;

  /// No description provided for @timerPomodoroLongBreakMinutesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Uzun Mola (dk)'**
  String get timerPomodoroLongBreakMinutesLabel;

  /// No description provided for @timerPomodoroSettings.
  ///
  /// In tr, this message translates to:
  /// **'Pomodoro Ayarları'**
  String get timerPomodoroSettings;

  /// No description provided for @timerPomodoroShortBreakMinutesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kısa Mola (dk)'**
  String get timerPomodoroShortBreakMinutesLabel;

  /// No description provided for @timerPomodoroSkipPhase.
  ///
  /// In tr, this message translates to:
  /// **'Aşamayı Atla'**
  String get timerPomodoroSkipPhase;

  /// No description provided for @timerPomodoroWorkMinutesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma (dk)'**
  String get timerPomodoroWorkMinutesLabel;

  /// No description provided for @timerPomodoroWorkPhase.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma'**
  String get timerPomodoroWorkPhase;

  /// No description provided for @timerSaveDurationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Süreyi Kaydet'**
  String get timerSaveDurationTitle;

  /// No description provided for @timerSaveSessionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu Kaydet'**
  String get timerSaveSessionTitle;

  /// No description provided for @timerQuickPresets.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Ayarlar'**
  String get timerQuickPresets;

  /// No description provided for @timerSessionAlreadySaved.
  ///
  /// In tr, this message translates to:
  /// **'Bu oturum zaten kaydedilmiş'**
  String get timerSessionAlreadySaved;

  /// No description provided for @totalDuration.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get totalDuration;

  /// No description provided for @timerSetDurationFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce süreyi ayarla'**
  String get timerSetDurationFirst;

  /// No description provided for @timerSettings.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlayıcı Ayarları'**
  String get timerSettings;

  /// No description provided for @timerTabCountdown.
  ///
  /// In tr, this message translates to:
  /// **'Geri Sayım'**
  String get timerTabCountdown;

  /// No description provided for @timerTabPomodoro.
  ///
  /// In tr, this message translates to:
  /// **'Pomodoro'**
  String get timerTabPomodoro;

  /// No description provided for @timerTabStopwatch.
  ///
  /// In tr, this message translates to:
  /// **'Kronometre'**
  String get timerTabStopwatch;

  /// No description provided for @timerType.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlayıcı'**
  String get timerType;

  /// No description provided for @checkboxType.
  ///
  /// In tr, this message translates to:
  /// **'Onay Kutusu'**
  String get checkboxType;

  /// No description provided for @subtasksType.
  ///
  /// In tr, this message translates to:
  /// **'Alt Görevler'**
  String get subtasksType;

  /// No description provided for @times.
  ///
  /// In tr, this message translates to:
  /// **'Kere'**
  String get times;

  /// No description provided for @titleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Market, Serbest Çalışma, vb.'**
  String get titleHint;

  /// No description provided for @titleOptional.
  ///
  /// In tr, this message translates to:
  /// **'Başlık (isteğe bağlı)'**
  String get titleOptional;

  /// No description provided for @typeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get typeLabel;

  /// No description provided for @unit.
  ///
  /// In tr, this message translates to:
  /// **'Birim'**
  String get unit;

  /// No description provided for @unitHint.
  ///
  /// In tr, this message translates to:
  /// **'Birim (bardak, adım, sayfa...)'**
  String get unitHint;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @vision.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon'**
  String get vision;

  /// No description provided for @visionAutoDurationInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bu vizyon şablondaki son günü kullanacak: {day}.'**
  String visionAutoDurationInfo(Object day);

  /// No description provided for @visionCreateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon Oluştur'**
  String get visionCreateTitle;

  /// No description provided for @visionDurationNote.
  ///
  /// In tr, this message translates to:
  /// **'Not: Vizyon başladığında toplam bir süre belirlenir; bitiş günü bu süreyi aşarsa otomatik olarak kısaltılır.'**
  String get visionDurationNote;

  /// No description provided for @visionEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonu Düzenle'**
  String get visionEditTitle;

  /// No description provided for @visionEndDayInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş günü 1 ile 365 arasında olmalıdır'**
  String get visionEndDayInvalid;

  /// No description provided for @visionEndDayLess.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş günü başlangıç gününden küçük olamaz'**
  String get visionEndDayLess;

  /// No description provided for @visionEndDayQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonun hangi gününde bitmeli?'**
  String get visionEndDayQuestion;

  /// No description provided for @visionEndDayRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş gününü girin'**
  String get visionEndDayRequired;

  /// No description provided for @visionNoEndDurationInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş günü belirtilmedi. Vizyon ucu açık başlayacak.'**
  String get visionNoEndDurationInfo;

  /// No description provided for @visionPlural.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonlar'**
  String get visionPlural;

  /// No description provided for @visionStartDayInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç günü 1 ile 365 arasında olmalıdır'**
  String get visionStartDayInvalid;

  /// No description provided for @visionStartDayQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonun hangi gününde başlamalı?'**
  String get visionStartDayQuestion;

  /// No description provided for @visionDurationDaysLabel.
  ///
  /// In tr, this message translates to:
  /// **'Süre (gün)'**
  String get visionDurationDaysLabel;

  /// No description provided for @visionStartFailed.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon başlatılamadı.'**
  String get visionStartFailed;

  /// No description provided for @visionStartedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon başladı: {title}'**
  String visionStartedMessage(Object title);

  /// No description provided for @visionStartLabel.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon başlangıcı: '**
  String get visionStartLabel;

  /// No description provided for @visual.
  ///
  /// In tr, this message translates to:
  /// **'Görsel'**
  String get visual;

  /// No description provided for @weekdaysShortFri.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get weekdaysShortFri;

  /// No description provided for @weekdaysShortMon.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get weekdaysShortMon;

  /// No description provided for @fortuneTitle.
  ///
  /// In tr, this message translates to:
  /// **'Karar Yumurtaları'**
  String get fortuneTitle;

  /// No description provided for @fortuneQuestionPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Aklındaki soruyu yaz'**
  String get fortuneQuestionPrompt;

  /// No description provided for @fortuneQuestionHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Bu hafta yeni bir şey denemeli miyim?'**
  String get fortuneQuestionHint;

  /// No description provided for @fortuneEggsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdan bir yumurta seç'**
  String get fortuneEggsSubtitle;

  /// No description provided for @fortuneResultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cevabın'**
  String get fortuneResultTitle;

  /// No description provided for @fortuneNoQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bir soru yazmadın'**
  String get fortuneNoQuestion;

  /// No description provided for @fortuneDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'Eğlence amaçlıdır.'**
  String get fortuneDisclaimer;

  /// No description provided for @fortuneEggSemantic.
  ///
  /// In tr, this message translates to:
  /// **'Yumurta {index}'**
  String fortuneEggSemantic(int index);

  /// No description provided for @fortunePlay.
  ///
  /// In tr, this message translates to:
  /// **'Karar Yumurtaları'**
  String get fortunePlay;

  /// No description provided for @shuffle.
  ///
  /// In tr, this message translates to:
  /// **'Karıştır'**
  String get shuffle;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @weekdaysShortSat.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get weekdaysShortSat;

  /// No description provided for @weekdaysShortSun.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get weekdaysShortSun;

  /// No description provided for @weekdaysShortThu.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get weekdaysShortThu;

  /// No description provided for @weekdaysShortTue.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get weekdaysShortTue;

  /// No description provided for @weekdaysShortWed.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get weekdaysShortWed;

  /// No description provided for @weekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get weekly;

  /// No description provided for @weeklyEmailSummary.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık e-posta özeti'**
  String get weeklyEmailSummary;

  /// No description provided for @weeklySummaryEmail.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık özet e-postası'**
  String get weeklySummaryEmail;

  /// No description provided for @whichDaysActive.
  ///
  /// In tr, this message translates to:
  /// **'Hangi günler aktif olmalı?'**
  String get whichDaysActive;

  /// No description provided for @whichMonthDays.
  ///
  /// In tr, this message translates to:
  /// **'Ayın hangi günleri?'**
  String get whichMonthDays;

  /// No description provided for @whichWeekdays.
  ///
  /// In tr, this message translates to:
  /// **'Hangi hafta günleri?'**
  String get whichWeekdays;

  /// No description provided for @worldTheme.
  ///
  /// In tr, this message translates to:
  /// **'Dünya'**
  String get worldTheme;

  /// No description provided for @worldThemeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm renklerin uyumu'**
  String get worldThemeDesc;

  /// No description provided for @xpProgressSummary.
  ///
  /// In tr, this message translates to:
  /// **'{current} / {total} XP • Sonraki seviye için {toNext} XP'**
  String xpProgressSummary(Object current, Object toNext, Object total);

  /// No description provided for @yesNoDescription.
  ///
  /// In tr, this message translates to:
  /// **'Basit evet/hayır takibi'**
  String get yesNoDescription;

  /// No description provided for @yesNoExample.
  ///
  /// In tr, this message translates to:
  /// **'Bugün meditasyon yaptım mı?'**
  String get yesNoExample;

  /// No description provided for @yesNoType.
  ///
  /// In tr, this message translates to:
  /// **'Evet/Hayır'**
  String get yesNoType;

  /// No description provided for @analysis.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get analysis;

  /// No description provided for @apply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  /// No description provided for @clearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get clearFilters;

  /// No description provided for @simpleTypeShort.
  ///
  /// In tr, this message translates to:
  /// **'Basit'**
  String get simpleTypeShort;

  /// No description provided for @completedSelectedDay.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı (seçilen gün)'**
  String get completedSelectedDay;

  /// No description provided for @incompleteSelectedDay.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanmadı (seçilen gün)'**
  String get incompleteSelectedDay;

  /// No description provided for @manageListsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni listeler ekleyin, adlarını değiştirin veya silin.'**
  String get manageListsSubtitle;

  /// No description provided for @editListTitle.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi Düzenle'**
  String get editListTitle;

  /// No description provided for @listNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Liste Adı'**
  String get listNameLabel;

  /// No description provided for @deleteListTitle.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi Sil'**
  String get deleteListTitle;

  /// No description provided for @deleteListMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu liste silinecek. Bağlı öğeler için işlemi seçin:'**
  String get deleteListMessage;

  /// No description provided for @unassignLinkedHabits.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı alışkanlıkların atamasını kaldır'**
  String get unassignLinkedHabits;

  /// No description provided for @unassignLinkedDailyTasks.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı günlük görevlerin atamasını kaldır'**
  String get unassignLinkedDailyTasks;

  /// No description provided for @listCreatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Liste oluşturuldu: {title}'**
  String listCreatedMessage(Object title);

  /// No description provided for @removeFromList.
  ///
  /// In tr, this message translates to:
  /// **'Listeden kaldır'**
  String get removeFromList;

  /// No description provided for @createNewList.
  ///
  /// In tr, this message translates to:
  /// **'Yeni liste oluştur'**
  String get createNewList;

  /// No description provided for @dailyTasksSection.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Görevler'**
  String get dailyTasksSection;

  /// No description provided for @addToList.
  ///
  /// In tr, this message translates to:
  /// **'Listeye ekle'**
  String get addToList;

  /// No description provided for @deleteTaskConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görev silinsin mi?'**
  String get deleteTaskConfirmTitle;

  /// No description provided for @deleteTaskConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu günlük görev silinsin mi? Bu işlem geri alınabilir.'**
  String get deleteTaskConfirmMessage;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @habitsSection.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklar'**
  String get habitsSection;

  /// No description provided for @noItemsMatchFilters.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen filtrelerle eşleşen öğe yok'**
  String get noItemsMatchFilters;

  /// No description provided for @dailyTaskCreatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük görev oluşturuldu: {title}'**
  String dailyTaskCreatedMessage(Object title);

  /// No description provided for @habitDeletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık silindi: {title}'**
  String habitDeletedMessage(Object title);

  /// No description provided for @habitCreatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık oluşturuldu: {title}'**
  String habitCreatedMessage(Object title);

  /// No description provided for @deleteHabitConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" alışkanlığı silinsin mi?'**
  String deleteHabitConfirm(Object title);

  /// No description provided for @enterValueTitle.
  ///
  /// In tr, this message translates to:
  /// **'Değer gir'**
  String get enterValueTitle;

  /// No description provided for @valueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Değer'**
  String get valueLabel;

  /// No description provided for @currentStreak.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Seri'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In tr, this message translates to:
  /// **'En uzun seri'**
  String get longestStreak;

  /// No description provided for @daysCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String daysCount(Object count);

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarı'**
  String get success;

  /// No description provided for @successfulDayLegend.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı gün'**
  String get successfulDayLegend;

  /// No description provided for @privacySecuritySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları ve veri silme seçeneklerini yönetin'**
  String get privacySecuritySubtitle;

  /// No description provided for @googleDrive.
  ///
  /// In tr, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @reportBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildir'**
  String get reportBug;

  /// No description provided for @reportBugSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştığınız sorunları bildirin'**
  String get reportBugSubtitle;

  /// No description provided for @reportBugDescription.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştığınız sorunu aşağıya detaylı olarak yazın.'**
  String get reportBugDescription;

  /// No description provided for @yourEmailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresiniz'**
  String get yourEmailAddress;

  /// No description provided for @issueDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sorun Açıklaması'**
  String get issueDescription;

  /// No description provided for @issueDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Sorunu detaylı olarak açıklayın...'**
  String get issueDescriptionHint;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm alanları doldurun'**
  String get pleaseFillAllFields;

  /// No description provided for @bugReportSentSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Hata raporunuz başarıyla gönderildi. Teşekkür ederiz!'**
  String get bugReportSentSuccess;

  /// No description provided for @bugReportFailedStatus.
  ///
  /// In tr, this message translates to:
  /// **'Hata raporu gönderilemedi: {statusCode}'**
  String bugReportFailedStatus(Object statusCode);

  /// No description provided for @bugReportFailedError.
  ///
  /// In tr, this message translates to:
  /// **'Hata raporu gönderilemedi: {error}'**
  String bugReportFailedError(Object error);

  /// No description provided for @resetOnboardingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tanıtımı Sıfırla?'**
  String get resetOnboardingTitle;

  /// No description provided for @resetOnboardingDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem mevcut kişilik testi sonuçlarınızı silecek ve testi tekrar yapmanızı sağlayacaktır.'**
  String get resetOnboardingDescription;

  /// No description provided for @resetAction.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get resetAction;

  /// No description provided for @deleteAllDataConfirmContent.
  ///
  /// In tr, this message translates to:
  /// **'Tüm uygulama verilerinizi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteAllDataConfirmContent;

  /// No description provided for @deleteAction.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get deleteAction;

  /// No description provided for @allDataDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler silindi'**
  String get allDataDeleted;

  /// No description provided for @diagnosticsData.
  ///
  /// In tr, this message translates to:
  /// **'Tanılama verileri'**
  String get diagnosticsData;

  /// No description provided for @diagnosticsDataSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama kullanımına dair anonim istatistikleri paylaş'**
  String get diagnosticsDataSubtitle;

  /// No description provided for @crashReports.
  ///
  /// In tr, this message translates to:
  /// **'Çökme raporları'**
  String get crashReports;

  /// No description provided for @crashReportsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama çökmelerinde anonim rapor gönder'**
  String get crashReportsSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @deleteAllData.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileri sil'**
  String get deleteAllData;

  /// No description provided for @stopwatchLabel.
  ///
  /// In tr, this message translates to:
  /// **'KRONOMETRE'**
  String get stopwatchLabel;

  /// No description provided for @runningLabel.
  ///
  /// In tr, this message translates to:
  /// **'ÇALIŞIYOR'**
  String get runningLabel;

  /// No description provided for @countdownLabel.
  ///
  /// In tr, this message translates to:
  /// **'GERİ SAYIM'**
  String get countdownLabel;

  /// No description provided for @focusLabel.
  ///
  /// In tr, this message translates to:
  /// **'ODAK'**
  String get focusLabel;

  /// No description provided for @breakLabel.
  ///
  /// In tr, this message translates to:
  /// **'MOLA'**
  String get breakLabel;

  /// No description provided for @minLabel.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minLabel;

  /// No description provided for @emojiCategoryPopular.
  ///
  /// In tr, this message translates to:
  /// **'Popüler'**
  String get emojiCategoryPopular;

  /// No description provided for @emojiCategoryHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get emojiCategoryHealth;

  /// No description provided for @emojiCategorySport.
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get emojiCategorySport;

  /// No description provided for @emojiCategoryLife.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam'**
  String get emojiCategoryLife;

  /// No description provided for @emojiCategoryProductivity.
  ///
  /// In tr, this message translates to:
  /// **'Üretkenlik'**
  String get emojiCategoryProductivity;

  /// No description provided for @emojiCategoryFood.
  ///
  /// In tr, this message translates to:
  /// **'Yiyecek'**
  String get emojiCategoryFood;

  /// No description provided for @emojiCategoryNature.
  ///
  /// In tr, this message translates to:
  /// **'Doğa'**
  String get emojiCategoryNature;

  /// No description provided for @emojiCategoryAnimals.
  ///
  /// In tr, this message translates to:
  /// **'Hayvanlar'**
  String get emojiCategoryAnimals;

  /// No description provided for @emojiCategoryCare.
  ///
  /// In tr, this message translates to:
  /// **'Bakım'**
  String get emojiCategoryCare;

  /// No description provided for @habitTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Tipi'**
  String get habitTypeLabel;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get nameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get descriptionLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In tr, this message translates to:
  /// **'opsiyonel'**
  String get optionalLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık'**
  String get frequencyLabel;

  /// No description provided for @dateRangeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Aralığı'**
  String get dateRangeLabel;

  /// No description provided for @reminderLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı'**
  String get reminderLabel;

  /// No description provided for @advancedHabitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Alışkanlık'**
  String get advancedHabitTitle;

  /// No description provided for @habitNamePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Adı'**
  String get habitNamePlaceholder;

  /// No description provided for @numericTypeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sayı takibi'**
  String get numericTypeDesc;

  /// No description provided for @checkboxTypeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Basit işaretle'**
  String get checkboxTypeDesc;

  /// No description provided for @subtasksTypeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu görev'**
  String get subtasksTypeDesc;

  /// No description provided for @selectEmoji.
  ///
  /// In tr, this message translates to:
  /// **'Emoji seç'**
  String get selectEmoji;

  /// No description provided for @customEmoji.
  ///
  /// In tr, this message translates to:
  /// **'Özel Emoji'**
  String get customEmoji;

  /// No description provided for @typeEmojiHint.
  ///
  /// In tr, this message translates to:
  /// **'Klavyeden bir emoji yazın'**
  String get typeEmojiHint;

  /// No description provided for @everyDay.
  ///
  /// In tr, this message translates to:
  /// **'Her gün'**
  String get everyDay;

  /// No description provided for @periodic.
  ///
  /// In tr, this message translates to:
  /// **'Periyodik'**
  String get periodic;

  /// No description provided for @everyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Her'**
  String get everyLabel;

  /// No description provided for @daysIntervalLabel.
  ///
  /// In tr, this message translates to:
  /// **'günde bir'**
  String get daysIntervalLabel;

  /// No description provided for @offLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get offLabel;

  /// No description provided for @completeAllSubtasksToFinish.
  ///
  /// In tr, this message translates to:
  /// **'tümünü tamamlayınca alışkanlık tamamlanır'**
  String get completeAllSubtasksToFinish;

  /// No description provided for @subtaskIndex.
  ///
  /// In tr, this message translates to:
  /// **'Alt görev {index}'**
  String subtaskIndex(Object index);

  /// No description provided for @addSubtask.
  ///
  /// In tr, this message translates to:
  /// **'Alt Görev Ekle'**
  String get addSubtask;

  /// No description provided for @saveChanges.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri Kaydet'**
  String get saveChanges;

  /// No description provided for @createHabitAction.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Oluştur'**
  String get createHabitAction;

  /// No description provided for @selectDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre Seç'**
  String get selectDuration;

  /// No description provided for @selectedDaysOfMonth.
  ///
  /// In tr, this message translates to:
  /// **'Ayın {sorted}. günleri'**
  String selectedDaysOfMonth(Object sorted);

  /// No description provided for @everyXDays.
  ///
  /// In tr, this message translates to:
  /// **'Her {periodicDays} günde bir'**
  String everyXDays(Object periodicDays);

  /// No description provided for @startDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get endDateLabel;

  /// No description provided for @notSelected.
  ///
  /// In tr, this message translates to:
  /// **'Seçilmedi'**
  String get notSelected;

  /// No description provided for @motivation.
  ///
  /// In tr, this message translates to:
  /// **'Motivasyon'**
  String get motivation;

  /// No description provided for @motivationBody.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler! {period} içinde başarı oranınız {percent}%. Harika bir ilerleme kaydettiniz.'**
  String motivationBody(Object percent, Object period);

  /// No description provided for @weeklyProgress.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık ilerleme'**
  String get weeklyProgress;

  /// No description provided for @monthlyProgress.
  ///
  /// In tr, this message translates to:
  /// **'Aylık ilerleme'**
  String get monthlyProgress;

  /// No description provided for @yearlyProgress.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık ilerleme'**
  String get yearlyProgress;

  /// No description provided for @overall.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get overall;

  /// No description provided for @overallProgress.
  ///
  /// In tr, this message translates to:
  /// **'Genel ilerleme'**
  String get overallProgress;

  /// No description provided for @totalSuccessfulDays.
  ///
  /// In tr, this message translates to:
  /// **'Toplam başarılı gün'**
  String get totalSuccessfulDays;

  /// No description provided for @totalUnsuccessfulDays.
  ///
  /// In tr, this message translates to:
  /// **'Toplam başarısız gün'**
  String get totalUnsuccessfulDays;

  /// No description provided for @totalProgress.
  ///
  /// In tr, this message translates to:
  /// **'Toplam ilerleme'**
  String get totalProgress;

  /// No description provided for @thisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta'**
  String get thisWeek;

  /// No description provided for @thisYear.
  ///
  /// In tr, this message translates to:
  /// **'Bu yıl'**
  String get thisYear;

  /// No description provided for @badges.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler'**
  String get badges;

  /// No description provided for @yearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get yearly;

  /// No description provided for @newList.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Liste'**
  String get newList;

  /// No description provided for @taskDeletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Görev silindi: {title}'**
  String taskDeletedMessage(Object title);

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @createHabitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Oluştur'**
  String get createHabitTitle;

  /// No description provided for @addDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih ekle'**
  String get addDate;

  /// No description provided for @listNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Sağlık'**
  String get listNameHint;

  /// No description provided for @taskTitleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Görev başlığı zorunlu'**
  String get taskTitleRequired;

  /// No description provided for @moodFlowTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Halin Nasıl?'**
  String get moodFlowTitle;

  /// No description provided for @moodFlowSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü ruh halini seç'**
  String get moodFlowSubtitle;

  /// No description provided for @moodSelection.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali Seçimi'**
  String get moodSelection;

  /// No description provided for @selectYourCurrentMood.
  ///
  /// In tr, this message translates to:
  /// **'Şu anki ruh halini seç'**
  String get selectYourCurrentMood;

  /// No description provided for @moodTerribleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Çok kötü hissediyorum'**
  String get moodTerribleDesc;

  /// No description provided for @moodBadDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kötü hissediyorum'**
  String get moodBadDesc;

  /// No description provided for @moodNeutralDesc.
  ///
  /// In tr, this message translates to:
  /// **'Normal hissediyorum'**
  String get moodNeutralDesc;

  /// No description provided for @moodGoodDesc.
  ///
  /// In tr, this message translates to:
  /// **'İyi hissediyorum'**
  String get moodGoodDesc;

  /// No description provided for @moodExcellentDesc.
  ///
  /// In tr, this message translates to:
  /// **'Harika hissediyorum'**
  String get moodExcellentDesc;

  /// No description provided for @feelingMoreSpecific.
  ///
  /// In tr, this message translates to:
  /// **'Bu duyguyu daha ayrıntılı tarif edelim'**
  String get feelingMoreSpecific;

  /// No description provided for @selectSubEmotionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hangi alt duygu seni en iyi tanımlıyor?'**
  String get selectSubEmotionDesc;

  /// No description provided for @whatsTheCause.
  ///
  /// In tr, this message translates to:
  /// **'Bu durumun sebebi nedir?'**
  String get whatsTheCause;

  /// No description provided for @selectReasonDesc.
  ///
  /// In tr, this message translates to:
  /// **'Günümüzü en çok hangi faktör etkiledi?'**
  String get selectReasonDesc;

  /// No description provided for @moodNeutral.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get moodNeutral;

  /// No description provided for @moodExcellent.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel'**
  String get moodExcellent;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In tr, this message translates to:
  /// **'Kendini nasıl hissediyorsun?'**
  String get howAreYouFeeling;

  /// No description provided for @selectYourMood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh halini seç'**
  String get selectYourMood;

  /// No description provided for @subEmotionSelection.
  ///
  /// In tr, this message translates to:
  /// **'Bu duyguyu daha detaylı tarif edelim'**
  String get subEmotionSelection;

  /// No description provided for @selectSubEmotion.
  ///
  /// In tr, this message translates to:
  /// **'Alt Duygu Seç'**
  String get selectSubEmotion;

  /// No description provided for @subEmotionExhausted.
  ///
  /// In tr, this message translates to:
  /// **'Bitkin'**
  String get subEmotionExhausted;

  /// No description provided for @subEmotionHelpless.
  ///
  /// In tr, this message translates to:
  /// **'Çaresiz'**
  String get subEmotionHelpless;

  /// No description provided for @subEmotionHopeless.
  ///
  /// In tr, this message translates to:
  /// **'Umutsuz'**
  String get subEmotionHopeless;

  /// No description provided for @subEmotionHurt.
  ///
  /// In tr, this message translates to:
  /// **'İncinmiş'**
  String get subEmotionHurt;

  /// No description provided for @subEmotionDrained.
  ///
  /// In tr, this message translates to:
  /// **'Boşalmış'**
  String get subEmotionDrained;

  /// No description provided for @subEmotionAngry.
  ///
  /// In tr, this message translates to:
  /// **'Kızgın'**
  String get subEmotionAngry;

  /// No description provided for @subEmotionSad.
  ///
  /// In tr, this message translates to:
  /// **'Üzgün'**
  String get subEmotionSad;

  /// No description provided for @subEmotionAnxious.
  ///
  /// In tr, this message translates to:
  /// **'Endişeli'**
  String get subEmotionAnxious;

  /// No description provided for @subEmotionStressed.
  ///
  /// In tr, this message translates to:
  /// **'Stresli'**
  String get subEmotionStressed;

  /// No description provided for @subEmotionDemoralized.
  ///
  /// In tr, this message translates to:
  /// **'Morali Bozuk'**
  String get subEmotionDemoralized;

  /// No description provided for @subEmotionIndecisive.
  ///
  /// In tr, this message translates to:
  /// **'Kararsız'**
  String get subEmotionIndecisive;

  /// No description provided for @subEmotionTired.
  ///
  /// In tr, this message translates to:
  /// **'Yorgun'**
  String get subEmotionTired;

  /// No description provided for @subEmotionOrdinary.
  ///
  /// In tr, this message translates to:
  /// **'Sıradan'**
  String get subEmotionOrdinary;

  /// No description provided for @subEmotionCalm.
  ///
  /// In tr, this message translates to:
  /// **'Sakin'**
  String get subEmotionCalm;

  /// No description provided for @subEmotionEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get subEmotionEmpty;

  /// No description provided for @subEmotionHappy.
  ///
  /// In tr, this message translates to:
  /// **'Mutlu'**
  String get subEmotionHappy;

  /// No description provided for @subEmotionCheerful.
  ///
  /// In tr, this message translates to:
  /// **'Neşeli'**
  String get subEmotionCheerful;

  /// No description provided for @subEmotionExcited.
  ///
  /// In tr, this message translates to:
  /// **'Heyecanlı'**
  String get subEmotionExcited;

  /// No description provided for @subEmotionEnthusiastic.
  ///
  /// In tr, this message translates to:
  /// **'Coşkulu'**
  String get subEmotionEnthusiastic;

  /// No description provided for @subEmotionDetermined.
  ///
  /// In tr, this message translates to:
  /// **'Kararlı'**
  String get subEmotionDetermined;

  /// No description provided for @subEmotionMotivated.
  ///
  /// In tr, this message translates to:
  /// **'Motive'**
  String get subEmotionMotivated;

  /// No description provided for @subEmotionAmazing.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get subEmotionAmazing;

  /// No description provided for @subEmotionEnergetic.
  ///
  /// In tr, this message translates to:
  /// **'Enerjik'**
  String get subEmotionEnergetic;

  /// No description provided for @subEmotionPeaceful.
  ///
  /// In tr, this message translates to:
  /// **'Huzurlu'**
  String get subEmotionPeaceful;

  /// No description provided for @subEmotionGrateful.
  ///
  /// In tr, this message translates to:
  /// **'Minnettar'**
  String get subEmotionGrateful;

  /// No description provided for @subEmotionLoving.
  ///
  /// In tr, this message translates to:
  /// **'Sevgi Dolu'**
  String get subEmotionLoving;

  /// No description provided for @reasonSelection.
  ///
  /// In tr, this message translates to:
  /// **'Bu durumun sebebi nedir?'**
  String get reasonSelection;

  /// No description provided for @selectReason.
  ///
  /// In tr, this message translates to:
  /// **'Sebep Seç'**
  String get selectReason;

  /// No description provided for @reasonAcademic.
  ///
  /// In tr, this message translates to:
  /// **'Akademik'**
  String get reasonAcademic;

  /// No description provided for @reasonWork.
  ///
  /// In tr, this message translates to:
  /// **'İş'**
  String get reasonWork;

  /// No description provided for @reasonRelationship.
  ///
  /// In tr, this message translates to:
  /// **'İlişki'**
  String get reasonRelationship;

  /// No description provided for @reasonFinance.
  ///
  /// In tr, this message translates to:
  /// **'Finans'**
  String get reasonFinance;

  /// No description provided for @reasonHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get reasonHealth;

  /// No description provided for @reasonSocial.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal'**
  String get reasonSocial;

  /// No description provided for @reasonPersonalGrowth.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Gelişim'**
  String get reasonPersonalGrowth;

  /// No description provided for @reasonWeather.
  ///
  /// In tr, this message translates to:
  /// **'Hava Durumu'**
  String get reasonWeather;

  /// No description provided for @reasonOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get reasonOther;

  /// No description provided for @journalEntry.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Girişi'**
  String get journalEntry;

  /// No description provided for @tellUsMore.
  ///
  /// In tr, this message translates to:
  /// **'Biraz daha anlat'**
  String get tellUsMore;

  /// No description provided for @journalEntryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bugün hakkında yazmak istediğin var mı?'**
  String get journalEntryDesc;

  /// No description provided for @yourMoodToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Ruh Halin'**
  String get yourMoodToday;

  /// No description provided for @journalHint.
  ///
  /// In tr, this message translates to:
  /// **'Bugün hakkında yazmak istediğin bir şey...'**
  String get journalHint;

  /// No description provided for @saving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get saving;

  /// No description provided for @saveEntry.
  ///
  /// In tr, this message translates to:
  /// **'Girişi Kaydet'**
  String get saveEntry;

  /// No description provided for @entrySaved.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarıyla kaydedildi!'**
  String get entrySaved;

  /// No description provided for @saveError.
  ///
  /// In tr, this message translates to:
  /// **'Kaydederken bir hata oluştu'**
  String get saveError;

  /// No description provided for @moodFlow.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali'**
  String get moodFlow;

  /// No description provided for @moodTracker.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali Takibi'**
  String get moodTracker;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get skip;

  /// No description provided for @habitNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık bulunamadı.'**
  String get habitNotFound;

  /// No description provided for @habitUpdatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık güncellendi.'**
  String get habitUpdatedMessage;

  /// No description provided for @invalidValue.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz değer'**
  String get invalidValue;

  /// No description provided for @nameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad gerekli'**
  String get nameRequired;

  /// No description provided for @simpleHabitTargetOne.
  ///
  /// In tr, this message translates to:
  /// **'Basit alışkanlık (hedef = 1)'**
  String get simpleHabitTargetOne;

  /// No description provided for @typeNotChangeable.
  ///
  /// In tr, this message translates to:
  /// **'Tür değiştirilemez'**
  String get typeNotChangeable;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mira\'ya Hoş Geldin'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seninle birlikte büyüyen kişisel alışkanlık takipçin. Benzersiz kişiliğini keşfedelim ve sana özel alışkanlıklar önerelim.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingQuizIntro.
  ///
  /// In tr, this message translates to:
  /// **'Kişiliğini daha iyi anlayabilmemiz için birkaç soruyu cevaplayın. Bu, bilimsel olarak doğrulanmış psikolojik araştırmalara dayanmaktadır.'**
  String get onboardingQuizIntro;

  /// No description provided for @onboardingQ1.
  ///
  /// In tr, this message translates to:
  /// **'Yeni deneyimler yaşamaktan ve tanımadığım şeyleri keşfetmekten hoşlanırım.'**
  String get onboardingQ1;

  /// No description provided for @onboardingQ2.
  ///
  /// In tr, this message translates to:
  /// **'Alanımı düzenli tutarım ve yapılandırılmış bir günlük rutine sahip olmayı tercih ederim.'**
  String get onboardingQ2;

  /// No description provided for @onboardingQ3.
  ///
  /// In tr, this message translates to:
  /// **'İnsanların yanında olduğumda enerjilenirim ve sosyal etkinliklerden keyif alırım.'**
  String get onboardingQ3;

  /// No description provided for @onboardingQ4.
  ///
  /// In tr, this message translates to:
  /// **'Başkalarıyla çalışmayı tercih ederim ve işbirliğinin rekabetten daha etkili olduğuna inanırım.'**
  String get onboardingQ4;

  /// No description provided for @onboardingQ5.
  ///
  /// In tr, this message translates to:
  /// **'Stresli durumlarla sakin bir şekilde başa çıkarım ve nadiren endişelenirim.'**
  String get onboardingQ5;

  /// No description provided for @onboardingQ6.
  ///
  /// In tr, this message translates to:
  /// **'Sanat, müzik veya yazma gibi yaratıcı aktivitelerden hoşlanırım.'**
  String get onboardingQ6;

  /// No description provided for @onboardingQ7.
  ///
  /// In tr, this message translates to:
  /// **'Kendime net hedefler koyarım ve bunları gerçekleştirmek için gayretle çalışırım.'**
  String get onboardingQ7;

  /// No description provided for @onboardingQ8.
  ///
  /// In tr, this message translates to:
  /// **'Grup aktivitelerini yalnız vakit geçirmeye tercih ederim.'**
  String get onboardingQ8;

  /// No description provided for @onboardingQ9.
  ///
  /// In tr, this message translates to:
  /// **'Karar vermeden önce genellikle başkalarının duygularını dikkate alırım.'**
  String get onboardingQ9;

  /// No description provided for @onboardingQ10.
  ///
  /// In tr, this message translates to:
  /// **'Önemli etkinlikler ve görevler için önceden plan yaparım.'**
  String get onboardingQ10;

  /// No description provided for @onboardingQ11.
  ///
  /// In tr, this message translates to:
  /// **'Tek bir yönteme bağlı kalmaktansa farklı yaklaşımlar denemeyi severim.'**
  String get onboardingQ11;

  /// No description provided for @onboardingQ12.
  ///
  /// In tr, this message translates to:
  /// **'Baskı altında sakin kalırım ve aksiliklerden çabuk toparlanırım.'**
  String get onboardingQ12;

  /// No description provided for @likertStronglyDisagree.
  ///
  /// In tr, this message translates to:
  /// **'Kesinlikle Katılmıyorum'**
  String get likertStronglyDisagree;

  /// No description provided for @likertDisagree.
  ///
  /// In tr, this message translates to:
  /// **'Katılmıyorum'**
  String get likertDisagree;

  /// No description provided for @likertNeutral.
  ///
  /// In tr, this message translates to:
  /// **'Kararsızım'**
  String get likertNeutral;

  /// No description provided for @likertAgree.
  ///
  /// In tr, this message translates to:
  /// **'Katılıyorum'**
  String get likertAgree;

  /// No description provided for @likertStronglyAgree.
  ///
  /// In tr, this message translates to:
  /// **'Kesinlikle Katılıyorum'**
  String get likertStronglyAgree;

  /// No description provided for @characterTypePlanner.
  ///
  /// In tr, this message translates to:
  /// **'Planlayıcı'**
  String get characterTypePlanner;

  /// No description provided for @characterDescPlanner.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli, hedef odaklı ve yapıdan beslenen birisin. Hayalleri eyleme dönüştürmekte ve disiplinle takip etmekte başarılısın.'**
  String get characterDescPlanner;

  /// No description provided for @characterTypeExplorer.
  ///
  /// In tr, this message translates to:
  /// **'Kaşif'**
  String get characterTypeExplorer;

  /// No description provided for @characterDescExplorer.
  ///
  /// In tr, this message translates to:
  /// **'Meraklı, yaratıcı ve çeşitliliği seven birisin. Yeni şeyler öğrenmekten ve hayatın zorluklarına farklı yaklaşımlar denemekten keyif alırsın.'**
  String get characterDescExplorer;

  /// No description provided for @characterTypeSocialConnector.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Bağlayıcı'**
  String get characterTypeSocialConnector;

  /// No description provided for @characterDescSocialConnector.
  ///
  /// In tr, this message translates to:
  /// **'Sıcakkanlı, empatik ve ilişkilerden enerji alan birisin. Başkalarıyla bağlantı kurmakta ve güçlü topluluklar oluşturmakta anlam bulursun.'**
  String get characterDescSocialConnector;

  /// No description provided for @characterTypeBalancedMindful.
  ///
  /// In tr, this message translates to:
  /// **'Dengeli Bilinçli'**
  String get characterTypeBalancedMindful;

  /// No description provided for @characterDescBalancedMindful.
  ///
  /// In tr, this message translates to:
  /// **'Sakin, istikrarlı ve iç huzura değer veren birisin. Denge sağlamakta ve hayata bilinçlilik ve soğukkanlılıkla yaklaşmakta başarılısın.'**
  String get characterDescBalancedMindful;

  /// No description provided for @yourCharacterType.
  ///
  /// In tr, this message translates to:
  /// **'Senin Karakter Tipin'**
  String get yourCharacterType;

  /// No description provided for @recommendedHabits.
  ///
  /// In tr, this message translates to:
  /// **'Senin İçin Önerilen Alışkanlıklar'**
  String get recommendedHabits;

  /// No description provided for @selectHabitsToAdd.
  ///
  /// In tr, this message translates to:
  /// **'Günlük rutinine eklemek istediğin alışkanlıkları seç:'**
  String get selectHabitsToAdd;

  /// No description provided for @startJourney.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğuna Başla'**
  String get startJourney;

  /// No description provided for @skipOnboarding.
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get skipOnboarding;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @habitPlannerMorningRoutine.
  ///
  /// In tr, this message translates to:
  /// **'Sabah Rutini'**
  String get habitPlannerMorningRoutine;

  /// No description provided for @habitPlannerMorningRoutineDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her günü verimliliğe uygun bir sabah rutiyle başlatın.'**
  String get habitPlannerMorningRoutineDesc;

  /// No description provided for @habitPlannerWeeklyReview.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık İnceleme'**
  String get habitPlannerWeeklyReview;

  /// No description provided for @habitPlannerWeeklyReviewDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Pazar haftanın ilerlemenizi inceleyin ve gelecek haftayı planlayın.'**
  String get habitPlannerWeeklyReviewDesc;

  /// No description provided for @habitPlannerGoalSetting.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Hedef Belirleme'**
  String get habitPlannerGoalSetting;

  /// No description provided for @habitPlannerGoalSettingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Gelecek ay için spesifik, ölçülebilir hedefler belirleyin.'**
  String get habitPlannerGoalSettingDesc;

  /// No description provided for @habitPlannerTaskPrioritization.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Görev Önceliklendirme'**
  String get habitPlannerTaskPrioritization;

  /// No description provided for @habitPlannerTaskPrioritizationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her sabah gün içindeki en öncelikli 3 görevinizi belirleyin.'**
  String get habitPlannerTaskPrioritizationDesc;

  /// No description provided for @habitPlannerTimeBlocking.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Blokları'**
  String get habitPlannerTimeBlocking;

  /// No description provided for @habitPlannerTimeBlockingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Derin çalışma için gününüzü odaklı zaman bloklarına ayırın.'**
  String get habitPlannerTimeBlockingDesc;

  /// No description provided for @habitExplorerLearnNewSkill.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bir Şey Öğren'**
  String get habitExplorerLearnNewSkill;

  /// No description provided for @habitExplorerLearnNewSkillDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her hafta yeni bir beceri veya konuya vakit ayırın.'**
  String get habitExplorerLearnNewSkillDesc;

  /// No description provided for @habitExplorerTryNewActivity.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bir Aktivite Dene'**
  String get habitExplorerTryNewActivity;

  /// No description provided for @habitExplorerTryNewActivityDesc.
  ///
  /// In tr, this message translates to:
  /// **'Konfor alanınızın dışına çıkın ve farklı bir deneyim yaşayın.'**
  String get habitExplorerTryNewActivityDesc;

  /// No description provided for @habitExplorerReadDiverse.
  ///
  /// In tr, this message translates to:
  /// **'Çeşitli İçerik Oku'**
  String get habitExplorerReadDiverse;

  /// No description provided for @habitExplorerReadDiverseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Farklı türlerde ve bakış açılarında kitaplar, makaleler veya içerik okuyun.'**
  String get habitExplorerReadDiverseDesc;

  /// No description provided for @habitExplorerCreativeProject.
  ///
  /// In tr, this message translates to:
  /// **'Yaratıcı Proje Zamanı'**
  String get habitExplorerCreativeProject;

  /// No description provided for @habitExplorerCreativeProjectDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hayal gücünüzü ateşleyen bir yaratıcı proje üzerinde çalışın.'**
  String get habitExplorerCreativeProjectDesc;

  /// No description provided for @habitExplorerExplorePlace.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bir Yer Keşfet'**
  String get habitExplorerExplorePlace;

  /// No description provided for @habitExplorerExplorePlaceDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenizdeki yeni bir mahalle, park veya yeri ziyaret edin.'**
  String get habitExplorerExplorePlaceDesc;

  /// No description provided for @habitSocialCallFriend.
  ///
  /// In tr, this message translates to:
  /// **'Bir Arkadaşı Ara'**
  String get habitSocialCallFriend;

  /// No description provided for @habitSocialCallFriendDesc.
  ///
  /// In tr, this message translates to:
  /// **'Anlamlı bir sohbet için bir arkadaşınızla veya aile üyenizle iletişime geçin.'**
  String get habitSocialCallFriendDesc;

  /// No description provided for @habitSocialGroupActivity.
  ///
  /// In tr, this message translates to:
  /// **'Grup Aktivitesine Katıl'**
  String get habitSocialGroupActivity;

  /// No description provided for @habitSocialGroupActivityDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir grup aktivitesine veya sosyal etkinliğe katılın.'**
  String get habitSocialGroupActivityDesc;

  /// No description provided for @habitSocialVolunteer.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü Ol'**
  String get habitSocialVolunteer;

  /// No description provided for @habitSocialVolunteerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü çalışma yoluyla topluluğunuza katkıda bulunun.'**
  String get habitSocialVolunteerDesc;

  /// No description provided for @habitSocialFamilyTime.
  ///
  /// In tr, this message translates to:
  /// **'Kaliteli Aile Zamanı'**
  String get habitSocialFamilyTime;

  /// No description provided for @habitSocialFamilyTimeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Aile üyeleriyle dikkat dağıtıcı şeyler olmadan özel vakit geçirin.'**
  String get habitSocialFamilyTimeDesc;

  /// No description provided for @habitSocialCompliment.
  ///
  /// In tr, this message translates to:
  /// **'Samimi Bir İltifat Yap'**
  String get habitSocialCompliment;

  /// No description provided for @habitSocialComplimentDesc.
  ///
  /// In tr, this message translates to:
  /// **'İçten bir iltifatla birinin gününü aydınlatın.'**
  String get habitSocialComplimentDesc;

  /// No description provided for @habitMindfulMeditation.
  ///
  /// In tr, this message translates to:
  /// **'Meditasyon'**
  String get habitMindfulMeditation;

  /// No description provided for @habitMindfulMeditationDesc.
  ///
  /// In tr, this message translates to:
  /// **'10-15 dakika bilinçli meditasyon yapın.'**
  String get habitMindfulMeditationDesc;

  /// No description provided for @habitMindfulGratitude.
  ///
  /// In tr, this message translates to:
  /// **'Şükür Pratiği'**
  String get habitMindfulGratitude;

  /// No description provided for @habitMindfulGratitudeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bugün minnettar olduğunuz üç şeyi yazın.'**
  String get habitMindfulGratitudeDesc;

  /// No description provided for @habitMindfulNatureWalk.
  ///
  /// In tr, this message translates to:
  /// **'Doğa Yürüyüşü'**
  String get habitMindfulNatureWalk;

  /// No description provided for @habitMindfulNatureWalkDesc.
  ///
  /// In tr, this message translates to:
  /// **'Çevrenize dikkat ederek doğada bilinçli bir yürüyüş yapın.'**
  String get habitMindfulNatureWalkDesc;

  /// No description provided for @habitMindfulBreathing.
  ///
  /// In tr, this message translates to:
  /// **'Derin Nefes Egzersizi'**
  String get habitMindfulBreathing;

  /// No description provided for @habitMindfulBreathingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kendinizi merkezlemek için derin nefes alma teknikleri uygulayın.'**
  String get habitMindfulBreathingDesc;

  /// No description provided for @habitMindfulJournaling.
  ///
  /// In tr, this message translates to:
  /// **'Yansıtıcı Günlük Tutma'**
  String get habitMindfulJournaling;

  /// No description provided for @habitMindfulJournalingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Öz farkındalık için düşüncelerinizi ve yansımalarınızı günlüğe yazın.'**
  String get habitMindfulJournalingDesc;

  /// No description provided for @habitAddSuccess.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Hiç alışkanlık eklenmedi} =1{1 alışkanlık eklendi} other{{count} alışkanlık eklendi}}'**
  String habitAddSuccess(int count);

  /// No description provided for @habitAddError.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklar eklenirken hata: {error}'**
  String habitAddError(Object error);

  /// No description provided for @unlistedItems.
  ///
  /// In tr, this message translates to:
  /// **'Listelenmemiş'**
  String get unlistedItems;

  /// No description provided for @unknownList.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Liste'**
  String get unknownList;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş yap'**
  String get signInWithGoogle;

  /// No description provided for @backupNow.
  ///
  /// In tr, this message translates to:
  /// **'Hemen yedekle'**
  String get backupNow;

  /// No description provided for @restoreLatest.
  ///
  /// In tr, this message translates to:
  /// **'Son yedеği geri yükle'**
  String get restoreLatest;

  /// No description provided for @backupSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Yedeklendi: {id}'**
  String backupSuccess(Object id);

  /// No description provided for @backupError.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme hatası'**
  String get backupError;

  /// No description provided for @restoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'İndirildi: {content}'**
  String restoreSuccess(Object content);

  /// No description provided for @restoreError.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme hatası'**
  String get restoreError;

  /// No description provided for @manageSubscription.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliği yönet'**
  String get manageSubscription;

  /// No description provided for @manageSubscriptionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Mira Plus aboneliğini Google Play üzerinden düzenle'**
  String get manageSubscriptionSubtitle;

  /// No description provided for @deleteMyAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı sil'**
  String get deleteMyAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızın ve verilerinizin silinmesini talep edin'**
  String get deleteAccountSubtitle;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı silmeyi onayla'**
  String get confirmDeleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. Lütfen hesabınızla ilişkili e-posta adresini onaylayın.'**
  String get deleteAccountWarning;

  /// No description provided for @yourEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresiniz'**
  String get yourEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-posta girin'**
  String get pleaseEnterEmail;

  /// No description provided for @deleteAccountRequestSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silme talebiniz başarıyla alındı'**
  String get deleteAccountRequestSuccess;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silme başarısız'**
  String get deleteAccountFailed;

  /// No description provided for @resetOnboarding.
  ///
  /// In tr, this message translates to:
  /// **'Tanıtımı sıfırla'**
  String get resetOnboarding;

  /// No description provided for @retakePersonalityTest.
  ///
  /// In tr, this message translates to:
  /// **'Kişilik testini tekrar yap'**
  String get retakePersonalityTest;

  /// No description provided for @processingWait.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başlatılıyor, lütfen bekleyin...'**
  String get processingWait;

  /// No description provided for @checkingPurchases.
  ///
  /// In tr, this message translates to:
  /// **'Satın almalar kontrol ediliyor...'**
  String get checkingPurchases;

  /// No description provided for @premiumPlans.
  ///
  /// In tr, this message translates to:
  /// **'Premium Planlar'**
  String get premiumPlans;

  /// No description provided for @restorePurchases.
  ///
  /// In tr, this message translates to:
  /// **'Satın Almaları Geri Yükle'**
  String get restorePurchases;

  /// No description provided for @noPlansAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Şu anda görüntülenecek plan yok.'**
  String get noPlansAvailable;

  /// No description provided for @cannotOpenPlayStore.
  ///
  /// In tr, this message translates to:
  /// **'Play Store açılamıyor'**
  String get cannotOpenPlayStore;

  /// No description provided for @subscriptionDetails.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik Detayları'**
  String get subscriptionDetails;

  /// No description provided for @goToPlayStore.
  ///
  /// In tr, this message translates to:
  /// **'Play Store\'a Git'**
  String get goToPlayStore;

  /// No description provided for @becomePremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium Olun'**
  String get becomePremium;

  /// No description provided for @premiumFeature.
  ///
  /// In tr, this message translates to:
  /// **'Premium Özellik'**
  String get premiumFeature;

  /// No description provided for @premiumBenefits.
  ///
  /// In tr, this message translates to:
  /// **'Premium avantajları:'**
  String get premiumBenefits;

  /// No description provided for @later.
  ///
  /// In tr, this message translates to:
  /// **'Daha Sonra'**
  String get later;

  /// No description provided for @becomePremiumShort.
  ///
  /// In tr, this message translates to:
  /// **'Premium Ol'**
  String get becomePremiumShort;

  /// No description provided for @shareDashboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoyu paylaş'**
  String get shareDashboard;

  /// No description provided for @customUnit.
  ///
  /// In tr, this message translates to:
  /// **'Özel Birim'**
  String get customUnit;

  /// No description provided for @pastelColors.
  ///
  /// In tr, this message translates to:
  /// **'Pastel Tonlar'**
  String get pastelColors;

  /// No description provided for @habitNameHintTimer.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Meditasyon, Egzersiz...'**
  String get habitNameHintTimer;

  /// No description provided for @habitNameHintNumerical.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Su içmek, Sayfa okumak...'**
  String get habitNameHintNumerical;

  /// No description provided for @habitDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Kısa bir açıklama ekle...'**
  String get habitDescriptionHint;

  /// No description provided for @target.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get target;

  /// No description provided for @amount.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get amount;

  /// No description provided for @custom.
  ///
  /// In tr, this message translates to:
  /// **'Özel'**
  String get custom;

  /// No description provided for @customUnitHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: porsiyon, set, km...'**
  String get customUnitHint;

  /// No description provided for @unitAdet.
  ///
  /// In tr, this message translates to:
  /// **'adet'**
  String get unitAdet;

  /// No description provided for @unitBardak.
  ///
  /// In tr, this message translates to:
  /// **'bardak'**
  String get unitBardak;

  /// No description provided for @unitSayfa.
  ///
  /// In tr, this message translates to:
  /// **'sayfa'**
  String get unitSayfa;

  /// No description provided for @unitKm.
  ///
  /// In tr, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitLitre.
  ///
  /// In tr, this message translates to:
  /// **'litre'**
  String get unitLitre;

  /// No description provided for @unitKalori.
  ///
  /// In tr, this message translates to:
  /// **'kalori'**
  String get unitKalori;

  /// No description provided for @unitAdim.
  ///
  /// In tr, this message translates to:
  /// **'adım'**
  String get unitAdim;

  /// No description provided for @unitKez.
  ///
  /// In tr, this message translates to:
  /// **'kez'**
  String get unitKez;

  /// No description provided for @premiumFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Premium Özellikler'**
  String get premiumFeatures;

  /// No description provided for @featureAdvancedHabits.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Alışkanlık Oluşturma'**
  String get featureAdvancedHabits;

  /// No description provided for @featureVisionCreation.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon Oluşturma'**
  String get featureVisionCreation;

  /// No description provided for @featureAdvancedFinance.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Finans Özellikleri'**
  String get featureAdvancedFinance;

  /// No description provided for @featurePremiumThemes.
  ///
  /// In tr, this message translates to:
  /// **'Premium Temalar'**
  String get featurePremiumThemes;

  /// No description provided for @featureBackup.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme Özelliği'**
  String get featureBackup;

  /// No description provided for @perMonth.
  ///
  /// In tr, this message translates to:
  /// **'/ay'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In tr, this message translates to:
  /// **'/yıl'**
  String get perYear;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Tüm özellikleri açın ve sınırları kaldırın.'**
  String get unlockAllFeatures;

  /// No description provided for @flexiblePlan.
  ///
  /// In tr, this message translates to:
  /// **'Esnek plan, istediğin zaman iptal et'**
  String get flexiblePlan;

  /// No description provided for @annualPlanDesc.
  ///
  /// In tr, this message translates to:
  /// **'12 ay boyunca kesintisiz erişim'**
  String get annualPlanDesc;

  /// No description provided for @trialInfo.
  ///
  /// In tr, this message translates to:
  /// **'14 gün ücretsiz deneme, istediğin zaman iptal et.'**
  String get trialInfo;

  /// No description provided for @miraPlusActive.
  ///
  /// In tr, this message translates to:
  /// **'Mira Plus Aktif'**
  String get miraPlusActive;

  /// No description provided for @miraPlusInactive.
  ///
  /// In tr, this message translates to:
  /// **'Mira Plus Aktif Değil'**
  String get miraPlusInactive;

  /// No description provided for @validity.
  ///
  /// In tr, this message translates to:
  /// **'Geçerlilik'**
  String get validity;

  /// No description provided for @daysLeft.
  ///
  /// In tr, this message translates to:
  /// **'gün kaldı'**
  String get daysLeft;

  /// No description provided for @subscribeToEnjoyPremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium özelliklerin keyfini çıkarmak için abone olun'**
  String get subscribeToEnjoyPremium;

  /// No description provided for @advancedAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'İleri Seviye Analiz'**
  String get advancedAnalysis;

  /// No description provided for @detailedCharts.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı grafikler ve istatistikler'**
  String get detailedCharts;

  /// No description provided for @cloudBackup.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Yedekleme'**
  String get cloudBackup;

  /// No description provided for @backupToDrive.
  ///
  /// In tr, this message translates to:
  /// **'Drive\'a Yedekle'**
  String get backupToDrive;

  /// No description provided for @adFreeExperience.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız Deneyim'**
  String get adFreeExperience;

  /// No description provided for @uninterruptedUsage.
  ///
  /// In tr, this message translates to:
  /// **'Kesintisiz kullanım'**
  String get uninterruptedUsage;

  /// No description provided for @advancedTimer.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Timer'**
  String get advancedTimer;

  /// No description provided for @pomodoroAndCustomTimers.
  ///
  /// In tr, this message translates to:
  /// **'Pomodoro ve özel zamanlayıcılar'**
  String get pomodoroAndCustomTimers;

  /// No description provided for @personalizedInsights.
  ///
  /// In tr, this message translates to:
  /// **'Kişiselleştirilmiş İçgörüler'**
  String get personalizedInsights;

  /// No description provided for @aiPoweredRecommendations.
  ///
  /// In tr, this message translates to:
  /// **'AI destekli öneriler'**
  String get aiPoweredRecommendations;

  /// No description provided for @buyPremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium Satın Al'**
  String get buyPremium;

  /// No description provided for @manageOnGooglePlay.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliği Google Play\'de Yönet'**
  String get manageOnGooglePlay;

  /// No description provided for @manageSubscriptionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Plan değiştir, iptal et veya fatura bilgilerini gör'**
  String get manageSubscriptionDesc;

  /// No description provided for @billingHistory.
  ///
  /// In tr, this message translates to:
  /// **'Fatura Geçmişi'**
  String get billingHistory;

  /// No description provided for @viewInvoicesOnPlayStore.
  ///
  /// In tr, this message translates to:
  /// **'Google Play Store\'dan faturalarınızı görüntüleyin'**
  String get viewInvoicesOnPlayStore;

  /// No description provided for @seeFullSubscriptionInfo.
  ///
  /// In tr, this message translates to:
  /// **'Tam abonelik bilgilerinizi görün'**
  String get seeFullSubscriptionInfo;

  /// No description provided for @helpAndSupport.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve Destek'**
  String get helpAndSupport;

  /// No description provided for @howToCancel.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl iptal ederim?'**
  String get howToCancel;

  /// No description provided for @cancelInstructions.
  ///
  /// In tr, this message translates to:
  /// **'Google Play Store → Abonelikler → Mira Plus → İptal Et'**
  String get cancelInstructions;

  /// No description provided for @whatHappensIfCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal edersem ne olur?'**
  String get whatHappensIfCancel;

  /// No description provided for @cancelEffect.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik süreniz bitene kadar premium özelliklerden faydalanmaya devam edersiniz.'**
  String get cancelEffect;

  /// No description provided for @ifTrialCancelled.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz deneme iptal edilirse?'**
  String get ifTrialCancelled;

  /// No description provided for @trialCancelEffect.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz deneme sırasında iptal ederseniz hemen ücretlendirilmezsiniz.'**
  String get trialCancelEffect;

  /// No description provided for @canIGetRefund.
  ///
  /// In tr, this message translates to:
  /// **'Geri ödeme alabilir miyim?'**
  String get canIGetRefund;

  /// No description provided for @refundPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Geri ödeme talepleri Google Play politikalarına tabidir. Play Store\'dan başvurabilirsiniz.'**
  String get refundPolicy;

  /// No description provided for @active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In tr, this message translates to:
  /// **'İnaktif'**
  String get inactive;

  /// No description provided for @daysRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Gün'**
  String get daysRemaining;

  /// No description provided for @usePlayStoreToManage.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğinizi yönetmek için Google Play Store\'u kullanın.'**
  String get usePlayStoreToManage;

  /// No description provided for @thisFeatureIsPremium.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik Premium\'da'**
  String get thisFeatureIsPremium;

  /// No description provided for @mustBePremiumToUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu özelliği kullanmak için Premium abonesi olmalısınız.'**
  String get mustBePremiumToUse;

  /// No description provided for @advancedAnalysisAndReports.
  ///
  /// In tr, this message translates to:
  /// **'İleri seviye analiz ve raporlar'**
  String get advancedAnalysisAndReports;

  /// No description provided for @unlimitedDataStorage.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız veri depolama'**
  String get unlimitedDataStorage;

  /// No description provided for @freeTrial14Days.
  ///
  /// In tr, this message translates to:
  /// **'14 gün ücretsiz deneme'**
  String get freeTrial14Days;

  /// No description provided for @backupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme başarısız'**
  String get backupFailed;

  /// No description provided for @restoreFailed.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme başarısız'**
  String get restoreFailed;

  /// No description provided for @plansLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Planlar yüklenirken hata oluştu: {error}'**
  String plansLoadError(Object error);

  /// No description provided for @optional.
  ///
  /// In tr, this message translates to:
  /// **'opsiyonel'**
  String get optional;

  /// No description provided for @newHabit.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Alışkanlık'**
  String get newHabit;

  /// No description provided for @typeEmoji.
  ///
  /// In tr, this message translates to:
  /// **'Klavyeden bir emoji yazın'**
  String get typeEmoji;

  /// No description provided for @habitNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Su içmek, Kitap okumak...'**
  String get habitNameHint;

  /// No description provided for @weekDaysShort.
  ///
  /// In tr, this message translates to:
  /// **'Pzt,Sal,Çar,Per,Cum,Cmt,Paz'**
  String get weekDaysShort;

  /// No description provided for @every.
  ///
  /// In tr, this message translates to:
  /// **'Her'**
  String get every;

  /// No description provided for @daysInterval.
  ///
  /// In tr, this message translates to:
  /// **'günde bir'**
  String get daysInterval;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @monthsShort.
  ///
  /// In tr, this message translates to:
  /// **'Oca,Şub,Mar,Nis,May,Haz,Tem,Ağu,Eyl,Eki,Kas,Ara'**
  String get monthsShort;

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @daysLater.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün sonra'**
  String daysLater(Object days);

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce'**
  String daysAgo(Object days);

  /// No description provided for @off.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get off;

  /// No description provided for @createHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Oluştur'**
  String get createHabit;

  /// No description provided for @pickTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat Seç'**
  String get pickTime;

  /// No description provided for @monthlyDays.
  ///
  /// In tr, this message translates to:
  /// **'Ayın {days}. günleri'**
  String monthlyDays(Object days);

  /// No description provided for @signInFailed.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız oldu. Lütfen tekrar deneyin.'**
  String get signInFailed;

  /// No description provided for @signInWithGoogleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Google hesabınla giriş yap'**
  String get signInWithGoogleTitle;

  /// No description provided for @signInWithGoogleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için Google hesabını bağla. Profil bilgilerin otomatik dolacak.'**
  String get signInWithGoogleDesc;

  /// No description provided for @signInWithGoogleButton.
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş yap'**
  String get signInWithGoogleButton;

  /// No description provided for @startTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişilik testine başlamak ister misin?'**
  String get startTestTitle;

  /// No description provided for @startTestDesc.
  ///
  /// In tr, this message translates to:
  /// **'Testi tamamlarsan kişiliğine uygun öneriler ve önerilen alışkanlıklar alırsın. İstersen bu adımı şimdi atlayabilirsin.'**
  String get startTestDesc;

  /// No description provided for @skipTest.
  ///
  /// In tr, this message translates to:
  /// **'Testi Atla'**
  String get skipTest;

  /// No description provided for @startTest.
  ///
  /// In tr, this message translates to:
  /// **'Testi Başlat'**
  String get startTest;

  /// No description provided for @backupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme'**
  String get backupTitle;

  /// No description provided for @jsonDataExample.
  ///
  /// In tr, this message translates to:
  /// **'JSON Veri (örnek):'**
  String get jsonDataExample;

  /// No description provided for @refreshList.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi Yenile'**
  String get refreshList;

  /// No description provided for @noBackupsFound.
  ///
  /// In tr, this message translates to:
  /// **'Yedek bulunamadı.'**
  String get noBackupsFound;

  /// No description provided for @unnamedBackup.
  ///
  /// In tr, this message translates to:
  /// **'adsız'**
  String get unnamedBackup;

  /// No description provided for @restore.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get restore;

  /// No description provided for @financeNet.
  ///
  /// In tr, this message translates to:
  /// **'Net'**
  String get financeNet;

  /// No description provided for @durationIndefinite.
  ///
  /// In tr, this message translates to:
  /// **'Süresiz'**
  String get durationIndefinite;

  /// No description provided for @durationMonths.
  ///
  /// In tr, this message translates to:
  /// **'{count} ay'**
  String durationMonths(Object count);

  /// No description provided for @fortuneProceedToEggs.
  ///
  /// In tr, this message translates to:
  /// **'Yumurtalara Geç'**
  String get fortuneProceedToEggs;

  /// No description provided for @fortuneSwipeInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Yumurtayı sağa/sola kaydırarak değiştirin, üzerine dokununca cevap görünür'**
  String get fortuneSwipeInstruction;

  /// No description provided for @listCreated.
  ///
  /// In tr, this message translates to:
  /// **'Liste oluşturuldu: {title}'**
  String listCreated(Object title);

  /// No description provided for @moodAnalytics.
  ///
  /// In tr, this message translates to:
  /// **'Duygu Analizi'**
  String get moodAnalytics;

  /// No description provided for @overview.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get overview;

  /// No description provided for @trends.
  ///
  /// In tr, this message translates to:
  /// **'Trendler'**
  String get trends;

  /// No description provided for @history.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get history;

  /// No description provided for @noMoodData.
  ///
  /// In tr, this message translates to:
  /// **'Henüz duygu verisi yok'**
  String get noMoodData;

  /// No description provided for @startTrackingMood.
  ///
  /// In tr, this message translates to:
  /// **'Analizleri görmek için duygu durumunu kaydetmeye başla'**
  String get startTrackingMood;

  /// No description provided for @totalEntries.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kayıt'**
  String get totalEntries;

  /// No description provided for @averageMood.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Duygu'**
  String get averageMood;

  /// No description provided for @moodDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Duygu Dağılımı'**
  String get moodDistribution;

  /// No description provided for @topCategories.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Kategoriler'**
  String get topCategories;

  /// No description provided for @mostCommonMood.
  ///
  /// In tr, this message translates to:
  /// **'En Yaygın Duygu'**
  String get mostCommonMood;

  /// No description provided for @mostCommonEmotion.
  ///
  /// In tr, this message translates to:
  /// **'En Yaygın His'**
  String get mostCommonEmotion;

  /// No description provided for @mostCommonReason.
  ///
  /// In tr, this message translates to:
  /// **'En Yaygın Sebep'**
  String get mostCommonReason;

  /// No description provided for @moodTrend.
  ///
  /// In tr, this message translates to:
  /// **'Duygu Trendi (Son 30 Gün)'**
  String get moodTrend;

  /// No description provided for @noTrendData.
  ///
  /// In tr, this message translates to:
  /// **'Trend için yeterli veri yok'**
  String get noTrendData;

  /// No description provided for @insights.
  ///
  /// In tr, this message translates to:
  /// **'İçgörüler'**
  String get insights;

  /// No description provided for @moodImproving.
  ///
  /// In tr, this message translates to:
  /// **'Duygu durumun iyileşiyor!'**
  String get moodImproving;

  /// No description provided for @moodDeclining.
  ///
  /// In tr, this message translates to:
  /// **'Duygu durumun düşüşte'**
  String get moodDeclining;

  /// No description provided for @moodStable.
  ///
  /// In tr, this message translates to:
  /// **'Duygu durumun nispeten dengeli'**
  String get moodStable;

  /// No description provided for @noHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş kaydı yok'**
  String get noHistory;

  /// No description provided for @open.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get open;

  /// No description provided for @openNotificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim ayarlarını aç'**
  String get openNotificationSettings;

  /// No description provided for @openSystemSettings.
  ///
  /// In tr, this message translates to:
  /// **'Sistem ayarlarını aç'**
  String get openSystemSettings;

  /// No description provided for @openBatteryOptimization.
  ///
  /// In tr, this message translates to:
  /// **'Pil optimizasyonunu aç'**
  String get openBatteryOptimization;

  /// No description provided for @habitReminderBody.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığını tamamlama zamanı!'**
  String get habitReminderBody;

  /// No description provided for @timerPause.
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get timerPause;

  /// No description provided for @timerResume.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get timerResume;

  /// No description provided for @timerStop.
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get timerStop;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicyTitle;

  /// No description provided for @miraPremium.
  ///
  /// In tr, this message translates to:
  /// **'Mira Premium'**
  String get miraPremium;

  /// No description provided for @visionTasks.
  ///
  /// In tr, this message translates to:
  /// **'Görevler'**
  String get visionTasks;

  /// No description provided for @addTask.
  ///
  /// In tr, this message translates to:
  /// **'Görev Ekle'**
  String get addTask;

  /// No description provided for @taskCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get taskCompleted;

  /// No description provided for @taskPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get taskPending;

  /// No description provided for @noTasksYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz görev eklenmedi'**
  String get noTasksYet;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu görevi silmek istediğinize emin misiniz?'**
  String get deleteTaskConfirm;

  /// No description provided for @taskAdded.
  ///
  /// In tr, this message translates to:
  /// **'Görev eklendi'**
  String get taskAdded;

  /// No description provided for @manageVisionTasks.
  ///
  /// In tr, this message translates to:
  /// **'Görevleri Yönet'**
  String get manageVisionTasks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'nl',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
