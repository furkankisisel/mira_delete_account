// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get about => '정보';

  @override
  String get account => '계정';

  @override
  String get achievements => '성취';

  @override
  String get activeDays => '활성일';

  @override
  String get add => '추가';

  @override
  String get addHabit => '습관 추가';

  @override
  String get addImage => '이미지 추가';

  @override
  String get addNew => '새로 추가';

  @override
  String get addNewHabit => '새 습관 추가';

  @override
  String get addSpecialDays => '특별한 날 추가';

  @override
  String get addText => '텍스트 추가';

  @override
  String get advancedHabit => '고급 습관';

  @override
  String get allLabel => '모두';

  @override
  String get alsoDeleteLinkedHabits => '연결된 습관도 삭제';

  @override
  String get amountLabel => '금액';

  @override
  String get socialFeedTitle => 'Feed';

  @override
  String get spendingAdvisorTitle => '지출 조언자';

  @override
  String spendingAdvisorSafe(Object amount) {
    return '하루에 $amount을(를) 사용할 수 있습니다.';
  }

  @override
  String spendingAdvisorWarning(Object amount) {
    return '목표를 유지하려면 일일 지출을 $amount 줄이세요.';
  }

  @override
  String get spendingAdvisorOnTrack => '훌륭합니다! 예산 계획대로 진행되고 있습니다.';

  @override
  String get spendingAdvisorOverBudget => '예산을 초과했습니다. 지출을 중단하세요.';

  @override
  String get spendingAdvisorNoBudget => '조언을 받으려면 예산을 설정하세요.';

  @override
  String get appTitle => 'Mira';

  @override
  String get appearance => '외관';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get notificationSettingsSubtitle => '알림 환경설정을 구성합니다';

  @override
  String get enableNotifications => '알림 사용';

  @override
  String get notificationsMasterSubtitle => '모든 앱 알림 관리';

  @override
  String get notificationTypes => '알림 유형';

  @override
  String get habitReminders => '습관 알림';

  @override
  String get habitRemindersSubtitle => '습관에 대한 일일 알림';

  @override
  String get notificationBehavior => '알림 동작';

  @override
  String get sound => '소리';

  @override
  String get soundSubtitle => '알림 시 소리 재생';

  @override
  String get vibration => '진동';

  @override
  String get vibrationSubtitle => '알림 시 진동';

  @override
  String get systemInfo => '시스템 정보';

  @override
  String get timezone => '시간대';

  @override
  String get notificationPermission => '알림 권한';

  @override
  String get exactAlarmPermission => '정확한 알람 권한 (Android 12+)';

  @override
  String get granted => '허용됨';

  @override
  String get notGranted => '허용 안 됨';

  @override
  String get importantNotice => '중요 공지';

  @override
  String get notificationTroubleshooting =>
      '알림이 제대로 작동하려면:\n\n• 배터리 최적화를 끄세요\n• 백그라운드 활동을 허용하세요\n• 알림 권한이 켜져 있는지 확인하세요\n• \'방해 금지\' 모드를 확인하세요';

  @override
  String approxVisionDurationDays(Object days) {
    return '이 비전은 약 $days일 동안 지속됩니다';
  }

  @override
  String get assetsReloadHint => '일부 자산을 로드하려면 앱을 완전히 다시 시작해야 할 수 있습니다.';

  @override
  String get atLeast => '최소';

  @override
  String get atMost => '최대';

  @override
  String get backgroundPlate => '배경 플레이트';

  @override
  String get badgeActive100dDesc => '100일 동안 활동';

  @override
  String get badgeActive100dTitle => '100일 활동';

  @override
  String get badgeActive30dDesc => '30일 동안 활동';

  @override
  String get badgeActive30dTitle => '30일 활동';

  @override
  String get badgeActive7dDesc => '7일 동안 활동';

  @override
  String get badgeActive7dTitle => '7일 활동';

  @override
  String get badgeCategoryActivity => '활동';

  @override
  String get badgeCategoryFinance => '금융';

  @override
  String get badgeCategoryHabit => '습관';

  @override
  String get badgeCategoryLevel => '레벨';

  @override
  String get badgeCategoryVision => '비전';

  @override
  String get badgeCategoryXp => 'XP';

  @override
  String get badgeFin100Desc => '거래 100건 기록';

  @override
  String get badgeFin100Title => '금융가 100';

  @override
  String get badgeFin10Desc => '거래 10건 기록';

  @override
  String get badgeFin10Title => '금융가 10';

  @override
  String get badgeFin250Desc => '거래 250건 기록';

  @override
  String get badgeFin250Title => '금융가 250';

  @override
  String get badgeFin50Desc => '거래 50건 기록';

  @override
  String get badgeFin50Title => '금융가 50';

  @override
  String get badgeHabit100Desc => '총 100개의 습관 완료';

  @override
  String get badgeHabit100Title => '습관 100';

  @override
  String get badgeHabit10Desc => '총 10개의 습관 완료';

  @override
  String get badgeHabit10Title => '습관 10';

  @override
  String get badgeHabit200Desc => '총 200개의 습관 완료';

  @override
  String get badgeHabit200Title => '습관 200';

  @override
  String get badgeHabit50Desc => '총 50개의 습관 완료';

  @override
  String get badgeHabit50Title => '습관 50';

  @override
  String get badgeLevel10Desc => '레벨 10 도달';

  @override
  String get badgeLevel10Title => '레벨 10';

  @override
  String get badgeLevel20Desc => '레벨 20 도달';

  @override
  String get badgeLevel20Title => '레벨 20';

  @override
  String get badgeLevel5Desc => '레벨 5 도달';

  @override
  String get badgeLevel5Title => '레벨 5';

  @override
  String get badgeVision10Desc => '비전 10개 생성';

  @override
  String get badgeVision10Title => '비전 그랜드마스터';

  @override
  String get badgeVision1Desc => '첫 비전 생성';

  @override
  String get badgeVision1Title => '비전가';

  @override
  String get badgeVision5Desc => '비전 5개 생성';

  @override
  String get badgeVision5Title => '비전 마스터';

  @override
  String get badgeVisionHabits3Desc => '비전에 3개 이상의 습관 연결';

  @override
  String get badgeVisionHabits3Title => '연결자';

  @override
  String get badgeXp1000Desc => '총 1000 XP 획득';

  @override
  String get badgeXp1000Title => '1000 XP';

  @override
  String get badgeXp500Desc => '총 500 XP 획득';

  @override
  String get badgeXp500Title => '500 XP';

  @override
  String get between1And360 => '1에서 360 사이';

  @override
  String get bio => '소개';

  @override
  String get bioHint => '자신에 대한 간략한 소개';

  @override
  String get breakTime => '휴식';

  @override
  String get breakdownByCategory => '카테고리별 분석';

  @override
  String get bringForward => '앞으로 가져오기';

  @override
  String get cancel => '취소';

  @override
  String get category => '카테고리';

  @override
  String get categoryName => '카테고리 이름';

  @override
  String get chooseBestCategory => '습관에 가장 적합한 카테고리를 선택하세요';

  @override
  String get chooseColor => '색상 선택:';

  @override
  String get chooseEmoji => '이모지 선택:';

  @override
  String get clearHistory => '기록 지우기';

  @override
  String get close => '닫기';

  @override
  String get colorLabel => '색상';

  @override
  String get colorTheme => '색상 테마';

  @override
  String get countdownConfigureTitle => '카운트다운 구성';

  @override
  String get create => '생성';

  @override
  String get createAdvancedHabit => '고급 습관 생성';

  @override
  String get createDailyTask => '일일 작업 생성';

  @override
  String get createHabitTemplateTitle => '습관 템플릿 생성';

  @override
  String get createList => '목록 생성';

  @override
  String get createNewCategory => '새 카테고리 생성';

  @override
  String get createVision => '비전 생성';

  @override
  String get createVisionTemplateTitle => '비전 템플릿 생성';

  @override
  String get customCategories => '사용자 지정 카테고리';

  @override
  String get customEmojiHint => '예: ✨';

  @override
  String get customEmojiOptional => '사용자 지정 이모지 (선택 사항)';

  @override
  String get reminder => '알림';

  @override
  String get enableReminder => '알림 활성화';

  @override
  String get selectTime => '시간 선택';

  @override
  String get customFrequency => '사용자 지정';

  @override
  String get daily => '매일';

  @override
  String get dailyCheck => '일일 확인';

  @override
  String get dailyLimit => '일일 한도';

  @override
  String get dailyTask => '일일 작업';

  @override
  String get darkTheme => '다크 테마';

  @override
  String get dashboard => '대시보드';

  @override
  String get date => '날짜';

  @override
  String dayRangeShort(Object end, Object start) {
    return '$start일–$end일';
  }

  @override
  String dayShort(Object day) {
    return '$day일';
  }

  @override
  String daysAverageShort(Object days) {
    return '$days일 평균';
  }

  @override
  String get delete => '삭제';

  @override
  String deleteCategoryConfirmNamed(Object name) {
    return '카테고리 \'$name\'을(를) 삭제하시겠습니까?';
  }

  @override
  String get deleteCategoryTitle => '카테고리 삭제';

  @override
  String get deleteCustomCategoryConfirm => '이 사용자 지정 카테고리를 삭제하시겠습니까?';

  @override
  String get deleteEntryConfirm => '이 항목을 삭제하시겠습니까?';

  @override
  String deleteTransactionConfirm(Object title) {
    return '기록 \'$title\'을(를) 삭제하시겠습니까?';
  }

  @override
  String get deleteVisionMessage => '이 비전을 삭제하시겠습니까?';

  @override
  String get deleteVisionTitle => '비전 삭제';

  @override
  String get descHint => '습관에 대한 세부 정보 (선택 사항)';

  @override
  String get difficulty => '난이도';

  @override
  String get duration => '기간';

  @override
  String get durationAutoLabel => '기간 (자동)';

  @override
  String get durationSelection => '기간 선택';

  @override
  String get durationType => '기간 유형';

  @override
  String get earthTheme => '어스';

  @override
  String get earthThemeDesc => '대지의 색상';

  @override
  String get easy => '쉬움';

  @override
  String get edit => '편집';

  @override
  String get editCategory => '카테고리 편집';

  @override
  String get editHabit => '습관 편집';

  @override
  String get education => '교육';

  @override
  String get emojiLabel => '이모지';

  @override
  String get endDate => '종료일';

  @override
  String get endDayOptionalLabel => '종료일 (선택 사항)';

  @override
  String get enterMonthlyPlanToComputeDailyLimit =>
      '일일 한도를 계산하려면 월간 계획을 입력하세요.';

  @override
  String get enterNameAndDesc => '습관의 이름과 설명을 입력하세요';

  @override
  String get enterYourName => '이름을 입력하세요';

  @override
  String get entries => '항목';

  @override
  String get everyNDaysQuestion => '며칠마다?';

  @override
  String get everyday => '매일';

  @override
  String get exact => '정확히';

  @override
  String examplePrefix(Object example) {
    return '예: $example';
  }

  @override
  String get expenseDelta => '지출 Δ';

  @override
  String get expenseDistributionPie => '지출 분포 (원형)';

  @override
  String get expenseEditTitle => '지출 편집';

  @override
  String get expenseLabel => '지출';

  @override
  String get expenseNewTitle => '새 지출';

  @override
  String failedToLoad(Object error) {
    return '로드 실패: $error';
  }

  @override
  String get filterTitle => '필터';

  @override
  String get finance => '금융';

  @override
  String financeAnalysisTitle(Object month) {
    return '재무 분석 · $month';
  }

  @override
  String get financeLast7Days => '재무 · 지난 7일';

  @override
  String get finish => '완료';

  @override
  String get historyTitle => 'History';

  @override
  String get fitness => '피트니스';

  @override
  String get fixedDuration => '고정';

  @override
  String get font => '글꼴';

  @override
  String get forestTheme => '포레스트';

  @override
  String get forestThemeDesc => '자연스러운 녹색 테마';

  @override
  String get forever => '영원히';

  @override
  String get frequency => '빈도';

  @override
  String get fullName => '전체 이름';

  @override
  String get fullScreen => '전체 화면';

  @override
  String get gallery => '갤러리';

  @override
  String get general => '일반';

  @override
  String get generalNotifications => '일반 알림';

  @override
  String get glasses => '잔';

  @override
  String get goldenTheme => '골든';

  @override
  String get goldenThemeDesc => '따뜻한 금색 테마';

  @override
  String get greetingAfternoon => '안녕하세요';

  @override
  String get greetingEvening => '안녕하세요';

  @override
  String get greetingMorning => '안녕하세요';

  @override
  String get habit => '습관';

  @override
  String get habitDescription => '설명';

  @override
  String get habitDetails => '습관 세부 정보';

  @override
  String get habitName => '습관 이름';

  @override
  String get habitOfThisVision => '이 비전의 습관';

  @override
  String get habits => '습관';

  @override
  String get hard => '어려움';

  @override
  String get headerFocusLabel => '집중';

  @override
  String get headerFocusReady => '준비';

  @override
  String get headerHabitsLabel => '습관';

  @override
  String get health => '건강';

  @override
  String get hours => '시간';

  @override
  String get howOftenDoHabit => '습관을 얼마나 자주 할지 결정하세요';

  @override
  String get howToEarn => '획득 방법';

  @override
  String get howToTrackHabit => '습관을 추적할 방법을 선택하세요';

  @override
  String get ifCondition => '만약';

  @override
  String get importFromLink => '링크에서 가져오기';

  @override
  String get incomeDelta => '소득 Δ';

  @override
  String get incomeEditTitle => '소득 편집';

  @override
  String get incomeLabel => '소득';

  @override
  String get incomeNewTitle => '새 소득';

  @override
  String get input => '입력';

  @override
  String get invalidLink => '잘못된 링크입니다.';

  @override
  String get language => '언어';

  @override
  String get languageSelection => '언어 선택';

  @override
  String levelLabel(Object level) {
    return '레벨 $level';
  }

  @override
  String levelShort(Object level) {
    return 'L$level';
  }

  @override
  String get lightTheme => '라이트 테마';

  @override
  String get linkHabits => '습관 연결';

  @override
  String get listLabel => '목록';

  @override
  String get loadingHabits => '습관 로드 중...';

  @override
  String get logout => '로그아웃';

  @override
  String get manageLists => '목록 관리';

  @override
  String get medium => '보통';

  @override
  String get mindfulness => '마음챙김';

  @override
  String get minutes => '분';

  @override
  String get minutesSuffixShort => '분';

  @override
  String get monthCount => '개월 수';

  @override
  String get monthCountHint => '예: 12';

  @override
  String get monthSuffixShort => '개월';

  @override
  String get monthly => '매월';

  @override
  String get monthlyTrend => '월간 추세';

  @override
  String get mood => '기분';

  @override
  String get moodBad => '나쁨';

  @override
  String get moodGood => '좋음';

  @override
  String get moodGreat => '아주 좋음';

  @override
  String get moodOk => '보통';

  @override
  String get moodTerrible => '끔찍함';

  @override
  String get mtdAverageShort => '월 누계 평균';

  @override
  String get multiple => '다중';

  @override
  String get mysticTheme => '미스틱';

  @override
  String get mysticThemeDesc => '신비로운 보라색 테마';

  @override
  String nDaysLabel(Object count) {
    return '$count일';
  }

  @override
  String get nameHint => '예: 매일 운동';

  @override
  String get newCategory => '새 카테고리';

  @override
  String get newHabits => '새 습관';

  @override
  String get next => '다음';

  @override
  String get nextLabel => '다음';

  @override
  String get nextYear => '내년';

  @override
  String get noDataLast7Days => '지난 7일간 데이터 없음';

  @override
  String get noDataThisMonth => '이번 달 데이터 없음';

  @override
  String get noEndDate => '종료일 없음';

  @override
  String get noEndDayDefaultsDaily => '종료일이 설정되지 않은 경우 이 습관은 기본적으로 매일 나타납니다.';

  @override
  String get noEntriesYet => '아직 항목 없음';

  @override
  String get noExpenseInThisCategory => '이 카테고리에 지출 없음';

  @override
  String get noExpenses => '지출 없음';

  @override
  String get noExpensesThisMonth => '이번 달 지출 없음';

  @override
  String get noHabitsAddedYet => '아직 추가된 습관 없음.';

  @override
  String get noIncomeThisMonth => '이번 달 소득 없음';

  @override
  String get noLinkedHabitsInVision => '이 비전에 연결된 습관 없음.';

  @override
  String get noReadyVisionsFound => '준비된 비전 없음.';

  @override
  String get noRecordsThisMonth => '이번 달 기록 없음';

  @override
  String get notAddedYet => '아직 추가되지 않음.';

  @override
  String get notUnlocked => '잠금 해제되지 않음';

  @override
  String get noteOptional => '메모 (선택 사항)';

  @override
  String get notifications => '알림';

  @override
  String get numberLabel => '숫자';

  @override
  String get numericExample => '하루에 물 8잔 마시기';

  @override
  String get numericSettings => '수치 목표 설정';

  @override
  String get numericalDescription => '수치 목표 추적';

  @override
  String get numericalGoalShort => '수치 목표';

  @override
  String get numericalType => '수치 값';

  @override
  String get oceanTheme => '오션';

  @override
  String get oceanThemeDesc => '고요한 파란색 테마';

  @override
  String get onDailyLimit => '일일 한도에 도달했습니다.';

  @override
  String get onPeriodic => '특정 간격으로';

  @override
  String get onSpecificMonthDays => '특정 월일에';

  @override
  String get onSpecificWeekdays => '특정 요일에';

  @override
  String get onSpecificYearDays => '특정 연일에';

  @override
  String get once => '한 번';

  @override
  String get other => '기타';

  @override
  String get outline => '윤곽선';

  @override
  String get outlineColor => '윤곽선 색상';

  @override
  String get pages => '페이지';

  @override
  String get pause => '일시 중지';

  @override
  String get periodicSelection => '주기적 선택';

  @override
  String get pickTodaysMood => '오늘의 기분 선택';

  @override
  String get plannedMonthlySpend => '계획된 월간 지출';

  @override
  String get plateColor => '플레이트 색상';

  @override
  String get previous => '이전';

  @override
  String get previousYear => '작년';

  @override
  String get privacySecurity => '개인정보 보호 및 보안';

  @override
  String get productivity => '생산성';

  @override
  String get profile => '프로필';

  @override
  String get profileInfo => '프로필 정보';

  @override
  String get profileUpdated => '프로필이 업데이트되었습니다';

  @override
  String get readyVisionsLoadFailed => '준비된 비전을 로드할 수 없습니다.';

  @override
  String get recurringMonthlyDesc => '선택한 날짜에 매월 자동으로 추가';

  @override
  String get recurringMonthlyTitle => '반복 (매월)';

  @override
  String get reload => '새로 고침';

  @override
  String get remainingToday => '오늘 남은 시간';

  @override
  String get reminderFrequency => '알림 빈도';

  @override
  String get reminderSettings => '알림 설정';

  @override
  String get reminderTime => '알림 시간';

  @override
  String get repeatEveryDay => '매일 반복';

  @override
  String get repeatEveryNDays => 'N일마다 반복';

  @override
  String get reset => '초기화';

  @override
  String get retry => '재시도';

  @override
  String ruleEnteredDurationAtLeast(Object target) {
    return '규칙: 입력 기간 ≥ $target';
  }

  @override
  String ruleEnteredDurationAtMost(Object target) {
    return '규칙: 입력 기간 ≤ $target';
  }

  @override
  String ruleEnteredDurationExactly(Object target) {
    return '규칙: 입력 기간 = $target';
  }

  @override
  String ruleEnteredValueAtLeast(Object target) {
    return '규칙: 입력 값 ≥ $target';
  }

  @override
  String ruleEnteredValueAtMost(Object target) {
    return '규칙: 입력 값 ≤ $target';
  }

  @override
  String ruleEnteredValueExactly(Object target) {
    return '규칙: 입력 값 = $target';
  }

  @override
  String get save => '저장';

  @override
  String get saved => '저장됨';

  @override
  String get savingsBudgetPlan => '저축/예산 계획';

  @override
  String get scheduleHabit => '습관 일정 설정';

  @override
  String get scheduleLabel => '일정';

  @override
  String get schedulingOptions => '일정 옵션';

  @override
  String get seconds => '초';

  @override
  String get select => '선택';

  @override
  String get selectAll => '모두 선택';

  @override
  String get selectCategory => '카테고리 선택';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get selectEndDate => '종료일 선택';

  @override
  String get selectFrequency => '빈도 선택';

  @override
  String get selectHabitType => '습관 유형 선택';

  @override
  String get sendBackward => '뒤로 보내기';

  @override
  String get settings => '설정';

  @override
  String get shareAsLink => '링크로 공유';

  @override
  String get shareLinkCopied => '공유 링크가 클립보드에 복사되었습니다.';

  @override
  String get shareVision => '비전 공유';

  @override
  String get social => '소셜';

  @override
  String get soundAlerts => '소리 알림';

  @override
  String get specificDaysOfMonth => '특정 월일';

  @override
  String get specificDaysOfWeek => '특정 요일';

  @override
  String get specificDaysOfYear => '특정 연일';

  @override
  String spendingLessThanDailyAvg(Object amount) {
    return '좋아요! 일일 평균보다 $amount 적게 지출하고 있습니다.';
  }

  @override
  String spendingMoreThanDailyAvg(Object amount) {
    return '경고! 일일 평균보다 $amount 더 많이 지출하고 있습니다.';
  }

  @override
  String get start => '시작';

  @override
  String get startDate => '시작일';

  @override
  String get startDayLabel => '시작일 (1-365)';

  @override
  String get statusLabel => '상태';

  @override
  String get step => '단계';

  @override
  String stepOf(Object current, Object total) {
    return '$total 중 $current 단계';
  }

  @override
  String get steps => '단계';

  @override
  String streakDays(Object count) {
    return '$count일 연속';
  }

  @override
  String get streakIndicator => '연속 기록 표시기';

  @override
  String get streakIndicatorDesc => '불꽃 및 얼음 효과 표시';

  @override
  String successfulDaysCount(Object count) {
    return '$count일 성공';
  }

  @override
  String get systemTheme => '시스템 테마';

  @override
  String get targetDurationMinutes => '목표 기간 (분)';

  @override
  String targetShort(Object value) {
    return '목표: $value';
  }

  @override
  String get targetType => '목표 유형';

  @override
  String get targetValue => '목표 값';

  @override
  String get targetValueLabel => '목표 값';

  @override
  String get taskDescription => '설명 (선택사항)';

  @override
  String get taskTitle => '작업 제목';

  @override
  String get templateDetailsNotFound => '템플릿 세부 정보를 찾을 수 없습니다';

  @override
  String get templatesTabManual => '수동';

  @override
  String get templatesTabReady => '준비';

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
  String get textLabel => '텍스트';

  @override
  String get theme => '테마';

  @override
  String get themeDetails => '테마 세부사항';

  @override
  String get themeSelection => '테마 선택';

  @override
  String get thisMonth => '이번 달';

  @override
  String get timerCreateTimerHabitFirst => '먼저 타이머 습관을 만드세요';

  @override
  String get timerDescription => '시간 기반 추적';

  @override
  String get timerExample => '30분 운동하기';

  @override
  String get timerHabitLabel => '타이머 습관';

  @override
  String timerPendingDurationLabel(Object duration) {
    return '대기 기간: $duration';
  }

  @override
  String timerPendingLabel(Object duration) {
    return '대기 중: $duration';
  }

  @override
  String get timerPomodoroBreakPhase => '휴식';

  @override
  String timerPomodoroCompletedWork(Object count) {
    return '완료된 작업: $count';
  }

  @override
  String get timerPomodoroLongBreakIntervalLabel => '긴 휴식 주기 (예: 4)';

  @override
  String get timerPomodoroLongBreakMinutesLabel => '긴 휴식 (분)';

  @override
  String get timerPomodoroSettings => '뽀모도로 설정';

  @override
  String get timerPomodoroShortBreakMinutesLabel => '짧은 휴식 (분)';

  @override
  String get timerPomodoroSkipPhase => '단계 건너뛰기';

  @override
  String get timerPomodoroWorkMinutesLabel => '작업 (분)';

  @override
  String get timerPomodoroWorkPhase => '작업';

  @override
  String get timerSaveDurationTitle => '기간 저장';

  @override
  String get timerSaveSessionTitle => '세션 저장';

  @override
  String get timerQuickPresets => 'Quick Presets';

  @override
  String get timerSessionAlreadySaved => '이 세션은 이미 저장되었습니다';

  @override
  String get totalDuration => '총 기간';

  @override
  String get timerSetDurationFirst => '먼저 기간을 설정하세요';

  @override
  String get timerSettings => '타이머 설정';

  @override
  String get timerTabCountdown => '카운트다운';

  @override
  String get timerTabPomodoro => '뽀모도로';

  @override
  String get timerTabStopwatch => '스톱워치';

  @override
  String get timerType => '타이머';

  @override
  String get checkboxType => 'Checkbox';

  @override
  String get subtasksType => 'Subtasks';

  @override
  String get times => '회';

  @override
  String get titleHint => '예: 식료품, 프리랜서 등';

  @override
  String get titleOptional => '제목 (선택 사항)';

  @override
  String get typeLabel => '유형';

  @override
  String get unit => '단위';

  @override
  String get unitHint => '단위 (잔, 걸음, 페이지...)';

  @override
  String get update => '업데이트';

  @override
  String get vision => '비전';

  @override
  String visionAutoDurationInfo(Object day) {
    return '이 비전은 템플릿의 마지막 날을 사용합니다: $day.';
  }

  @override
  String get visionCreateTitle => '비전 생성';

  @override
  String get visionDurationNote =>
      '참고: 비전이 시작되면 총 기간이 설정됩니다. 종료일이 이 기간을 초과하면 자동으로 단축됩니다.';

  @override
  String get visionEditTitle => '비전 편집';

  @override
  String get visionEndDayInvalid => '종료일은 1에서 365 사이여야 합니다';

  @override
  String get visionEndDayLess => '종료일은 시작일보다 빠를 수 없습니다';

  @override
  String get visionEndDayQuestion => '비전의 며칠째에 종료해야 합니까?';

  @override
  String get visionEndDayRequired => '종료일을 입력하세요';

  @override
  String get visionNoEndDurationInfo => '종료일이 지정되지 않았습니다. 비전은 무기한으로 시작됩니다.';

  @override
  String get visionPlural => '비전';

  @override
  String get visionStartDayInvalid => '시작일은 1에서 365 사이여야 합니다';

  @override
  String get visionStartDayQuestion => '비전의 며칠째에 시작해야 합니까?';

  @override
  String get visionDurationDaysLabel => '기간(일)';

  @override
  String get visionStartFailed => '비전을 시작할 수 없습니다.';

  @override
  String visionStartedMessage(Object title) {
    return '비전 시작됨: $title';
  }

  @override
  String get visionStartLabel => 'Vision start: ';

  @override
  String get visual => '시각적';

  @override
  String get weekdaysShortFri => '금';

  @override
  String get weekdaysShortMon => '월';

  @override
  String get fortuneTitle => '운세 달걀';

  @override
  String get fortuneQuestionPrompt => '질문을 입력하세요';

  @override
  String get fortuneQuestionHint => '무엇을 알고 싶으신가요?';

  @override
  String get fortuneEggsSubtitle => '달걀을 선택하여 운세를 확인하세요';

  @override
  String get fortuneResultTitle => '당신의 운세';

  @override
  String get fortuneNoQuestion => '아직 질문을 하지 않았습니다';

  @override
  String get fortuneDisclaimer => '운세는 오락 목적으로만 제공됩니다';

  @override
  String fortuneEggSemantic(int index) {
    return '운세 달걀 $index';
  }

  @override
  String get fortunePlay => '시작';

  @override
  String get shuffle => '섞기';

  @override
  String get ok => '확인';

  @override
  String get weekdaysShortSat => '토';

  @override
  String get weekdaysShortSun => '일';

  @override
  String get weekdaysShortThu => '목';

  @override
  String get weekdaysShortTue => '화';

  @override
  String get weekdaysShortWed => '수';

  @override
  String get weekly => '매주';

  @override
  String get weeklyEmailSummary => '주간 이메일 요약';

  @override
  String get weeklySummaryEmail => '주간 요약 이메일';

  @override
  String get whichDaysActive => '어떤 날을 활성화해야 합니까?';

  @override
  String get whichMonthDays => '월의 어떤 날?';

  @override
  String get whichWeekdays => '어떤 요일?';

  @override
  String get worldTheme => '월드';

  @override
  String get worldThemeDesc => '모든 색상의 조화';

  @override
  String xpProgressSummary(Object current, Object toNext, Object total) {
    return '$current / $total XP • 다음 레벨까지 $toNext XP';
  }

  @override
  String get yesNoDescription => '단순 예/아니오 추적';

  @override
  String get yesNoExample => '오늘 명상했나요?';

  @override
  String get yesNoType => '예/아니오';

  @override
  String get analysis => '분석';

  @override
  String get apply => '적용';

  @override
  String get clearFilters => '필터 지우기';

  @override
  String get simpleTypeShort => '단순';

  @override
  String get completedSelectedDay => '완료 (선택한 날짜)';

  @override
  String get incompleteSelectedDay => '미완료 (선택한 날짜)';

  @override
  String get manageListsSubtitle => '새 목록을 추가, 이름 변경 또는 삭제합니다.';

  @override
  String get editListTitle => '목록 편집';

  @override
  String get listNameLabel => '목록 이름';

  @override
  String get deleteListTitle => '목록 삭제';

  @override
  String get deleteListMessage => '이 목록이 삭제됩니다. 연결된 항목으로 수행할 작업을 선택하세요:';

  @override
  String get unassignLinkedHabits => '연결된 습관 할당 해제';

  @override
  String get unassignLinkedDailyTasks => '연결된 일일 작업 할당 해제';

  @override
  String listCreatedMessage(Object title) {
    return '목록 생성됨: $title';
  }

  @override
  String get removeFromList => '목록에서 제거';

  @override
  String get createNewList => '새 목록 생성';

  @override
  String get dailyTasksSection => '일일 작업';

  @override
  String get addToList => '목록에 추가';

  @override
  String get deleteTaskConfirmTitle => '작업을 삭제하시겠습니까?';

  @override
  String get deleteTaskConfirmMessage => '이 일일 작업을 삭제하시겠습니까? 이 작업은 취소할 수 있습니다.';

  @override
  String get undo => '실행 취소';

  @override
  String get habitsSection => '습관';

  @override
  String get noItemsMatchFilters => '선택한 필터와 일치하는 항목 없음';

  @override
  String dailyTaskCreatedMessage(Object title) {
    return '일일 작업 생성됨: $title';
  }

  @override
  String habitDeletedMessage(Object title) {
    return '습관 삭제됨: $title';
  }

  @override
  String habitCreatedMessage(Object title) {
    return '습관 생성됨: $title';
  }

  @override
  String deleteHabitConfirm(Object title) {
    return '습관 \'$title\'을(를) 삭제하시겠습니까?';
  }

  @override
  String get enterValueTitle => '값 입력';

  @override
  String get valueLabel => '값';

  @override
  String get currentStreak => '현재 연속 기록';

  @override
  String get longestStreak => '최장 연속 기록';

  @override
  String daysCount(Object count) {
    return '$count일';
  }

  @override
  String get success => '성공';

  @override
  String get successfulDayLegend => '성공한 날';

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
  String get periodic => '주기적';

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
  String get motivation => '동기 부여';

  @override
  String motivationBody(Object percent, Object period) {
    return '잘했어요! $period 동안 $percent%의 성공률을 달성했습니다.';
  }

  @override
  String get weeklyProgress => '주간 진행률';

  @override
  String get monthlyProgress => '월간 진행률';

  @override
  String get yearlyProgress => '연간 진행률';

  @override
  String get overall => '전체';

  @override
  String get overallProgress => '전체 진행률';

  @override
  String get totalSuccessfulDays => '총 성공일';

  @override
  String get totalUnsuccessfulDays => '총 실패일';

  @override
  String get totalProgress => '전체 진행률';

  @override
  String get thisWeek => '이번 주';

  @override
  String get thisYear => '올해';

  @override
  String get badges => '배지';

  @override
  String get yearly => '매년';

  @override
  String get newList => '새 목록';

  @override
  String taskDeletedMessage(Object title) {
    return '작업 삭제됨: $title';
  }

  @override
  String get clear => '지우기';

  @override
  String get createHabitTitle => '습관 생성';

  @override
  String get addDate => '날짜 추가';

  @override
  String get listNameHint => '예: 건강';

  @override
  String get taskTitleRequired => '작업 제목은 필수입니다';

  @override
  String get moodFlowTitle => '기분이 어떠신가요?';

  @override
  String get moodFlowSubtitle => '감정적 건강을 추적하세요';

  @override
  String get moodSelection => '기분 선택';

  @override
  String get selectYourCurrentMood => '현재 기분을 선택하세요';

  @override
  String get moodTerribleDesc => '매우 우울해요';

  @override
  String get moodBadDesc => '힘든 시간을 보내고 있어요';

  @override
  String get moodNeutralDesc => '괜찮아요';

  @override
  String get moodGoodDesc => '긍정적이에요';

  @override
  String get moodExcellentDesc => '정말 좋아요';

  @override
  String get feelingMoreSpecific => '더 구체적으로 말씀해 주시겠어요?';

  @override
  String get selectSubEmotionDesc => '더 구체적인 감정을 선택하세요';

  @override
  String get whatsTheCause => '원인이 무엇인가요?';

  @override
  String get selectReasonDesc => '기분에 영향을 주는 것을 선택하세요';

  @override
  String get moodNeutral => '보통';

  @override
  String get moodExcellent => '훌륭함';

  @override
  String get howAreYouFeeling => '기분이 어떠신가요?';

  @override
  String get selectYourMood => '기분을 선택하세요';

  @override
  String get subEmotionSelection => '세부 감정 선택';

  @override
  String get selectSubEmotion => '세부 감정 선택';

  @override
  String get subEmotionExhausted => '지친';

  @override
  String get subEmotionHelpless => '무력한';

  @override
  String get subEmotionHopeless => '절망적인';

  @override
  String get subEmotionHurt => '상처받은';

  @override
  String get subEmotionDrained => '기진맥진한';

  @override
  String get subEmotionAngry => '화난';

  @override
  String get subEmotionSad => '슬픈';

  @override
  String get subEmotionAnxious => '불안한';

  @override
  String get subEmotionStressed => '스트레스받는';

  @override
  String get subEmotionDemoralized => '의기소침한';

  @override
  String get subEmotionIndecisive => '우유부단한';

  @override
  String get subEmotionTired => '피곤한';

  @override
  String get subEmotionOrdinary => '평범한';

  @override
  String get subEmotionCalm => '차분한';

  @override
  String get subEmotionEmpty => '공허한';

  @override
  String get subEmotionHappy => '행복한';

  @override
  String get subEmotionCheerful => '명랑한';

  @override
  String get subEmotionExcited => '신난';

  @override
  String get subEmotionEnthusiastic => '열정적인';

  @override
  String get subEmotionDetermined => '결연한';

  @override
  String get subEmotionMotivated => '의욕적인';

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
  String get reasonWork => '일';

  @override
  String get reasonRelationship => 'Relationship';

  @override
  String get reasonFinance => 'Finance';

  @override
  String get reasonHealth => '건강';

  @override
  String get reasonSocial => 'Social';

  @override
  String get reasonPersonalGrowth => 'Personal Growth';

  @override
  String get reasonWeather => 'Weather';

  @override
  String get reasonOther => '기타';

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
  String get skip => '건너뛰기';

  @override
  String get habitNotFound => '습관을 찾을 수 없습니다.';

  @override
  String get habitUpdatedMessage => '습관이 업데이트되었습니다.';

  @override
  String get invalidValue => '잘못된 값';

  @override
  String get nameRequired => '이름은 필수입니다';

  @override
  String get simpleHabitTargetOne => '단순 습관 (목표 = 1)';

  @override
  String get typeNotChangeable => '유형은 변경할 수 없습니다';

  @override
  String get onboardingWelcomeTitle => 'Mira에 오신 것을 환영합니다';

  @override
  String get onboardingWelcomeDesc =>
      '당신과 함께 성장하는 개인 맞춤형 습관 추적기입니다. 고유한 성격을 발견하고 당신에게 맞춘 습관을 제안해 드립니다.';

  @override
  String get onboardingQuizIntro =>
      '당신의 성격을 더 잘 이해할 수 있도록 몇 가지 질문에 답해주세요. 이는 과학적으로 검증된 심리학 연구에 기반합니다.';

  @override
  String get onboardingQ1 => '새롭고 낯선 경험을 시도하고 탐색하는 것을 즐깁니다.';

  @override
  String get onboardingQ2 => '공간을 정리정돈하며 구조적인 일과를 선호합니다.';

  @override
  String get onboardingQ3 => '사람들과 함께 있을 때 에너지를 얻고 모임을 즐깁니다.';

  @override
  String get onboardingQ4 => '다른 사람들과 협력하여 일하는 것을 선호하며 경쟁보다 협력이 더 효과적이라고 느낍니다.';

  @override
  String get onboardingQ5 => '스트레스 상황에서도 침착하게 대처하며 불안을 거의 느끼지 않습니다.';

  @override
  String get onboardingQ6 => '미술, 음악, 글쓰기와 같은 창의적인 활동을 즐깁니다.';

  @override
  String get onboardingQ7 => '스스로 명확한 목표를 세우고 이를 달성하기 위해 성실히 노력합니다.';

  @override
  String get onboardingQ8 => '혼자 시간을 보내는 것보다 그룹 활동을 더 선호합니다.';

  @override
  String get onboardingQ9 => '결정을 내리기 전에 종종 다른 사람들의 감정을 고려합니다.';

  @override
  String get onboardingQ10 => '중요한 일정과 과업을 미리 계획합니다.';

  @override
  String get onboardingQ11 => '한 가지 방식에 고집하기보다 다양한 접근을 시도하는 것을 좋아합니다.';

  @override
  String get onboardingQ12 => '압박 속에서도 침착함을 유지하고 좌절에서 빠르게 회복합니다.';

  @override
  String get likertStronglyDisagree => '전혀 동의하지 않음';

  @override
  String get likertDisagree => '동의하지 않음';

  @override
  String get likertNeutral => '중립';

  @override
  String get likertAgree => '동의';

  @override
  String get likertStronglyAgree => '매우 동의';

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
  String get selectHabitsToAdd => '일상에 추가하고 싶은 습관을 선택하세요:';

  @override
  String get startJourney => '여정 시작하기';

  @override
  String get skipOnboarding => '건너뛰기';

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
    return '백업됨: $id';
  }

  @override
  String get backupError => 'Backup Error';

  @override
  String restoreSuccess(Object content) {
    return '다운로드됨: $content';
  }

  @override
  String get restoreError => 'Restore Error';

  @override
  String get manageSubscription => '구독 관리';

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
  String get pastelColors => '파스텔 색상';

  @override
  String get habitNameHintTimer => '예: 명상, 운동...';

  @override
  String get habitNameHintNumerical => '예: 물 마시기, 독서...';

  @override
  String get habitDescriptionHint => '짧은 설명 추가...';

  @override
  String get target => '목표';

  @override
  String get amount => '양';

  @override
  String get custom => '사용자 지정';

  @override
  String get customUnitHint => '예: 인분, 세트, km...';

  @override
  String get unitAdet => '개';

  @override
  String get unitBardak => '잔';

  @override
  String get unitSayfa => '페이지';

  @override
  String get unitKm => 'km';

  @override
  String get unitLitre => '리터';

  @override
  String get unitKalori => 'cal';

  @override
  String get unitAdim => '걸음';

  @override
  String get unitKez => '회';

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
  String get backupFailed => '백업 실패';

  @override
  String get restoreFailed => '복원 실패';

  @override
  String plansLoadError(Object error) {
    return '플랜 로드 오류: $error';
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
  String get averageMood => '평균 기분';

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
  String get noHistory => '기록 없음';

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
  String get addTask => '작업 추가';

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
