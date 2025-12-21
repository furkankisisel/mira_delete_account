// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get about => 'について';

  @override
  String get account => 'アカウント';

  @override
  String get achievements => '成果';

  @override
  String get activeDays => 'アクティブな日数';

  @override
  String get add => '追加';

  @override
  String get addHabit => '習慣を追加';

  @override
  String get addImage => '画像を追加';

  @override
  String get addNew => '新規追加';

  @override
  String get addNewHabit => '新しい習慣を追加';

  @override
  String get addSpecialDays => '特別な日を追加';

  @override
  String get addText => 'テキストを追加';

  @override
  String get advancedHabit => '高度な習慣';

  @override
  String get allLabel => 'すべて';

  @override
  String get alsoDeleteLinkedHabits => 'リンクされた習慣も削除する';

  @override
  String get amountLabel => '金額';

  @override
  String get socialFeedTitle => 'Feed';

  @override
  String get spendingAdvisorTitle => '支出アドバイザー';

  @override
  String spendingAdvisorSafe(Object amount) {
    return '1日あたり$amount使えます。';
  }

  @override
  String spendingAdvisorWarning(Object amount) {
    return '予算内に収めるには、1日の支出を$amount減らしてください。';
  }

  @override
  String get spendingAdvisorOnTrack => '素晴らしい！予算通りに進んでいます。';

  @override
  String get spendingAdvisorOverBudget => '予算を超過しています。支出を控えてください。';

  @override
  String get spendingAdvisorNoBudget => 'アドバイスを受けるには予算を設定してください。';

  @override
  String get appTitle => 'Mira';

  @override
  String get appearance => '外観';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get notificationSettingsSubtitle => '通知の設定を変更します';

  @override
  String get enableNotifications => '通知を有効にする';

  @override
  String get notificationsMasterSubtitle => 'すべてのアプリ通知を管理';

  @override
  String get notificationTypes => '通知の種類';

  @override
  String get habitReminders => '習慣のリマインダー';

  @override
  String get habitRemindersSubtitle => '習慣の毎日のリマインダー';

  @override
  String get notificationBehavior => '通知の動作';

  @override
  String get sound => 'サウンド';

  @override
  String get soundSubtitle => '通知でサウンドを再生';

  @override
  String get vibration => 'バイブレーション';

  @override
  String get vibrationSubtitle => '通知でバイブレーション';

  @override
  String get systemInfo => 'システム情報';

  @override
  String get timezone => 'タイムゾーン';

  @override
  String get notificationPermission => '通知の許可';

  @override
  String get exactAlarmPermission => '正確なアラームの許可（Android 12以降）';

  @override
  String get granted => '許可済み';

  @override
  String get notGranted => '未許可';

  @override
  String get importantNotice => '重要なお知らせ';

  @override
  String get notificationTroubleshooting =>
      '通知を正常に動作させるには：\n\n• バッテリー最適化をオフにする\n• バックグラウンドアクティビティを許可する\n• 通知の許可がオンになっていることを確認する\n• 「おやすみモード」を確認する';

  @override
  String approxVisionDurationDays(Object days) {
    return 'このビジョンは約$days日間続きます';
  }

  @override
  String get assetsReloadHint => '一部のアセットを読み込むには、アプリの完全な再起動が必要な場合があります。';

  @override
  String get atLeast => '以上';

  @override
  String get atMost => '以下';

  @override
  String get backgroundPlate => '背景プレート';

  @override
  String get badgeActive100dDesc => '100日間アクティブであること';

  @override
  String get badgeActive100dTitle => '100日間のアクティビティ';

  @override
  String get badgeActive30dDesc => '30日間アクティブであること';

  @override
  String get badgeActive30dTitle => '30日間のアクティビティ';

  @override
  String get badgeActive7dDesc => '7日間アクティブであること';

  @override
  String get badgeActive7dTitle => '7日間のアクティビティ';

  @override
  String get badgeCategoryActivity => 'アクティビティ';

  @override
  String get badgeCategoryFinance => 'ファイナンス';

  @override
  String get badgeCategoryHabit => '習慣';

  @override
  String get badgeCategoryLevel => 'レベル';

  @override
  String get badgeCategoryVision => 'ビジョン';

  @override
  String get badgeCategoryXp => 'XP';

  @override
  String get badgeFin100Desc => '100件の取引を記録する';

  @override
  String get badgeFin100Title => 'フィナンシェ100';

  @override
  String get badgeFin10Desc => '10件の取引を記録する';

  @override
  String get badgeFin10Title => 'フィナンシェ10';

  @override
  String get badgeFin250Desc => '250件の取引を記録する';

  @override
  String get badgeFin250Title => 'フィナンシェ250';

  @override
  String get badgeFin50Desc => '50件の取引を記録する';

  @override
  String get badgeFin50Title => 'フィナンシェ50';

  @override
  String get badgeHabit100Desc => '合計100個の習慣を完了する';

  @override
  String get badgeHabit100Title => '習慣100';

  @override
  String get badgeHabit10Desc => '合計10個の習慣を完了する';

  @override
  String get badgeHabit10Title => '習慣10';

  @override
  String get badgeHabit200Desc => '合計200個の習慣を完了する';

  @override
  String get badgeHabit200Title => '習慣200';

  @override
  String get badgeHabit50Desc => '合計50個の習慣を完了する';

  @override
  String get badgeHabit50Title => '習慣50';

  @override
  String get badgeLevel10Desc => 'レベル10に到達';

  @override
  String get badgeLevel10Title => 'レベル10';

  @override
  String get badgeLevel20Desc => 'レベル20に到達';

  @override
  String get badgeLevel20Title => 'レベル20';

  @override
  String get badgeLevel5Desc => 'レベル5に到達';

  @override
  String get badgeLevel5Title => 'レベル5';

  @override
  String get badgeVision10Desc => '10個のビジョンを作成する';

  @override
  String get badgeVision10Title => 'ビジョングランドマスター';

  @override
  String get badgeVision1Desc => '最初のビジョンを作成する';

  @override
  String get badgeVision1Title => 'ビジョナリー';

  @override
  String get badgeVision5Desc => '5個のビジョンを作成する';

  @override
  String get badgeVision5Title => 'ビジョンマスター';

  @override
  String get badgeVisionHabits3Desc => '3つ以上の習慣をビジョンにリンクする';

  @override
  String get badgeVisionHabits3Title => 'コネクター';

  @override
  String get badgeXp1000Desc => '合計1000 XPを獲得';

  @override
  String get badgeXp1000Title => '1000 XP';

  @override
  String get badgeXp500Desc => '合計500 XPを獲得';

  @override
  String get badgeXp500Title => '500 XP';

  @override
  String get between1And360 => '1から360の間';

  @override
  String get bio => '経歴';

  @override
  String get bioHint => 'あなたについての短い経歴';

  @override
  String get breakTime => '休憩';

  @override
  String get breakdownByCategory => 'カテゴリ別の内訳';

  @override
  String get bringForward => '前面へ移動';

  @override
  String get cancel => 'キャンセル';

  @override
  String get category => 'カテゴリ';

  @override
  String get categoryName => 'カテゴリ名';

  @override
  String get chooseBestCategory => 'あなたの習慣に最適なカテゴリを選択してください';

  @override
  String get chooseColor => '色を選択:';

  @override
  String get chooseEmoji => '絵文字を選択:';

  @override
  String get clearHistory => '履歴をクリア';

  @override
  String get close => '閉じる';

  @override
  String get colorLabel => '色';

  @override
  String get colorTheme => 'カラーテーマ';

  @override
  String get countdownConfigureTitle => 'カウントダウンを設定';

  @override
  String get create => '作成';

  @override
  String get createAdvancedHabit => '高度な習慣を作成';

  @override
  String get createDailyTask => '日課を作成';

  @override
  String get createHabitTemplateTitle => '習慣テンプレートを作成';

  @override
  String get createList => 'リストを作成';

  @override
  String get createNewCategory => '新しいカテゴリを作成';

  @override
  String get createVision => 'ビジョンを作成';

  @override
  String get createVisionTemplateTitle => 'ビジョンテンプレートを作成';

  @override
  String get customCategories => 'カスタムカテゴリ';

  @override
  String get customEmojiHint => '例: ✨';

  @override
  String get customEmojiOptional => 'カスタム絵文字（任意）';

  @override
  String get reminder => 'リマインダー';

  @override
  String get enableReminder => 'リマインダーを有効にする';

  @override
  String get selectTime => '時刻を選択';

  @override
  String get customFrequency => 'カスタム';

  @override
  String get daily => '毎日';

  @override
  String get dailyCheck => '毎日のチェック';

  @override
  String get dailyLimit => '1日の制限';

  @override
  String get dailyTask => '日課';

  @override
  String get darkTheme => 'ダークテーマ';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get date => '日付';

  @override
  String dayRangeShort(Object end, Object start) {
    return '$start日目～$end日目';
  }

  @override
  String dayShort(Object day) {
    return '$day日目';
  }

  @override
  String daysAverageShort(Object days) {
    return '$days日平均';
  }

  @override
  String get delete => '削除';

  @override
  String deleteCategoryConfirmNamed(Object name) {
    return 'カテゴリ「$name」を削除しますか？';
  }

  @override
  String get deleteCategoryTitle => 'カテゴリを削除';

  @override
  String get deleteCustomCategoryConfirm => 'このカスタムカテゴリを削除しますか？';

  @override
  String get deleteEntryConfirm => 'このエントリを削除しますか？';

  @override
  String deleteTransactionConfirm(Object title) {
    return 'レコード「$title」を削除しますか？';
  }

  @override
  String get deleteVisionMessage => 'このビジョンを削除しますか？';

  @override
  String get deleteVisionTitle => 'ビジョンを削除';

  @override
  String get descHint => 'あなたの習慣に関する詳細（任意）';

  @override
  String get difficulty => '難易度';

  @override
  String get duration => '期間';

  @override
  String get durationAutoLabel => '期間（自動）';

  @override
  String get durationSelection => '期間の選択';

  @override
  String get durationType => '期間タイプ';

  @override
  String get earthTheme => 'アース';

  @override
  String get earthThemeDesc => '大地の色';

  @override
  String get easy => '簡単';

  @override
  String get edit => '編集';

  @override
  String get editCategory => 'カテゴリを編集';

  @override
  String get editHabit => '習慣を編集';

  @override
  String get education => '教育';

  @override
  String get emojiLabel => '絵文字';

  @override
  String get endDate => '終了日';

  @override
  String get endDayOptionalLabel => '終了日（任意）';

  @override
  String get enterMonthlyPlanToComputeDailyLimit =>
      '1日の制限を計算するために月間プランを入力してください。';

  @override
  String get enterNameAndDesc => '習慣の名前と説明を入力してください';

  @override
  String get enterYourName => 'あなたの名前を入力してください';

  @override
  String get entries => 'エントリ';

  @override
  String get everyNDaysQuestion => '何日ごとですか？';

  @override
  String get everyday => '毎日';

  @override
  String get exact => '正確';

  @override
  String examplePrefix(Object example) {
    return '例: $example';
  }

  @override
  String get expenseDelta => '支出Δ';

  @override
  String get expenseDistributionPie => '支出分布（円グラフ）';

  @override
  String get expenseEditTitle => '支出を編集';

  @override
  String get expenseLabel => '支出';

  @override
  String get expenseNewTitle => '新しい支出';

  @override
  String failedToLoad(Object error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get filterTitle => 'フィルター';

  @override
  String get finance => 'ファイナンス';

  @override
  String financeAnalysisTitle(Object month) {
    return '財務分析・$month';
  }

  @override
  String get financeLast7Days => '財務・過去7日間';

  @override
  String get finish => '完了';

  @override
  String get historyTitle => 'History';

  @override
  String get fitness => 'フィットネス';

  @override
  String get fixedDuration => '固定';

  @override
  String get font => 'フォント';

  @override
  String get forestTheme => 'フォレスト';

  @override
  String get forestThemeDesc => '自然な緑のテーマ';

  @override
  String get forever => '無期限';

  @override
  String get frequency => '頻度';

  @override
  String get fullName => 'フルネーム';

  @override
  String get fullScreen => '全画面';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get general => '一般';

  @override
  String get generalNotifications => '一般通知';

  @override
  String get glasses => 'グラス';

  @override
  String get goldenTheme => 'ゴールデン';

  @override
  String get goldenThemeDesc => '暖かい金色のテーマ';

  @override
  String get greetingAfternoon => 'こんにちは';

  @override
  String get greetingEvening => 'こんばんは';

  @override
  String get greetingMorning => 'おはようございます';

  @override
  String get habit => '習慣';

  @override
  String get habitDescription => '説明';

  @override
  String get habitDetails => '習慣の詳細';

  @override
  String get habitName => '習慣名';

  @override
  String get habitOfThisVision => 'このビジョンの習慣';

  @override
  String get habits => '習慣';

  @override
  String get hard => '難しい';

  @override
  String get headerFocusLabel => '集中';

  @override
  String get headerFocusReady => '準備完了';

  @override
  String get headerHabitsLabel => '習慣';

  @override
  String get health => '健康';

  @override
  String get hours => '時間';

  @override
  String get howOftenDoHabit => '習慣をどのくらいの頻度で行うか決めてください';

  @override
  String get howToEarn => '獲得方法';

  @override
  String get howToTrackHabit => '習慣をどのように追跡するかを選択します';

  @override
  String get ifCondition => 'もし';

  @override
  String get importFromLink => 'リンクからインポート';

  @override
  String get incomeDelta => '収入Δ';

  @override
  String get incomeEditTitle => '収入を編集';

  @override
  String get incomeLabel => '収入';

  @override
  String get incomeNewTitle => '新しい収入';

  @override
  String get input => '入力';

  @override
  String get invalidLink => '無効なリンクです。';

  @override
  String get language => '言語';

  @override
  String get languageSelection => '言語選択';

  @override
  String levelLabel(Object level) {
    return 'レベル$level';
  }

  @override
  String levelShort(Object level) {
    return 'L$level';
  }

  @override
  String get lightTheme => 'ライトテーマ';

  @override
  String get linkHabits => '習慣をリンク';

  @override
  String get listLabel => 'リスト';

  @override
  String get loadingHabits => '習慣を読み込み中...';

  @override
  String get logout => 'ログアウト';

  @override
  String get manageLists => 'リストを管理';

  @override
  String get medium => '普通';

  @override
  String get mindfulness => 'マインドフルネス';

  @override
  String get minutes => '分';

  @override
  String get minutesSuffixShort => '分';

  @override
  String get monthCount => '月数';

  @override
  String get monthCountHint => '例: 12';

  @override
  String get monthSuffixShort => '月';

  @override
  String get monthly => '毎月';

  @override
  String get monthlyTrend => '月間トレンド';

  @override
  String get mood => '気分';

  @override
  String get moodBad => '悪い';

  @override
  String get moodGood => '良い';

  @override
  String get moodGreat => '最高';

  @override
  String get moodOk => '普通';

  @override
  String get moodTerrible => '最悪';

  @override
  String get mtdAverageShort => '月間平均';

  @override
  String get multiple => '複数';

  @override
  String get mysticTheme => 'ミスティック';

  @override
  String get mysticThemeDesc => '神秘的な紫のテーマ';

  @override
  String nDaysLabel(Object count) {
    return '$count日間';
  }

  @override
  String get nameHint => '例: 毎日のトレーニング';

  @override
  String get newCategory => '新しいカテゴリ';

  @override
  String get newHabits => '新しい習慣';

  @override
  String get next => '次へ';

  @override
  String get nextLabel => '次へ';

  @override
  String get nextYear => '来年';

  @override
  String get noDataLast7Days => '過去7日間のデータがありません';

  @override
  String get noDataThisMonth => '今月のデータがありません';

  @override
  String get noEndDate => '終了日なし';

  @override
  String get noEndDayDefaultsDaily => '終了日が設定されていない場合、この習慣はデフォルトで毎日表示されます。';

  @override
  String get noEntriesYet => 'まだエントリがありません';

  @override
  String get noExpenseInThisCategory => 'このカテゴリには支出がありません';

  @override
  String get noExpenses => '支出がありません';

  @override
  String get noExpensesThisMonth => '今月の支出はありません';

  @override
  String get noHabitsAddedYet => 'まだ習慣が追加されていません。';

  @override
  String get noIncomeThisMonth => '今月の収入はありません';

  @override
  String get noLinkedHabitsInVision => 'このビジョンにリンクされた習慣はありません。';

  @override
  String get noReadyVisionsFound => '既製のビジョンが見つかりません。';

  @override
  String get noRecordsThisMonth => '今月の記録はありません';

  @override
  String get notAddedYet => 'まだ追加されていません。';

  @override
  String get notUnlocked => 'ロックされていない';

  @override
  String get noteOptional => 'メモ（任意）';

  @override
  String get notifications => '通知';

  @override
  String get numberLabel => '数値';

  @override
  String get numericExample => '1日に8杯の水を飲む';

  @override
  String get numericSettings => '数値目標設定';

  @override
  String get numericalDescription => '数値目標の追跡';

  @override
  String get numericalGoalShort => '数値目標';

  @override
  String get numericalType => '数値';

  @override
  String get oceanTheme => 'オーシャン';

  @override
  String get oceanThemeDesc => '穏やかな青いテーマ';

  @override
  String get onDailyLimit => '1日の制限に達しました。';

  @override
  String get onPeriodic => '特定の間隔で';

  @override
  String get onSpecificMonthDays => '特定の月の日に';

  @override
  String get onSpecificWeekdays => '特定の曜日に';

  @override
  String get onSpecificYearDays => '特定の年の日に';

  @override
  String get once => '1回';

  @override
  String get other => 'その他';

  @override
  String get outline => 'アウトライン';

  @override
  String get outlineColor => 'アウトラインの色';

  @override
  String get pages => 'ページ';

  @override
  String get pause => '一時停止';

  @override
  String get periodicSelection => '定期的な選択';

  @override
  String get pickTodaysMood => '今日の気分を選択';

  @override
  String get plannedMonthlySpend => '計画された月間支出';

  @override
  String get plateColor => 'プレートの色';

  @override
  String get previous => '前へ';

  @override
  String get previousYear => '前年';

  @override
  String get privacySecurity => 'プライバシーとセキュリティ';

  @override
  String get productivity => '生産性';

  @override
  String get profile => 'プロファイル';

  @override
  String get profileInfo => 'プロフィール情報';

  @override
  String get profileUpdated => 'プロフィールが更新されました';

  @override
  String get readyVisionsLoadFailed => '既製のビジョンを読み込めませんでした。';

  @override
  String get recurringMonthlyDesc => '選択した日に毎月自動的に追加';

  @override
  String get recurringMonthlyTitle => '定期的（毎月）';

  @override
  String get reload => '再読み込み';

  @override
  String get remainingToday => '今日残り';

  @override
  String get reminderFrequency => 'リマインダーの頻度';

  @override
  String get reminderSettings => 'リマインダー設定';

  @override
  String get reminderTime => 'リマインダー時間';

  @override
  String get repeatEveryDay => '毎日繰り返す';

  @override
  String get repeatEveryNDays => 'N日ごとに繰り返す';

  @override
  String get reset => 'リセット';

  @override
  String get retry => '再試行';

  @override
  String ruleEnteredDurationAtLeast(Object target) {
    return 'ルール: 入力期間 ≥ $target';
  }

  @override
  String ruleEnteredDurationAtMost(Object target) {
    return 'ルール: 入力期間 ≤ $target';
  }

  @override
  String ruleEnteredDurationExactly(Object target) {
    return 'ルール: 入力期間 = $target';
  }

  @override
  String ruleEnteredValueAtLeast(Object target) {
    return 'ルール: 入力値 ≥ $target';
  }

  @override
  String ruleEnteredValueAtMost(Object target) {
    return 'ルール: 入力値 ≤ $target';
  }

  @override
  String ruleEnteredValueExactly(Object target) {
    return 'ルール: 入力値 = $target';
  }

  @override
  String get save => '保存';

  @override
  String get saved => '保存済み';

  @override
  String get savingsBudgetPlan => '貯蓄・予算計画';

  @override
  String get scheduleHabit => '習慣のスケジュールを設定';

  @override
  String get scheduleLabel => 'スケジュール';

  @override
  String get schedulingOptions => 'スケジュールオプション';

  @override
  String get seconds => '秒';

  @override
  String get select => '選択';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get selectCategory => 'カテゴリを選択';

  @override
  String get selectDate => '日付を選択';

  @override
  String get selectEndDate => '終了日を選択';

  @override
  String get selectFrequency => '頻度を選択';

  @override
  String get selectHabitType => '習慣タイプを選択';

  @override
  String get sendBackward => '背面へ移動';

  @override
  String get settings => '設定';

  @override
  String get shareAsLink => 'リンクとして共有';

  @override
  String get shareLinkCopied => '共有リンクがクリップボードにコピーされました。';

  @override
  String get shareVision => 'ビジョンを共有';

  @override
  String get social => 'ソーシャル';

  @override
  String get soundAlerts => '音声アラート';

  @override
  String get specificDaysOfMonth => '特定の月の日にち';

  @override
  String get specificDaysOfWeek => '特定の曜日';

  @override
  String get specificDaysOfYear => '特定の年の日にち';

  @override
  String spendingLessThanDailyAvg(Object amount) {
    return '素晴らしい！1日の平均より$amount少なく使っています。';
  }

  @override
  String spendingMoreThanDailyAvg(Object amount) {
    return '警告！1日の平均より$amount多く使っています。';
  }

  @override
  String get start => '開始';

  @override
  String get startDate => '開始日';

  @override
  String get startDayLabel => '開始日（1-365）';

  @override
  String get statusLabel => 'ステータス';

  @override
  String get step => 'ステップ';

  @override
  String stepOf(Object current, Object total) {
    return '$total中のステップ$current';
  }

  @override
  String get steps => 'ステップ';

  @override
  String streakDays(Object count) {
    return '$count日間の連続記録';
  }

  @override
  String get streakIndicator => '連続記録インジケーター';

  @override
  String get streakIndicatorDesc => '炎と氷のエフェクトを表示';

  @override
  String successfulDaysCount(Object count) {
    return '$count回の成功日';
  }

  @override
  String get systemTheme => 'システムテーマ';

  @override
  String get targetDurationMinutes => '目標期間（分）';

  @override
  String targetShort(Object value) {
    return '目標: $value';
  }

  @override
  String get targetType => '目標タイプ';

  @override
  String get targetValue => '目標値';

  @override
  String get targetValueLabel => '目標値';

  @override
  String get taskDescription => '説明（任意）';

  @override
  String get taskTitle => 'タスクタイトル';

  @override
  String get templateDetailsNotFound => 'テンプレートの詳細が見つかりません';

  @override
  String get templatesTabManual => '手動';

  @override
  String get templatesTabReady => '既製';

  @override
  String get enterPromoCode => 'Please enter a promo code';

  @override
  String get promoCodeSuccess =>
      '🎉 Promo code applied successfully! Premium access activated.';

  @override
  String get promoCodeAlreadyUsed =>
      'A promo code has already been used on this account.';

  @override
  String get promoCodeInvalid =>
      'Invalid promo code. Please check and try again.';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get promoCodeLabel => 'Promo Code';

  @override
  String get promoCodeActiveMessage =>
      'Your Premium access is activated via promo code ✨';

  @override
  String get promoCodeHint => 'Enter your promo code';

  @override
  String get applying => 'Applying...';

  @override
  String get applyCode => 'Apply Code';

  @override
  String get visionSettingsTooltip => 'Freeform board settings';

  @override
  String get visionBoardViewTooltip => 'Board view';

  @override
  String get visionFreeformTooltip => 'Freeform board';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get selectMonthTooltip => 'Select month';

  @override
  String get analysisTooltip => 'Analysis';

  @override
  String get shareBoard => 'Share board';

  @override
  String get roundCorners => 'Round Corners';

  @override
  String get showText => 'Show text';

  @override
  String get showProgress => 'Show progress';

  @override
  String get myBoard => 'My Board';

  @override
  String get textLabel => 'テキスト';

  @override
  String get theme => 'テーマ';

  @override
  String get themeDetails => 'テーマ詳細';

  @override
  String get themeSelection => 'テーマ選択';

  @override
  String get thisMonth => '今月';

  @override
  String get timerCreateTimerHabitFirst => '最初にタイマー習慣を作成してください';

  @override
  String get timerDescription => '時間ベースの追跡';

  @override
  String get timerExample => '30分のトレーニングをする';

  @override
  String get timerHabitLabel => 'タイマー習慣';

  @override
  String timerPendingDurationLabel(Object duration) {
    return '保留中の期間: $duration';
  }

  @override
  String timerPendingLabel(Object duration) {
    return '保留中: $duration';
  }

  @override
  String get timerPomodoroBreakPhase => '休憩';

  @override
  String timerPomodoroCompletedWork(Object count) {
    return '完了した作業: $count';
  }

  @override
  String get timerPomodoroLongBreakIntervalLabel => '長い休憩のサイクル（例: 4）';

  @override
  String get timerPomodoroLongBreakMinutesLabel => '長い休憩（分）';

  @override
  String get timerPomodoroSettings => 'ポモドーロ設定';

  @override
  String get timerPomodoroShortBreakMinutesLabel => '短い休憩（分）';

  @override
  String get timerPomodoroSkipPhase => 'フェーズをスキップ';

  @override
  String get timerPomodoroWorkMinutesLabel => '作業（分）';

  @override
  String get timerPomodoroWorkPhase => '作業';

  @override
  String get timerSaveDurationTitle => '期間を保存';

  @override
  String get timerSaveSessionTitle => 'セッションを保存';

  @override
  String get timerQuickPresets => 'Quick Presets';

  @override
  String get timerSessionAlreadySaved => 'このセッションは既に保存されています';

  @override
  String get totalDuration => '合計期間';

  @override
  String get timerSetDurationFirst => '最初に期間を設定してください';

  @override
  String get timerSettings => 'タイマー設定';

  @override
  String get timerTabCountdown => 'カウントダウン';

  @override
  String get timerTabPomodoro => 'ポモドーロ';

  @override
  String get timerTabStopwatch => 'ストップウォッチ';

  @override
  String get timerType => 'タイマー';

  @override
  String get checkboxType => 'Checkbox';

  @override
  String get subtasksType => 'Subtasks';

  @override
  String get times => '回';

  @override
  String get titleHint => '例: 食料品、フリーランスなど';

  @override
  String get titleOptional => 'タイトル（任意）';

  @override
  String get typeLabel => 'タイプ';

  @override
  String get unit => '単位';

  @override
  String get unitHint => '単位（グラス、ステップ、ページ...）';

  @override
  String get update => '更新';

  @override
  String get vision => 'ビジョン';

  @override
  String visionAutoDurationInfo(Object day) {
    return 'このビジョンはテンプレートの最終日を使用します: $day。';
  }

  @override
  String get visionCreateTitle => 'ビジョンを作成';

  @override
  String get visionDurationNote =>
      '注意: ビジョンが開始されると、合計期間が設定されます。終了日がこの期間を超える場合、自動的に短縮されます。';

  @override
  String get visionEditTitle => 'ビジョンを編集';

  @override
  String get visionEndDayInvalid => '終了日は1から365の間でなければなりません';

  @override
  String get visionEndDayLess => '終了日は開始日より前にすることはできません';

  @override
  String get visionEndDayQuestion => 'ビジョンの何日目に終了しますか？';

  @override
  String get visionEndDayRequired => '終了日を入力してください';

  @override
  String get visionNoEndDurationInfo => '終了日が指定されていません。ビジョンは無期限で開始されます。';

  @override
  String get visionPlural => 'ビジョン';

  @override
  String get visionStartDayInvalid => '開始日は1から365の間でなければなりません';

  @override
  String get visionStartDayQuestion => 'ビジョンの何日目に開始しますか？';

  @override
  String get visionDurationDaysLabel => '期間（日数）';

  @override
  String get visionStartFailed => 'ビジョンを開始できませんでした。';

  @override
  String visionStartedMessage(Object title) {
    return 'ビジョンが開始されました: $title';
  }

  @override
  String get visionStartLabel => 'Vision start: ';

  @override
  String get visual => 'ビジュアル';

  @override
  String get weekdaysShortFri => '金';

  @override
  String get weekdaysShortMon => '月';

  @override
  String get fortuneTitle => '運勢たまご';

  @override
  String get fortuneQuestionPrompt => '質問を入力してください';

  @override
  String get fortuneQuestionHint => '何を知りたいですか？';

  @override
  String get fortuneEggsSubtitle => 'たまごを選んで運勢を見る';

  @override
  String get fortuneResultTitle => 'あなたの運勢';

  @override
  String get fortuneNoQuestion => 'まだ質問をしていません';

  @override
  String get fortuneDisclaimer => '占いはエンターテインメント目的のみです';

  @override
  String fortuneEggSemantic(int index) {
    return '運勢たまご $index';
  }

  @override
  String get fortunePlay => '遊ぶ';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get ok => 'OK';

  @override
  String get weekdaysShortSat => '土';

  @override
  String get weekdaysShortSun => '日';

  @override
  String get weekdaysShortThu => '木';

  @override
  String get weekdaysShortTue => '火';

  @override
  String get weekdaysShortWed => '水';

  @override
  String get weekly => '毎週';

  @override
  String get weeklyEmailSummary => '週間メール要約';

  @override
  String get weeklySummaryEmail => '週間サマリーメール';

  @override
  String get whichDaysActive => 'どの日をアクティブにしますか？';

  @override
  String get whichMonthDays => '月のどの日ですか？';

  @override
  String get whichWeekdays => 'どの曜日ですか？';

  @override
  String get worldTheme => 'ワールド';

  @override
  String get worldThemeDesc => 'すべての色の調和';

  @override
  String xpProgressSummary(Object current, Object toNext, Object total) {
    return '$current / $total XP • 次のレベルまで$toNext XP';
  }

  @override
  String get yesNoDescription => '単純なはい/いいえの追跡';

  @override
  String get yesNoExample => '今日瞑想しましたか？';

  @override
  String get yesNoType => 'はい/いいえ';

  @override
  String get analysis => '分析';

  @override
  String get apply => '適用';

  @override
  String get clearFilters => 'フィルターをクリア';

  @override
  String get simpleTypeShort => '単純';

  @override
  String get completedSelectedDay => '完了（選択日）';

  @override
  String get incompleteSelectedDay => '未完了（選択日）';

  @override
  String get manageListsSubtitle => '新しいリストの追加、名前の変更、削除を行います。';

  @override
  String get editListTitle => 'リストを編集';

  @override
  String get listNameLabel => 'リスト名';

  @override
  String get deleteListTitle => 'リストを削除';

  @override
  String get deleteListMessage => 'このリストは削除されます。リンクされたアイテムの処理を選択してください:';

  @override
  String get unassignLinkedHabits => 'リンクされた習慣の割り当てを解除';

  @override
  String get unassignLinkedDailyTasks => 'リンクされた日課の割り当てを解除';

  @override
  String listCreatedMessage(Object title) {
    return 'リストが作成されました: $title';
  }

  @override
  String get removeFromList => 'リストから削除';

  @override
  String get createNewList => '新しいリストを作成';

  @override
  String get dailyTasksSection => '日課';

  @override
  String get addToList => 'リストに追加';

  @override
  String get deleteTaskConfirmTitle => 'タスクを削除しますか？';

  @override
  String get deleteTaskConfirmMessage => 'この日課を削除しますか？この操作は元に戻すことができます。';

  @override
  String get undo => '元に戻す';

  @override
  String get habitsSection => '習慣';

  @override
  String get noItemsMatchFilters => '選択したフィルターに一致するアイテムがありません';

  @override
  String dailyTaskCreatedMessage(Object title) {
    return '日課が作成されました: $title';
  }

  @override
  String habitDeletedMessage(Object title) {
    return '習慣が削除されました: $title';
  }

  @override
  String habitCreatedMessage(Object title) {
    return '習慣が作成されました: $title';
  }

  @override
  String deleteHabitConfirm(Object title) {
    return '習慣「$title」を削除しますか？';
  }

  @override
  String get enterValueTitle => '値を入力';

  @override
  String get valueLabel => '値';

  @override
  String get currentStreak => '現在の連続記録';

  @override
  String get longestStreak => '最長連続記録';

  @override
  String daysCount(Object count) {
    return '$count日間';
  }

  @override
  String get success => '成功';

  @override
  String get successfulDayLegend => '成功した日';

  @override
  String get privacySecuritySubtitle =>
      'Manage settings and data deletion options';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get reportBug => 'Report Bug';

  @override
  String get reportBugSubtitle => 'Report issues you encounter';

  @override
  String get reportBugDescription =>
      'Describe the issue you encountered in detail below.';

  @override
  String get yourEmailAddress => 'Your Email Address';

  @override
  String get issueDescription => 'Issue Description';

  @override
  String get issueDescriptionHint => 'Describe the issue in detail...';

  @override
  String get send => 'Send';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get bugReportSentSuccess =>
      'Your bug report has been sent successfully. Thank you!';

  @override
  String bugReportFailedStatus(Object statusCode) {
    return 'Failed to send bug report: $statusCode';
  }

  @override
  String bugReportFailedError(Object error) {
    return 'Failed to send bug report: $error';
  }

  @override
  String get resetOnboardingTitle => 'Reset Onboarding?';

  @override
  String get resetOnboardingDescription =>
      'This will clear your current personality results and let you retake the quiz.';

  @override
  String get resetAction => 'Reset';

  @override
  String get deleteAllDataConfirmContent =>
      'Are you sure you want to delete all your app data? This action cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get allDataDeleted => 'All data deleted';

  @override
  String get diagnosticsData => 'Diagnostics data';

  @override
  String get diagnosticsDataSubtitle => 'Share anonymous usage statistics';

  @override
  String get crashReports => 'Crash reports';

  @override
  String get crashReportsSubtitle => 'Send anonymous reports on app crashes';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get stopwatchLabel => 'STOPWATCH';

  @override
  String get runningLabel => 'RUNNING';

  @override
  String get countdownLabel => 'COUNTDOWN';

  @override
  String get focusLabel => 'FOCUS';

  @override
  String get breakLabel => 'BREAK';

  @override
  String get minLabel => 'min';

  @override
  String get emojiCategoryPopular => 'Popular';

  @override
  String get emojiCategoryHealth => 'Health';

  @override
  String get emojiCategorySport => 'Sport';

  @override
  String get emojiCategoryLife => 'Life';

  @override
  String get emojiCategoryProductivity => 'Productivity';

  @override
  String get emojiCategoryFood => 'Food';

  @override
  String get emojiCategoryNature => 'Nature';

  @override
  String get emojiCategoryAnimals => 'Animals';

  @override
  String get emojiCategoryCare => 'Care';

  @override
  String get habitTypeLabel => 'Habit Type';

  @override
  String get nameLabel => 'Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get optionalLabel => 'optional';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get dateRangeLabel => 'Date Range';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get advancedHabitTitle => 'Advanced Habit';

  @override
  String get habitNamePlaceholder => 'Habit Name';

  @override
  String get numericTypeDesc => 'Number tracking';

  @override
  String get checkboxTypeDesc => 'Simple check';

  @override
  String get subtasksTypeDesc => 'Multi-task';

  @override
  String get selectEmoji => 'Select Emoji';

  @override
  String get customEmoji => 'Custom Emoji';

  @override
  String get typeEmojiHint => 'Type an emoji from keyboard';

  @override
  String get everyDay => 'Every day';

  @override
  String get periodic => '定期的';

  @override
  String get everyLabel => 'Every';

  @override
  String get daysIntervalLabel => 'days';

  @override
  String get offLabel => 'Off';

  @override
  String get completeAllSubtasksToFinish => 'complete all to finish habit';

  @override
  String subtaskIndex(Object index) {
    return 'Subtask $index';
  }

  @override
  String get addSubtask => 'Add Subtask';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get createHabitAction => 'Create Habit';

  @override
  String get selectDuration => 'Select Duration';

  @override
  String selectedDaysOfMonth(Object sorted) {
    return 'Days $sorted of the month';
  }

  @override
  String everyXDays(Object periodicDays) {
    return 'Every $periodicDays days';
  }

  @override
  String get startDateLabel => 'Start';

  @override
  String get endDateLabel => 'End';

  @override
  String get notSelected => 'Not selected';

  @override
  String get motivation => 'モチベーション';

  @override
  String motivationBody(Object percent, Object period) {
    return '素晴らしい！$period、あなたは$percent%の成功率を達成しました。';
  }

  @override
  String get weeklyProgress => '週間進捗';

  @override
  String get monthlyProgress => '月間進捗';

  @override
  String get yearlyProgress => '年間進捗';

  @override
  String get overall => '全体';

  @override
  String get overallProgress => '全体の進捗';

  @override
  String get totalSuccessfulDays => '成功した合計日数';

  @override
  String get totalUnsuccessfulDays => '失敗した合計日数';

  @override
  String get totalProgress => '全体の進捗';

  @override
  String get thisWeek => '今週';

  @override
  String get thisYear => '今年';

  @override
  String get badges => 'バッジ';

  @override
  String get yearly => '毎年';

  @override
  String get newList => '新しいリスト';

  @override
  String taskDeletedMessage(Object title) {
    return 'タスクが削除されました: $title';
  }

  @override
  String get clear => 'クリア';

  @override
  String get createHabitTitle => '習慣を作成';

  @override
  String get addDate => '日付を追加';

  @override
  String get listNameHint => '例: 健康';

  @override
  String get taskTitleRequired => 'タスクタイトルは必須です';

  @override
  String get moodFlowTitle => '気分はいかがですか？';

  @override
  String get moodFlowSubtitle => '感情の健康を記録する';

  @override
  String get moodSelection => '気分の選択';

  @override
  String get selectYourCurrentMood => '現在の気分を選択';

  @override
  String get moodTerribleDesc => 'とても落ち込んでいる';

  @override
  String get moodBadDesc => 'つらい時期を過ごしている';

  @override
  String get moodNeutralDesc => '普通';

  @override
  String get moodGoodDesc => '前向きな気分';

  @override
  String get moodExcellentDesc => '素晴らしい気分';

  @override
  String get feelingMoreSpecific => 'もう少し具体的に教えてください';

  @override
  String get selectSubEmotionDesc => 'より具体的な感情を選択';

  @override
  String get whatsTheCause => '原因は何ですか？';

  @override
  String get selectReasonDesc => '気分に影響を与えているものを選択';

  @override
  String get moodNeutral => '普通';

  @override
  String get moodExcellent => '素晴らしい';

  @override
  String get howAreYouFeeling => '気分はいかがですか？';

  @override
  String get selectYourMood => '気分を選択';

  @override
  String get subEmotionSelection => '詳細な感情の選択';

  @override
  String get selectSubEmotion => '詳細な感情を選択';

  @override
  String get subEmotionExhausted => '疲れ果てた';

  @override
  String get subEmotionHelpless => '無力';

  @override
  String get subEmotionHopeless => '絶望的';

  @override
  String get subEmotionHurt => '傷ついた';

  @override
  String get subEmotionDrained => '消耗した';

  @override
  String get subEmotionAngry => '怒っている';

  @override
  String get subEmotionSad => '悲しい';

  @override
  String get subEmotionAnxious => '不安';

  @override
  String get subEmotionStressed => 'ストレスを感じる';

  @override
  String get subEmotionDemoralized => '意気消沈';

  @override
  String get subEmotionIndecisive => '優柔不断';

  @override
  String get subEmotionTired => '疲れた';

  @override
  String get subEmotionOrdinary => '普通';

  @override
  String get subEmotionCalm => '穏やか';

  @override
  String get subEmotionEmpty => '空虚';

  @override
  String get subEmotionHappy => '幸せ';

  @override
  String get subEmotionCheerful => '陽気';

  @override
  String get subEmotionExcited => '興奮している';

  @override
  String get subEmotionEnthusiastic => '熱心';

  @override
  String get subEmotionDetermined => '決意した';

  @override
  String get subEmotionMotivated => 'やる気がある';

  @override
  String get subEmotionAmazing => 'Amazing';

  @override
  String get subEmotionEnergetic => 'Energetic';

  @override
  String get subEmotionPeaceful => 'Peaceful';

  @override
  String get subEmotionGrateful => 'Grateful';

  @override
  String get subEmotionLoving => 'Loving';

  @override
  String get reasonSelection => 'What\'s the reason for this state?';

  @override
  String get selectReason => 'Select reason';

  @override
  String get reasonAcademic => 'Academic';

  @override
  String get reasonWork => '仕事';

  @override
  String get reasonRelationship => 'Relationship';

  @override
  String get reasonFinance => 'Finance';

  @override
  String get reasonHealth => '健康';

  @override
  String get reasonSocial => 'Social';

  @override
  String get reasonPersonalGrowth => 'Personal Growth';

  @override
  String get reasonWeather => 'Weather';

  @override
  String get reasonOther => 'その他';

  @override
  String get journalEntry => 'Journal Entry';

  @override
  String get tellUsMore => 'Tell us more';

  @override
  String get journalEntryDesc =>
      'Is there anything you\'d like to write about today?';

  @override
  String get yourMoodToday => 'Your Mood Today';

  @override
  String get journalHint => 'Something you\'d like to write about today...';

  @override
  String get saving => 'Saving...';

  @override
  String get saveEntry => 'Save Entry';

  @override
  String get entrySaved => 'Entry saved successfully!';

  @override
  String get saveError => 'An error occurred while saving';

  @override
  String get moodFlow => 'Mood';

  @override
  String get moodTracker => 'Mood Tracker';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'スキップ';

  @override
  String get habitNotFound => '習慣が見つかりません。';

  @override
  String get habitUpdatedMessage => '習慣が更新されました。';

  @override
  String get invalidValue => '無効な値';

  @override
  String get nameRequired => '名前は必須です';

  @override
  String get simpleHabitTargetOne => '単純な習慣（目標=1）';

  @override
  String get typeNotChangeable => 'タイプは変更できません';

  @override
  String get onboardingWelcomeTitle => 'Miraへようこそ';

  @override
  String get onboardingWelcomeDesc =>
      'あなたとともに成長するパーソナル習慣トラッカーです。あなたの個性を見つけ、あなたに合った習慣を提案します。';

  @override
  String get onboardingQuizIntro =>
      'あなたの個性をよりよく理解するために、いくつかの質問にお答えください。これは科学的に検証された心理学研究に基づいています。';

  @override
  String get onboardingQ1 => '新しい体験に挑戦し、未知のことを探求するのが好きです。';

  @override
  String get onboardingQ2 => '身の回りを整理整頓し、規則的な日課を好みます。';

  @override
  String get onboardingQ3 => '人と一緒にいると元気が出て、交流の場を楽しみます。';

  @override
  String get onboardingQ4 => '他者と協力して働くことを好み、競争よりも協力の方が効果的だと感じます。';

  @override
  String get onboardingQ5 => 'ストレスの多い状況でも落ち着いて対処し、不安を感じることはほとんどありません。';

  @override
  String get onboardingQ6 => 'アート、音楽、執筆などの創造的な活動を楽しみます。';

  @override
  String get onboardingQ7 => '明確な目標を立て、達成に向けて粘り強く取り組みます。';

  @override
  String get onboardingQ8 => '一人で過ごすよりも、グループでの活動を好みます。';

  @override
  String get onboardingQ9 => '意思決定の前に、相手の気持ちをよく考えます。';

  @override
  String get onboardingQ10 => '重要な出来事やタスクは事前に計画します。';

  @override
  String get onboardingQ11 => '一つの方法にこだわるより、さまざまなアプローチを試すのが好きです。';

  @override
  String get onboardingQ12 => 'プレッシャーの中でも落ち着いて対処し、失敗から素早く立ち直ります。';

  @override
  String get likertStronglyDisagree => '強く反対';

  @override
  String get likertDisagree => '反対';

  @override
  String get likertNeutral => '中立';

  @override
  String get likertAgree => '賛成';

  @override
  String get likertStronglyAgree => '強く賛成';

  @override
  String get characterTypePlanner => 'The Planner';

  @override
  String get characterDescPlanner =>
      'You\'re organized, goal-oriented, and thrive on structure. You excel at turning dreams into actionable plans and following through with discipline.';

  @override
  String get characterTypeExplorer => 'The Explorer';

  @override
  String get characterDescExplorer =>
      'You\'re curious, creative, and love variety. You thrive on learning new things and trying different approaches to life\'s challenges.';

  @override
  String get characterTypeSocialConnector => 'The Social Connector';

  @override
  String get characterDescSocialConnector =>
      'You\'re warm, empathetic, and energized by relationships. You find meaning in connecting with others and building strong communities.';

  @override
  String get characterTypeBalancedMindful => 'The Balanced Mindful';

  @override
  String get characterDescBalancedMindful =>
      'You\'re calm, stable, and value inner peace. You excel at maintaining balance and approaching life with mindfulness and composure.';

  @override
  String get yourCharacterType => 'Your Character Type';

  @override
  String get recommendedHabits => 'Recommended Habits for You';

  @override
  String get selectHabitsToAdd => '日々の習慣に追加したい項目を選んでください:';

  @override
  String get startJourney => 'はじめる';

  @override
  String get skipOnboarding => 'スキップ';

  @override
  String get back => 'Back';

  @override
  String get habitPlannerMorningRoutine => 'Morning Routine';

  @override
  String get habitPlannerMorningRoutineDesc =>
      'Start each day with a structured morning routine to set the tone for productivity.';

  @override
  String get habitPlannerWeeklyReview => 'Weekly Review';

  @override
  String get habitPlannerWeeklyReviewDesc =>
      'Review your week\'s progress and plan for the next week every Sunday.';

  @override
  String get habitPlannerGoalSetting => 'Monthly Goal Setting';

  @override
  String get habitPlannerGoalSettingDesc =>
      'Set specific, measurable goals for the month ahead.';

  @override
  String get habitPlannerTaskPrioritization => 'Daily Task Prioritization';

  @override
  String get habitPlannerTaskPrioritizationDesc =>
      'Identify your top 3 priorities for the day each morning.';

  @override
  String get habitPlannerTimeBlocking => 'Time Blocking';

  @override
  String get habitPlannerTimeBlockingDesc =>
      'Schedule your day in focused time blocks for deep work.';

  @override
  String get habitExplorerLearnNewSkill => 'Learn Something New';

  @override
  String get habitExplorerLearnNewSkillDesc =>
      'Dedicate time each week to learning a new skill or subject.';

  @override
  String get habitExplorerTryNewActivity => 'Try a New Activity';

  @override
  String get habitExplorerTryNewActivityDesc =>
      'Step out of your comfort zone and experience something different.';

  @override
  String get habitExplorerReadDiverse => 'Read Diverse Content';

  @override
  String get habitExplorerReadDiverseDesc =>
      'Read books, articles, or content from different genres and perspectives.';

  @override
  String get habitExplorerCreativeProject => 'Creative Project Time';

  @override
  String get habitExplorerCreativeProjectDesc =>
      'Work on a creative project that sparks your imagination.';

  @override
  String get habitExplorerExplorePlace => 'Explore a New Place';

  @override
  String get habitExplorerExplorePlaceDesc =>
      'Visit a new neighborhood, park, or location in your area.';

  @override
  String get habitSocialCallFriend => 'Call a Friend';

  @override
  String get habitSocialCallFriendDesc =>
      'Reach out to a friend or family member for a meaningful conversation.';

  @override
  String get habitSocialGroupActivity => 'Join Group Activity';

  @override
  String get habitSocialGroupActivityDesc =>
      'Participate in a group activity or social event.';

  @override
  String get habitSocialVolunteer => 'Volunteer';

  @override
  String get habitSocialVolunteerDesc =>
      'Give back to your community through volunteer work.';

  @override
  String get habitSocialFamilyTime => 'Quality Family Time';

  @override
  String get habitSocialFamilyTimeDesc =>
      'Spend dedicated time with family members without distractions.';

  @override
  String get habitSocialCompliment => 'Give a Genuine Compliment';

  @override
  String get habitSocialComplimentDesc =>
      'Brighten someone\'s day with a sincere compliment.';

  @override
  String get habitMindfulMeditation => 'Meditation';

  @override
  String get habitMindfulMeditationDesc =>
      'Practice mindfulness meditation for 10-15 minutes.';

  @override
  String get habitMindfulGratitude => 'Gratitude Practice';

  @override
  String get habitMindfulGratitudeDesc =>
      'Write down three things you\'re grateful for today.';

  @override
  String get habitMindfulNatureWalk => 'Nature Walk';

  @override
  String get habitMindfulNatureWalkDesc =>
      'Take a mindful walk in nature, paying attention to your surroundings.';

  @override
  String get habitMindfulBreathing => 'Deep Breathing Exercise';

  @override
  String get habitMindfulBreathingDesc =>
      'Practice deep breathing techniques to center yourself.';

  @override
  String get habitMindfulJournaling => 'Reflective Journaling';

  @override
  String get habitMindfulJournalingDesc =>
      'Journal your thoughts and reflections for self-awareness.';

  @override
  String habitAddSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits added',
      one: '1 habit added',
      zero: 'No habits added',
    );
    return '$_temp0';
  }

  @override
  String habitAddError(Object error) {
    return 'Error adding habits: $error';
  }

  @override
  String get unlistedItems => 'Unlisted Items';

  @override
  String get unknownList => 'Unknown List';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get restoreLatest => 'Restore Latest';

  @override
  String backupSuccess(Object id) {
    return 'バックアップ完了: $id';
  }

  @override
  String get backupError => 'Backup Error';

  @override
  String restoreSuccess(Object content) {
    return 'ダウンロード完了: $content';
  }

  @override
  String get restoreError => 'Restore Error';

  @override
  String get manageSubscription => 'サブスクリプションの管理';

  @override
  String get manageSubscriptionSubtitle =>
      'Manage Mira Plus subscription via Google Play';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get deleteAccountSubtitle =>
      'Request deletion of your account and data';

  @override
  String get confirmDeleteAccount => 'Confirm Account Deletion';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. Please confirm the email associated with your account.';

  @override
  String get yourEmail => 'Your Email';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get deleteAccountRequestSuccess =>
      'Your account deletion request has been successfully received';

  @override
  String get deleteAccountFailed => 'Account deletion failed';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get retakePersonalityTest => 'Retake Personality Test';

  @override
  String get processingWait => 'Processing, please wait...';

  @override
  String get checkingPurchases => 'Checking purchases...';

  @override
  String get premiumPlans => 'Premium Plans';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get noPlansAvailable => 'No plans available at the moment.';

  @override
  String get cannotOpenPlayStore => 'Cannot open Play Store';

  @override
  String get subscriptionDetails => 'Subscription Details';

  @override
  String get goToPlayStore => 'Go to Play Store';

  @override
  String get becomePremium => 'Become Premium';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get premiumBenefits => 'Premium benefits:';

  @override
  String get later => 'Later';

  @override
  String get becomePremiumShort => 'Get Premium';

  @override
  String get shareDashboard => 'Share Dashboard';

  @override
  String get customUnit => 'Custom Unit';

  @override
  String get pastelColors => 'パステルカラー';

  @override
  String get habitNameHintTimer => '例：瞑想、運動...';

  @override
  String get habitNameHintNumerical => '例：水を飲む、読書...';

  @override
  String get habitDescriptionHint => '短い説明を追加...';

  @override
  String get target => '目標';

  @override
  String get amount => '量';

  @override
  String get custom => 'カスタム';

  @override
  String get customUnitHint => '例：ポーション、セット、km...';

  @override
  String get unitAdet => '個';

  @override
  String get unitBardak => '杯';

  @override
  String get unitSayfa => 'ページ';

  @override
  String get unitKm => 'km';

  @override
  String get unitLitre => 'リットル';

  @override
  String get unitKalori => 'cal';

  @override
  String get unitAdim => '歩';

  @override
  String get unitKez => '回';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get featureAdvancedHabits => 'Gelişmiş Alışkanlık Oluşturma';

  @override
  String get featureVisionCreation => 'Vizyon Oluşturma';

  @override
  String get featureAdvancedFinance => 'Gelişmiş Finans Özellikleri';

  @override
  String get featurePremiumThemes => 'Premium Temalar';

  @override
  String get featureBackup => 'Yedekleme Özelliği';

  @override
  String get perMonth => '/mo';

  @override
  String get perYear => '/yr';

  @override
  String get unlockAllFeatures => 'Unlock all features and remove limits.';

  @override
  String get flexiblePlan => 'Flexible plan, cancel anytime';

  @override
  String get annualPlanDesc => 'Uninterrupted access for 12 months';

  @override
  String get trialInfo => '14-day free trial, cancel anytime.';

  @override
  String get miraPlusActive => 'Mira Plus Active';

  @override
  String get miraPlusInactive => 'Mira Plus Inactive';

  @override
  String get validity => 'Validity';

  @override
  String get daysLeft => 'days left';

  @override
  String get subscribeToEnjoyPremium => 'Subscribe to enjoy premium features';

  @override
  String get advancedAnalysis => 'Advanced Analysis';

  @override
  String get detailedCharts => 'Detailed charts and statistics';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get backupToDrive => 'Backup to Drive';

  @override
  String get adFreeExperience => 'Ad-Free Experience';

  @override
  String get uninterruptedUsage => 'Uninterrupted usage';

  @override
  String get advancedTimer => 'Advanced Timer';

  @override
  String get pomodoroAndCustomTimers => 'Pomodoro and custom timers';

  @override
  String get personalizedInsights => 'Personalized Insights';

  @override
  String get aiPoweredRecommendations => 'AI powered recommendations';

  @override
  String get buyPremium => 'Buy Premium';

  @override
  String get manageOnGooglePlay => 'Manage on Google Play';

  @override
  String get manageSubscriptionDesc =>
      'Change plan, cancel or view billing info';

  @override
  String get billingHistory => 'Billing History';

  @override
  String get viewInvoicesOnPlayStore =>
      'View your invoices on Google Play Store';

  @override
  String get seeFullSubscriptionInfo => 'See full subscription info';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get howToCancel => 'How to cancel?';

  @override
  String get cancelInstructions =>
      'Google Play Store → Subscriptions → Mira Plus → Cancel';

  @override
  String get whatHappensIfCancel => 'What happens if I cancel?';

  @override
  String get cancelEffect =>
      'You continue to enjoy premium features until your subscription ends.';

  @override
  String get ifTrialCancelled => 'If free trial is cancelled?';

  @override
  String get trialCancelEffect =>
      'If you cancel during the free trial, you won\'t be charged immediately.';

  @override
  String get canIGetRefund => 'Can I get a refund?';

  @override
  String get refundPolicy =>
      'Refund requests are subject to Google Play policies. You can apply from Play Store.';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get daysRemaining => 'Days Remaining';

  @override
  String get usePlayStoreToManage =>
      'Use Google Play Store to manage your subscription.';

  @override
  String get thisFeatureIsPremium => 'This feature is Premium';

  @override
  String get mustBePremiumToUse =>
      'You must be a Premium subscriber to use this feature.';

  @override
  String get advancedAnalysisAndReports => 'Advanced analysis and reports';

  @override
  String get unlimitedDataStorage => 'Unlimited data storage';

  @override
  String get freeTrial14Days => '14-day free trial';

  @override
  String get backupFailed => 'バックアップに失敗しました';

  @override
  String get restoreFailed => '復元に失敗しました';

  @override
  String plansLoadError(Object error) {
    return 'プランの読み込みエラー: $error';
  }

  @override
  String get optional => 'optional';

  @override
  String get newHabit => 'New Habit';

  @override
  String get typeEmoji => 'Type an emoji from keyboard';

  @override
  String get habitNameHint => 'Ex: Drink water, Read book...';

  @override
  String get weekDaysShort => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String get every => 'Every';

  @override
  String get daysInterval => 'days';

  @override
  String get today => 'Today';

  @override
  String get monthsShort => 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysLater(Object days) {
    return '$days days later';
  }

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get off => 'Off';

  @override
  String get createHabit => 'Create Habit';

  @override
  String get pickTime => 'Pick Time';

  @override
  String monthlyDays(Object days) {
    return 'Days $days of the month';
  }

  @override
  String get signInFailed => 'Sign in failed. Please try again.';

  @override
  String get signInWithGoogleTitle => 'Sign in with Google';

  @override
  String get signInWithGoogleDesc =>
      'Connect your Google account to continue. Your profile info will be filled automatically.';

  @override
  String get signInWithGoogleButton => 'Sign in with Google';

  @override
  String get startTestTitle => 'Do you want to start the personality test?';

  @override
  String get startTestDesc =>
      'If you complete the test, you will get personalized suggestions and habit recommendations. You can skip this step if you wish.';

  @override
  String get skipTest => 'Skip Test';

  @override
  String get startTest => 'Start Test';

  @override
  String get backupTitle => 'Backup';

  @override
  String get jsonDataExample => 'JSON Data (example):';

  @override
  String get refreshList => 'Refresh List';

  @override
  String get noBackupsFound => 'No backups found.';

  @override
  String get unnamedBackup => 'unnamed';

  @override
  String get restore => 'Restore';

  @override
  String get financeNet => 'Net';

  @override
  String get durationIndefinite => 'Indefinite';

  @override
  String durationMonths(Object count) {
    return '$count months';
  }

  @override
  String get fortuneProceedToEggs => 'Proceed to Eggs';

  @override
  String get fortuneSwipeInstruction =>
      'Swipe left/right to change the egg, tap to reveal the answer';

  @override
  String listCreated(Object title) {
    return 'List created: $title';
  }

  @override
  String get moodAnalytics => 'Mood Analytics';

  @override
  String get overview => 'Overview';

  @override
  String get trends => 'Trends';

  @override
  String get history => 'History';

  @override
  String get noMoodData => 'No mood data yet';

  @override
  String get startTrackingMood => 'Start tracking your mood to see analytics';

  @override
  String get totalEntries => 'Total Entries';

  @override
  String get averageMood => '平均的な気分';

  @override
  String get moodDistribution => 'Mood Distribution';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get mostCommonMood => 'Most Common Mood';

  @override
  String get mostCommonEmotion => 'Most Common Emotion';

  @override
  String get mostCommonReason => 'Most Common Reason';

  @override
  String get moodTrend => 'Mood Trend (Last 30 Days)';

  @override
  String get noTrendData => 'Not enough data for trends';

  @override
  String get insights => 'Insights';

  @override
  String get moodImproving => 'Your mood is improving!';

  @override
  String get moodDeclining => 'Your mood seems to be declining';

  @override
  String get moodStable => 'Your mood is relatively stable';

  @override
  String get noHistory => '履歴なし';

  @override
  String get open => 'Open';

  @override
  String get openNotificationSettings => 'Open notification settings';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get openBatteryOptimization => 'Open battery optimization';

  @override
  String get habitReminderBody => 'Time to complete your habit!';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerStop => 'Stop';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get miraPremium => 'Mira Premium';

  @override
  String get visionTasks => 'Tasks';

  @override
  String get addTask => 'タスクを追加';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskPending => 'Pending';

  @override
  String get noTasksYet => 'No tasks added yet';

  @override
  String get deleteTaskConfirm => 'Are you sure you want to delete this task?';

  @override
  String get taskAdded => 'Task added';

  @override
  String get manageVisionTasks => 'Manage Tasks';
}
