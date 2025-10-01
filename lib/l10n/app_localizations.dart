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
  /// **'Bu girişi sil?'**
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

  /// No description provided for @enableReminder.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcıyı Etkinleştir'**
  String get enableReminder;

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
  /// **'Geri'**
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

  /// No description provided for @motivation.
  ///
  /// In tr, this message translates to:
  /// **'Motivasyon'**
  String get motivation;

  /// No description provided for @motivationBody.
  ///
  /// In tr, this message translates to:
  /// **'Harika! {period} boyunca %{percent} başarı oranına ulaştınız.'**
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

  /// No description provided for @periodic.
  ///
  /// In tr, this message translates to:
  /// **'Periyodik'**
  String get periodic;

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
  /// **'Alt duygu seç'**
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
  /// **'Sebep seç'**
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

  /// No description provided for @moodAnalytics.
  ///
  /// In tr, this message translates to:
  /// **'Mood Analizi'**
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
  /// **'Henüz mood verisi yok'**
  String get noMoodData;

  /// No description provided for @startTrackingMood.
  ///
  /// In tr, this message translates to:
  /// **'Analitikleri görmek için mood\'unuzu takip etmeye başlayın'**
  String get startTrackingMood;

  /// No description provided for @totalEntries.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Girişler'**
  String get totalEntries;

  /// No description provided for @averageMood.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Mood'**
  String get averageMood;

  /// No description provided for @moodDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Mood Dağılımı'**
  String get moodDistribution;

  /// No description provided for @topCategories.
  ///
  /// In tr, this message translates to:
  /// **'Üst Kategoriler'**
  String get topCategories;

  /// No description provided for @mostCommonMood.
  ///
  /// In tr, this message translates to:
  /// **'En Yaygın Mood'**
  String get mostCommonMood;

  /// No description provided for @mostCommonEmotion.
  ///
  /// In tr, this message translates to:
  /// **'En Yaygın Duygu'**
  String get mostCommonEmotion;

  /// No description provided for @mostCommonReason.
  ///
  /// In tr, this message translates to:
  /// **'En Yaygın Sebep'**
  String get mostCommonReason;

  /// No description provided for @noTrendData.
  ///
  /// In tr, this message translates to:
  /// **'Trend için yeterli veri yok'**
  String get noTrendData;

  /// No description provided for @moodTrend.
  ///
  /// In tr, this message translates to:
  /// **'Mood Trendi (Son 30 Gün)'**
  String get moodTrend;

  /// No description provided for @insights.
  ///
  /// In tr, this message translates to:
  /// **'İçgörüler'**
  String get insights;

  /// No description provided for @moodImproving.
  ///
  /// In tr, this message translates to:
  /// **'Mood\'unuz gelişiyor!'**
  String get moodImproving;

  /// No description provided for @moodDeclining.
  ///
  /// In tr, this message translates to:
  /// **'Mood\'unuz düşüyor gibi görünüyor'**
  String get moodDeclining;

  /// No description provided for @moodStable.
  ///
  /// In tr, this message translates to:
  /// **'Mood\'unuz nispeten stabil'**
  String get moodStable;

  /// No description provided for @noHistory.
  ///
  /// In tr, this message translates to:
  /// **'Mood geçmişi yok'**
  String get noHistory;

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
