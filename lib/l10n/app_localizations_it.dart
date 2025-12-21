// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get about => 'Informazioni';

  @override
  String get account => 'Account';

  @override
  String get achievements => 'Traguardi';

  @override
  String get activeDays => 'Giorni attivi';

  @override
  String get add => 'Aggiungi';

  @override
  String get addHabit => 'Aggiungi abitudine';

  @override
  String get addImage => 'Aggiungi immagine';

  @override
  String get addNew => 'Aggiungi nuovo';

  @override
  String get addNewHabit => 'Aggiungi nuova abitudine';

  @override
  String get addSpecialDays => 'Aggiungi giorni speciali';

  @override
  String get addText => 'Aggiungi testo';

  @override
  String get advancedHabit => 'Abitudine avanzata';

  @override
  String get allLabel => 'Tutti';

  @override
  String get alsoDeleteLinkedHabits => 'Elimina anche le abitudini collegate';

  @override
  String get amountLabel => 'Importo';

  @override
  String get socialFeedTitle => 'Feed';

  @override
  String get spendingAdvisorTitle => 'Consulente di Spesa';

  @override
  String spendingAdvisorSafe(Object amount) {
    return 'Puoi spendere $amount al giorno.';
  }

  @override
  String spendingAdvisorWarning(Object amount) {
    return 'Riduci la spesa giornaliera di $amount per rimanere in linea.';
  }

  @override
  String get spendingAdvisorOnTrack =>
      'Ottimo! Sei in linea con il tuo budget.';

  @override
  String get spendingAdvisorOverBudget =>
      'Sei fuori budget. Smetti di spendere.';

  @override
  String get spendingAdvisorNoBudget =>
      'Imposta un budget per ricevere consigli.';

  @override
  String get appTitle => 'Mira';

  @override
  String get appearance => 'Aspetto';

  @override
  String get notificationSettings => 'Impostazioni notifiche';

  @override
  String get notificationSettingsSubtitle =>
      'Configura le tue preferenze di notifica';

  @override
  String get enableNotifications => 'Attiva notifiche';

  @override
  String get notificationsMasterSubtitle =>
      'Controlla tutte le notifiche dell\'app';

  @override
  String get notificationTypes => 'Tipi di notifiche';

  @override
  String get habitReminders => 'Promemoria abitudini';

  @override
  String get habitRemindersSubtitle =>
      'Promemoria giornalieri per le tue abitudini';

  @override
  String get notificationBehavior => 'Comportamento notifiche';

  @override
  String get sound => 'Suono';

  @override
  String get soundSubtitle => 'Riproduci suono con le notifiche';

  @override
  String get vibration => 'Vibrazione';

  @override
  String get vibrationSubtitle => 'Vibra con le notifiche';

  @override
  String get systemInfo => 'Informazioni di sistema';

  @override
  String get timezone => 'Fuso orario';

  @override
  String get notificationPermission => 'Permesso notifiche';

  @override
  String get exactAlarmPermission => 'Permesso allarme esatto (Android 12+)';

  @override
  String get granted => 'Concesso';

  @override
  String get notGranted => 'Non concesso';

  @override
  String get importantNotice => 'Avviso importante';

  @override
  String get notificationTroubleshooting =>
      'Per il corretto funzionamento delle notifiche:\n\n• DISATTIVA l\'ottimizzazione della batteria\n• CONSENTI l\'attività in background\n• Assicurati che i permessi di notifica siano ATTIVI\n• Controlla la modalità \'Non disturbare\'';

  @override
  String approxVisionDurationDays(Object days) {
    return 'Questa visione dura circa $days giorni';
  }

  @override
  String get assetsReloadHint =>
      'Potrebbe essere necessario un riavvio completo dell\'app per caricare alcune risorse.';

  @override
  String get atLeast => 'Almeno';

  @override
  String get atMost => 'Al massimo';

  @override
  String get backgroundPlate => 'Piatto di sfondo';

  @override
  String get badgeActive100dDesc => 'Sii attivo per 100 giorni diversi';

  @override
  String get badgeActive100dTitle => '100 giorni di attività';

  @override
  String get badgeActive30dDesc => 'Sii attivo per 30 giorni diversi';

  @override
  String get badgeActive30dTitle => '30 giorni di attività';

  @override
  String get badgeActive7dDesc => 'Sii attivo per 7 giorni diversi';

  @override
  String get badgeActive7dTitle => '7 giorni di attività';

  @override
  String get badgeCategoryActivity => 'Attività';

  @override
  String get badgeCategoryFinance => 'Finanza';

  @override
  String get badgeCategoryHabit => 'Abitudine';

  @override
  String get badgeCategoryLevel => 'Livello';

  @override
  String get badgeCategoryVision => 'Visione';

  @override
  String get badgeCategoryXp => 'XP';

  @override
  String get badgeFin100Desc => 'Registra 100 transazioni';

  @override
  String get badgeFin100Title => 'Finanziere 100';

  @override
  String get badgeFin10Desc => 'Registra 10 transazioni';

  @override
  String get badgeFin10Title => 'Finanziere 10';

  @override
  String get badgeFin250Desc => 'Registra 250 transazioni';

  @override
  String get badgeFin250Title => 'Finanziere 250';

  @override
  String get badgeFin50Desc => 'Registra 50 transazioni';

  @override
  String get badgeFin50Title => 'Finanziere 50';

  @override
  String get badgeHabit100Desc => 'Completa 100 abitudini in totale';

  @override
  String get badgeHabit100Title => 'Abitudine 100';

  @override
  String get badgeHabit10Desc => 'Completa 10 abitudini in totale';

  @override
  String get badgeHabit10Title => 'Abitudine 10';

  @override
  String get badgeHabit200Desc => 'Completa 200 abitudini in totale';

  @override
  String get badgeHabit200Title => 'Abitudine 200';

  @override
  String get badgeHabit50Desc => 'Completa 50 abitudini in totale';

  @override
  String get badgeHabit50Title => 'Abitudine 50';

  @override
  String get badgeLevel10Desc => 'Raggiungi il livello 10';

  @override
  String get badgeLevel10Title => 'Livello 10';

  @override
  String get badgeLevel20Desc => 'Raggiungi il livello 20';

  @override
  String get badgeLevel20Title => 'Livello 20';

  @override
  String get badgeLevel5Desc => 'Raggiungi il livello 5';

  @override
  String get badgeLevel5Title => 'Livello 5';

  @override
  String get badgeVision10Desc => 'Crea 10 visioni';

  @override
  String get badgeVision10Title => 'Gran Maestro della Visione';

  @override
  String get badgeVision1Desc => 'Crea la tua prima visione';

  @override
  String get badgeVision1Title => 'Visionario';

  @override
  String get badgeVision5Desc => 'Crea 5 visioni';

  @override
  String get badgeVision5Title => 'Maestro della Visione';

  @override
  String get badgeVisionHabits3Desc => 'Collega 3+ abitudini a una visione';

  @override
  String get badgeVisionHabits3Title => 'Connettore';

  @override
  String get badgeXp1000Desc => 'Guadagna un totale di 1000 XP';

  @override
  String get badgeXp1000Title => '1000 XP';

  @override
  String get badgeXp500Desc => 'Guadagna un totale di 500 XP';

  @override
  String get badgeXp500Title => '500 XP';

  @override
  String get between1And360 => 'Tra 1 e 360';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Una breve biografia su di te';

  @override
  String get breakTime => 'Pausa';

  @override
  String get breakdownByCategory => 'Ripartizione per categoria';

  @override
  String get bringForward => 'Porta avanti';

  @override
  String get cancel => 'Annulla';

  @override
  String get category => 'Categoria';

  @override
  String get categoryName => 'Nome della categoria';

  @override
  String get chooseBestCategory =>
      'Scegli la categoria migliore per la tua abitudine';

  @override
  String get chooseColor => 'Scegli colore:';

  @override
  String get chooseEmoji => 'Scegli Emoji:';

  @override
  String get clearHistory => 'Cancella cronologia';

  @override
  String get close => 'Chiudi';

  @override
  String get colorLabel => 'Colore';

  @override
  String get colorTheme => 'Tema colore';

  @override
  String get countdownConfigureTitle => 'Configura conto alla rovescia';

  @override
  String get create => 'Crea';

  @override
  String get createAdvancedHabit => 'Crea abitudine avanzata';

  @override
  String get createDailyTask => 'Crea compito giornaliero';

  @override
  String get createHabitTemplateTitle => 'Crea modello di abitudine';

  @override
  String get createList => 'Crea lista';

  @override
  String get createNewCategory => 'Crea nuova categoria';

  @override
  String get createVision => 'Crea visione';

  @override
  String get createVisionTemplateTitle => 'Crea modello di visione';

  @override
  String get customCategories => 'Categorie personalizzate';

  @override
  String get customEmojiHint => 'Es: ✨';

  @override
  String get customEmojiOptional => 'Emoji personalizzata (opzionale)';

  @override
  String get reminder => 'Promemoria';

  @override
  String get enableReminder => 'Abilita promemoria';

  @override
  String get selectTime => 'Seleziona ora';

  @override
  String get customFrequency => 'Personalizzato';

  @override
  String get daily => 'Giornaliero';

  @override
  String get dailyCheck => 'Controllo giornaliero';

  @override
  String get dailyLimit => 'Limite giornaliero';

  @override
  String get dailyTask => 'Compito giornaliero';

  @override
  String get darkTheme => 'Tema scuro';

  @override
  String get dashboard => 'Cruscotto';

  @override
  String get date => 'Data';

  @override
  String dayRangeShort(Object end, Object start) {
    return 'Giorno $start–$end';
  }

  @override
  String dayShort(Object day) {
    return 'Giorno $day';
  }

  @override
  String daysAverageShort(Object days) {
    return '${days}g media';
  }

  @override
  String get delete => 'Elimina';

  @override
  String deleteCategoryConfirmNamed(Object name) {
    return 'Eliminare la categoria \"$name\"?';
  }

  @override
  String get deleteCategoryTitle => 'Elimina categoria';

  @override
  String get deleteCustomCategoryConfirm =>
      'Eliminare questa categoria personalizzata?';

  @override
  String get deleteEntryConfirm => 'Eliminare questa voce?';

  @override
  String deleteTransactionConfirm(Object title) {
    return 'Eliminare la registrazione \"$title\"?';
  }

  @override
  String get deleteVisionMessage => 'Eliminare questa visione?';

  @override
  String get deleteVisionTitle => 'Elimina visione';

  @override
  String get descHint => 'Dettagli sulla tua abitudine (opzionale)';

  @override
  String get difficulty => 'Livello di difficoltà';

  @override
  String get duration => 'Durata';

  @override
  String get durationAutoLabel => 'Durata (auto)';

  @override
  String get durationSelection => 'Selezione durata';

  @override
  String get durationType => 'Tipo di durata';

  @override
  String get earthTheme => 'Terra';

  @override
  String get earthThemeDesc => 'Colori della terra';

  @override
  String get easy => 'Facile';

  @override
  String get edit => 'Modifica';

  @override
  String get editCategory => 'Modifica categoria';

  @override
  String get editHabit => 'Modifica abitudine';

  @override
  String get education => 'Istruzione';

  @override
  String get emojiLabel => 'Emoji';

  @override
  String get endDate => 'Data di fine';

  @override
  String get endDayOptionalLabel => 'Giorno di fine (opzionale)';

  @override
  String get enterMonthlyPlanToComputeDailyLimit =>
      'Inserisci un piano mensile per calcolare un limite giornaliero.';

  @override
  String get enterNameAndDesc =>
      'Inserisci il nome e la descrizione della tua abitudine';

  @override
  String get enterYourName => 'Inserisci il tuo nome';

  @override
  String get entries => 'Voci';

  @override
  String get everyNDaysQuestion => 'Ogni quanti giorni?';

  @override
  String get everyday => 'Ogni giorno';

  @override
  String get exact => 'Esatto';

  @override
  String examplePrefix(Object example) {
    return 'Esempio: $example';
  }

  @override
  String get expenseDelta => 'Spesa Δ';

  @override
  String get expenseDistributionPie => 'Distribuzione delle spese (torta)';

  @override
  String get expenseEditTitle => 'Modifica spesa';

  @override
  String get expenseLabel => 'Spesa';

  @override
  String get expenseNewTitle => 'Nuova spesa';

  @override
  String failedToLoad(Object error) {
    return 'Caricamento non riuscito: $error';
  }

  @override
  String get filterTitle => 'Filtro';

  @override
  String get finance => 'Finanze';

  @override
  String financeAnalysisTitle(Object month) {
    return 'Analisi finanziaria · $month';
  }

  @override
  String get financeLast7Days => 'Finanza · Ultimi 7 giorni';

  @override
  String get finish => 'Fine';

  @override
  String get historyTitle => 'History';

  @override
  String get fitness => 'Fitness';

  @override
  String get fixedDuration => 'Fissa';

  @override
  String get font => 'Carattere';

  @override
  String get forestTheme => 'Foresta';

  @override
  String get forestThemeDesc => 'Tema verde naturale';

  @override
  String get forever => 'Per sempre';

  @override
  String get frequency => 'Frequenza';

  @override
  String get fullName => 'Nome completo';

  @override
  String get fullScreen => 'Schermo intero';

  @override
  String get gallery => 'Galleria';

  @override
  String get general => 'Generale';

  @override
  String get generalNotifications => 'Notifiche generali';

  @override
  String get glasses => 'Bicchieri';

  @override
  String get goldenTheme => 'Dorato';

  @override
  String get goldenThemeDesc => 'Tema dorato caldo';

  @override
  String get greetingAfternoon => 'Buon pomeriggio';

  @override
  String get greetingEvening => 'Buonasera';

  @override
  String get greetingMorning => 'Buongiorno';

  @override
  String get habit => 'Abitudine';

  @override
  String get habitDescription => 'Descrizione';

  @override
  String get habitDetails => 'Dettagli abitudine';

  @override
  String get habitName => 'Nome abitudine';

  @override
  String get habitOfThisVision => 'Abitudine di questa visione';

  @override
  String get habits => 'Abitudini';

  @override
  String get hard => 'Difficile';

  @override
  String get headerFocusLabel => 'Focus';

  @override
  String get headerFocusReady => 'Pronto';

  @override
  String get headerHabitsLabel => 'Abitudine';

  @override
  String get health => 'Salute';

  @override
  String get hours => 'Ore';

  @override
  String get howOftenDoHabit => 'Decidi quanto spesso farai la tua abitudine';

  @override
  String get howToEarn => 'Come guadagnare';

  @override
  String get howToTrackHabit => 'Scegli come verrà monitorata la tua abitudine';

  @override
  String get ifCondition => 'Se';

  @override
  String get importFromLink => 'Importa da link';

  @override
  String get incomeDelta => 'Δ reddito';

  @override
  String get incomeEditTitle => 'Modifica reddito';

  @override
  String get incomeLabel => 'Reddito';

  @override
  String get incomeNewTitle => 'Nuovo reddito';

  @override
  String get input => 'Input';

  @override
  String get invalidLink => 'Link non valido.';

  @override
  String get language => 'Lingua';

  @override
  String get languageSelection => 'Selezione Lingua';

  @override
  String levelLabel(Object level) {
    return 'Livello $level';
  }

  @override
  String levelShort(Object level) {
    return 'L$level';
  }

  @override
  String get lightTheme => 'Tema chiaro';

  @override
  String get linkHabits => 'Collega abitudini';

  @override
  String get listLabel => 'Lista';

  @override
  String get loadingHabits => 'Caricamento abitudini...';

  @override
  String get logout => 'Disconnetti';

  @override
  String get manageLists => 'Gestisci liste';

  @override
  String get medium => 'Medio';

  @override
  String get mindfulness => 'Mindfulness';

  @override
  String get minutes => 'Minuti';

  @override
  String get minutesSuffixShort => 'min';

  @override
  String get monthCount => 'Conteggio mesi';

  @override
  String get monthCountHint => 'Es: 12';

  @override
  String get monthSuffixShort => 'm';

  @override
  String get monthly => 'Mensile';

  @override
  String get monthlyTrend => 'Andamento mensile';

  @override
  String get mood => 'Umore';

  @override
  String get moodBad => 'Cattivo';

  @override
  String get moodGood => 'Buono';

  @override
  String get moodGreat => 'Ottimo';

  @override
  String get moodOk => 'Ok';

  @override
  String get moodTerrible => 'Terribile';

  @override
  String get mtdAverageShort => 'Media MTD';

  @override
  String get multiple => 'Multiplo';

  @override
  String get mysticTheme => 'Mistico';

  @override
  String get mysticThemeDesc => 'Tema viola mistico';

  @override
  String nDaysLabel(Object count) {
    return '$count giorni';
  }

  @override
  String get nameHint => 'Es: Allenamento quotidiano';

  @override
  String get newCategory => 'Nuova categoria';

  @override
  String get newHabits => 'Nuove abitudini';

  @override
  String get next => 'Successivo';

  @override
  String get nextLabel => 'Successivo';

  @override
  String get nextYear => 'Anno prossimo';

  @override
  String get noDataLast7Days => 'Nessun dato per gli ultimi 7 giorni';

  @override
  String get noDataThisMonth => 'Nessun dato per questo mese';

  @override
  String get noEndDate => 'Nessuna data di fine';

  @override
  String get noEndDayDefaultsDaily =>
      'Quando non è impostato un giorno di fine, questa abitudine apparirà ogni giorno per impostazione predefinita.';

  @override
  String get noEntriesYet => 'Ancora nessuna voce';

  @override
  String get noExpenseInThisCategory => 'Nessuna spesa in questa categoria';

  @override
  String get noExpenses => 'Nessuna spesa';

  @override
  String get noExpensesThisMonth => 'Nessuna spesa per questo mese';

  @override
  String get noHabitsAddedYet => 'Nessuna abitudine ancora aggiunta.';

  @override
  String get noIncomeThisMonth => 'Nessun reddito per questo mese';

  @override
  String get noLinkedHabitsInVision =>
      'Nessuna abitudine collegata a questa visione.';

  @override
  String get noReadyVisionsFound => 'Nessuna visione pronta trovata.';

  @override
  String get noRecordsThisMonth => 'Nessuna registrazione per questo mese';

  @override
  String get notAddedYet => 'Non ancora aggiunto.';

  @override
  String get notUnlocked => 'Non sbloccato';

  @override
  String get noteOptional => 'Nota (opzionale)';

  @override
  String get notifications => 'Notifiche';

  @override
  String get numberLabel => 'Numero';

  @override
  String get numericExample => 'Bevi 8 bicchieri d\'acqua al giorno';

  @override
  String get numericSettings => 'Impostazioni obiettivo numerico';

  @override
  String get numericalDescription => 'Tracciamento obiettivo numerico';

  @override
  String get numericalGoalShort => 'Obiettivo numerico';

  @override
  String get numericalType => 'Valore numerico';

  @override
  String get oceanTheme => 'Oceano';

  @override
  String get oceanThemeDesc => 'Tema blu tranquillo';

  @override
  String get onDailyLimit => 'Hai raggiunto il tuo limite giornaliero.';

  @override
  String get onPeriodic => 'A intervalli specifici';

  @override
  String get onSpecificMonthDays => 'In giorni specifici del mese';

  @override
  String get onSpecificWeekdays => 'In giorni specifici della settimana';

  @override
  String get onSpecificYearDays => 'In giorni specifici dell\'anno';

  @override
  String get once => 'Una volta';

  @override
  String get other => 'Altro';

  @override
  String get outline => 'Contorno';

  @override
  String get outlineColor => 'Colore contorno';

  @override
  String get pages => 'Pagine';

  @override
  String get pause => 'Pausa';

  @override
  String get periodicSelection => 'Selezione periodica';

  @override
  String get pickTodaysMood => 'Scegli l\'umore di oggi';

  @override
  String get plannedMonthlySpend => 'Spesa mensile pianificata';

  @override
  String get plateColor => 'Colore piatto';

  @override
  String get previous => 'Precedente';

  @override
  String get previousYear => 'Anno precedente';

  @override
  String get privacySecurity => 'Privacy e sicurezza';

  @override
  String get productivity => 'Produttività';

  @override
  String get profile => 'Profilo';

  @override
  String get profileInfo => 'Informazioni profilo';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String get readyVisionsLoadFailed =>
      'Impossibile caricare le visioni pronte.';

  @override
  String get recurringMonthlyDesc =>
      'Aggiungi automaticamente ogni mese nella data selezionata';

  @override
  String get recurringMonthlyTitle => 'Ricorrente (mensile)';

  @override
  String get reload => 'Ricarica';

  @override
  String get remainingToday => 'Rimanente oggi';

  @override
  String get reminderFrequency => 'Frequenza promemoria';

  @override
  String get reminderSettings => 'Impostazioni promemoria';

  @override
  String get reminderTime => 'Ora promemoria';

  @override
  String get repeatEveryDay => 'Si ripete ogni giorno';

  @override
  String get repeatEveryNDays => 'Ripeti ogni N giorni';

  @override
  String get reset => 'Ripristina';

  @override
  String get retry => 'Riprova';

  @override
  String ruleEnteredDurationAtLeast(Object target) {
    return 'Regola: Durata inserita ≥ $target';
  }

  @override
  String ruleEnteredDurationAtMost(Object target) {
    return 'Regola: Durata inserita ≤ $target';
  }

  @override
  String ruleEnteredDurationExactly(Object target) {
    return 'Regola: Durata inserita = $target';
  }

  @override
  String ruleEnteredValueAtLeast(Object target) {
    return 'Regola: Valore inserito ≥ $target';
  }

  @override
  String ruleEnteredValueAtMost(Object target) {
    return 'Regola: Valore inserito ≤ $target';
  }

  @override
  String ruleEnteredValueExactly(Object target) {
    return 'Regola: Valore inserito = $target';
  }

  @override
  String get save => 'Salva';

  @override
  String get saved => 'Salvato';

  @override
  String get savingsBudgetPlan => 'Piano di risparmio / budget';

  @override
  String get scheduleHabit => 'Imposta il programma della tua abitudine';

  @override
  String get scheduleLabel => 'Programma';

  @override
  String get schedulingOptions => 'Opzioni di pianificazione';

  @override
  String get seconds => 'Secondi';

  @override
  String get select => 'Seleziona';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get selectCategory => 'Seleziona categoria';

  @override
  String get selectDate => 'Seleziona Data';

  @override
  String get selectEndDate => 'Seleziona data di fine';

  @override
  String get selectFrequency => 'Seleziona frequenza';

  @override
  String get selectHabitType => 'Seleziona tipo di abitudine';

  @override
  String get sendBackward => 'Porta indietro';

  @override
  String get settings => 'Impostazioni';

  @override
  String get shareAsLink => 'Condividi come link';

  @override
  String get shareLinkCopied => 'Link di condivisione copiato negli appunti.';

  @override
  String get shareVision => 'Condividi visione';

  @override
  String get social => 'Sociale';

  @override
  String get soundAlerts => 'Avvisi sonori';

  @override
  String get specificDaysOfMonth => 'Giorni specifici del mese';

  @override
  String get specificDaysOfWeek => 'Giorni specifici della settimana';

  @override
  String get specificDaysOfYear => 'Giorni specifici dell\'anno';

  @override
  String spendingLessThanDailyAvg(Object amount) {
    return 'Ottimo! Stai spendendo $amount in meno della media giornaliera.';
  }

  @override
  String spendingMoreThanDailyAvg(Object amount) {
    return 'Attenzione! Stai spendendo $amount in più della media giornaliera.';
  }

  @override
  String get start => 'Inizia';

  @override
  String get startDate => 'Data di inizio';

  @override
  String get startDayLabel => 'Giorno di inizio (1-365)';

  @override
  String get statusLabel => 'Stato';

  @override
  String get step => 'Passo';

  @override
  String stepOf(Object current, Object total) {
    return 'Passo $current di $total';
  }

  @override
  String get steps => 'Passi';

  @override
  String streakDays(Object count) {
    return 'Serie di $count giorni';
  }

  @override
  String get streakIndicator => 'Indicatore di serie';

  @override
  String get streakIndicatorDesc => 'Mostra effetti di fiamma e ghiaccio';

  @override
  String successfulDaysCount(Object count) {
    return '$count giorni di successo';
  }

  @override
  String get systemTheme => 'Tema di sistema';

  @override
  String get targetDurationMinutes => 'Durata obiettivo (minuti)';

  @override
  String targetShort(Object value) {
    return 'Obiettivo: $value';
  }

  @override
  String get targetType => 'Tipo di obiettivo';

  @override
  String get targetValue => 'Valore obiettivo';

  @override
  String get targetValueLabel => 'Valore obiettivo';

  @override
  String get taskDescription => 'Descrizione (Opzionale)';

  @override
  String get taskTitle => 'Titolo del compito';

  @override
  String get templateDetailsNotFound => 'Dettagli del modello non trovati';

  @override
  String get templatesTabManual => 'Manuale';

  @override
  String get templatesTabReady => 'Pronto';

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
  String get textLabel => 'Testo';

  @override
  String get theme => 'Tema';

  @override
  String get themeDetails => 'Dettagli Tema';

  @override
  String get themeSelection => 'Selezione Tema';

  @override
  String get thisMonth => 'Questo mese';

  @override
  String get timerCreateTimerHabitFirst => 'Crea prima un\'abitudine con timer';

  @override
  String get timerDescription => 'Tracciamento basato sul tempo';

  @override
  String get timerExample => 'Fai un allenamento di 30 minuti';

  @override
  String get timerHabitLabel => 'Abitudine con timer';

  @override
  String timerPendingDurationLabel(Object duration) {
    return 'Durata in sospeso: $duration';
  }

  @override
  String timerPendingLabel(Object duration) {
    return 'In sospeso: $duration';
  }

  @override
  String get timerPomodoroBreakPhase => 'Pausa';

  @override
  String timerPomodoroCompletedWork(Object count) {
    return 'Lavoro completato: $count';
  }

  @override
  String get timerPomodoroLongBreakIntervalLabel =>
      'Ciclo di pausa lunga (es: 4)';

  @override
  String get timerPomodoroLongBreakMinutesLabel => 'Pausa lunga (min)';

  @override
  String get timerPomodoroSettings => 'Impostazioni Pomodoro';

  @override
  String get timerPomodoroShortBreakMinutesLabel => 'Pausa breve (min)';

  @override
  String get timerPomodoroSkipPhase => 'Salta fase';

  @override
  String get timerPomodoroWorkMinutesLabel => 'Lavoro (min)';

  @override
  String get timerPomodoroWorkPhase => 'Lavoro';

  @override
  String get timerSaveDurationTitle => 'Salva durata';

  @override
  String get timerSaveSessionTitle => 'Salva sessione';

  @override
  String get timerQuickPresets => 'Quick Presets';

  @override
  String get timerSessionAlreadySaved => 'Questa sessione è già salvata';

  @override
  String get totalDuration => 'Durata totale';

  @override
  String get timerSetDurationFirst => 'Imposta prima la durata';

  @override
  String get timerSettings => 'Impostazioni timer';

  @override
  String get timerTabCountdown => 'Conto alla rovescia';

  @override
  String get timerTabPomodoro => 'Pomodoro';

  @override
  String get timerTabStopwatch => 'Cronometro';

  @override
  String get timerType => 'Timer';

  @override
  String get checkboxType => 'Checkbox';

  @override
  String get subtasksType => 'Subtasks';

  @override
  String get times => 'Volte';

  @override
  String get titleHint => 'Es: Spesa, Freelance, ecc.';

  @override
  String get titleOptional => 'Titolo (opzionale)';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get unit => 'Unità';

  @override
  String get unitHint => 'Unità (bicchiere, passo, pagina...)';

  @override
  String get update => 'Aggiorna';

  @override
  String get vision => 'Visione';

  @override
  String visionAutoDurationInfo(Object day) {
    return 'Questa visione utilizzerà l\'ultimo giorno nel modello: $day.';
  }

  @override
  String get visionCreateTitle => 'Crea visione';

  @override
  String get visionDurationNote =>
      'Nota: Quando la visione inizia, viene impostata una durata totale; se il giorno di fine supera questa durata, verrà accorciato automaticamente.';

  @override
  String get visionEditTitle => 'Modifica visione';

  @override
  String get visionEndDayInvalid =>
      'Il giorno di fine deve essere compreso tra 1 e 365';

  @override
  String get visionEndDayLess =>
      'Il giorno di fine non può essere precedente al giorno di inizio';

  @override
  String get visionEndDayQuestion =>
      'In quale giorno della visione dovrebbe finire?';

  @override
  String get visionEndDayRequired => 'Inserisci il giorno di fine';

  @override
  String get visionNoEndDurationInfo =>
      'Nessun giorno di fine specificato. La visione inizierà a tempo indeterminato.';

  @override
  String get visionPlural => 'Visioni';

  @override
  String get visionStartDayInvalid =>
      'Il giorno di inizio deve essere compreso tra 1 e 365';

  @override
  String get visionStartDayQuestion =>
      'In quale giorno della visione dovrebbe iniziare?';

  @override
  String get visionDurationDaysLabel => 'Durata (giorni)';

  @override
  String get visionStartFailed => 'Impossibile avviare la visione.';

  @override
  String visionStartedMessage(Object title) {
    return 'Visione avviata: $title';
  }

  @override
  String get visionStartLabel => 'Vision start: ';

  @override
  String get visual => 'Visivo';

  @override
  String get weekdaysShortFri => 'Ven';

  @override
  String get weekdaysShortMon => 'Lun';

  @override
  String get fortuneTitle => 'Uova della fortuna';

  @override
  String get fortuneQuestionPrompt => 'Fai la tua domanda';

  @override
  String get fortuneQuestionHint => 'Cosa vorresti sapere?';

  @override
  String get fortuneEggsSubtitle =>
      'Scegli un uovo per rivelare la tua fortuna';

  @override
  String get fortuneResultTitle => 'La tua fortuna';

  @override
  String get fortuneNoQuestion => 'Non hai ancora fatto una domanda';

  @override
  String get fortuneDisclaimer => 'La divinazione è solo per intrattenimento';

  @override
  String fortuneEggSemantic(int index) {
    return 'Uovo della fortuna $index';
  }

  @override
  String get fortunePlay => 'Gioca';

  @override
  String get shuffle => 'Mescola';

  @override
  String get ok => 'OK';

  @override
  String get weekdaysShortSat => 'Sab';

  @override
  String get weekdaysShortSun => 'Dom';

  @override
  String get weekdaysShortThu => 'Gio';

  @override
  String get weekdaysShortTue => 'Mar';

  @override
  String get weekdaysShortWed => 'Mer';

  @override
  String get weekly => 'Settimanale';

  @override
  String get weeklyEmailSummary => 'Riepilogo settimanale via email';

  @override
  String get weeklySummaryEmail => 'Email di riepilogo settimanale';

  @override
  String get whichDaysActive => 'Quali giorni dovrebbero essere attivi?';

  @override
  String get whichMonthDays => 'Quali giorni del mese?';

  @override
  String get whichWeekdays => 'Quali giorni della settimana?';

  @override
  String get worldTheme => 'Mondo';

  @override
  String get worldThemeDesc => 'Armonia di tutti i colori';

  @override
  String xpProgressSummary(Object current, Object toNext, Object total) {
    return '$current / $total XP • $toNext XP per il livello successivo';
  }

  @override
  String get yesNoDescription => 'Semplice tracciamento sì/no';

  @override
  String get yesNoExample => 'Ho meditato oggi?';

  @override
  String get yesNoType => 'Sì/No';

  @override
  String get analysis => 'Analisi';

  @override
  String get apply => 'Applica';

  @override
  String get clearFilters => 'Cancella filtri';

  @override
  String get simpleTypeShort => 'Semplice';

  @override
  String get completedSelectedDay => 'Completato (giorno selezionato)';

  @override
  String get incompleteSelectedDay => 'Incompleto (giorno selezionato)';

  @override
  String get manageListsSubtitle =>
      'Aggiungi una nuova lista, rinomina o elimina.';

  @override
  String get editListTitle => 'Modifica lista';

  @override
  String get listNameLabel => 'Nome lista';

  @override
  String get deleteListTitle => 'Elimina lista';

  @override
  String get deleteListMessage =>
      'Questa lista verrà eliminata. Scegli cosa fare con gli elementi collegati:';

  @override
  String get unassignLinkedHabits => 'Disassegna abitudini collegate';

  @override
  String get unassignLinkedDailyTasks =>
      'Disassegna compiti giornalieri collegati';

  @override
  String listCreatedMessage(Object title) {
    return 'Lista creata: $title';
  }

  @override
  String get removeFromList => 'Rimuovi dalla lista';

  @override
  String get createNewList => 'Crea nuova lista';

  @override
  String get dailyTasksSection => 'Compiti giornalieri';

  @override
  String get addToList => 'Aggiungi alla lista';

  @override
  String get deleteTaskConfirmTitle => 'Eliminare il compito?';

  @override
  String get deleteTaskConfirmMessage =>
      'Vuoi eliminare questo compito giornaliero? Questa azione può essere annullata.';

  @override
  String get undo => 'Annulla';

  @override
  String get habitsSection => 'Abitudini';

  @override
  String get noItemsMatchFilters =>
      'Nessun elemento corrisponde ai filtri selezionati';

  @override
  String dailyTaskCreatedMessage(Object title) {
    return 'Compito giornaliero creato: $title';
  }

  @override
  String habitDeletedMessage(Object title) {
    return 'Abitudine eliminata: $title';
  }

  @override
  String habitCreatedMessage(Object title) {
    return 'Abitudine creata: $title';
  }

  @override
  String deleteHabitConfirm(Object title) {
    return 'Eliminare l\'abitudine \"$title\"?';
  }

  @override
  String get enterValueTitle => 'Inserisci valore';

  @override
  String get valueLabel => 'Valore';

  @override
  String get currentStreak => 'Serie attuale';

  @override
  String get longestStreak => 'Serie più lunga';

  @override
  String daysCount(Object count) {
    return '$count giorni';
  }

  @override
  String get success => 'Successo';

  @override
  String get successfulDayLegend => 'Giorno di successo';

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
  String get periodic => 'Periodico';

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
  String get motivation => 'Motivazione';

  @override
  String motivationBody(Object percent, Object period) {
    return 'Ottimo lavoro! $period hai raggiunto un tasso di successo del $percent%.';
  }

  @override
  String get weeklyProgress => 'Progresso settimanale';

  @override
  String get monthlyProgress => 'Progresso mensile';

  @override
  String get yearlyProgress => 'Progresso annuale';

  @override
  String get overall => 'Complessivo';

  @override
  String get overallProgress => 'Progresso complessivo';

  @override
  String get totalSuccessfulDays => 'Totale giorni di successo';

  @override
  String get totalUnsuccessfulDays => 'Totale giorni di insuccesso';

  @override
  String get totalProgress => 'Progresso totale';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get thisYear => 'Quest\'anno';

  @override
  String get badges => 'Distintivi';

  @override
  String get yearly => 'Annuale';

  @override
  String get newList => 'Nuova lista';

  @override
  String taskDeletedMessage(Object title) {
    return 'Compito eliminato: $title';
  }

  @override
  String get clear => 'Cancella';

  @override
  String get createHabitTitle => 'Crea abitudine';

  @override
  String get addDate => 'Aggiungi data';

  @override
  String get listNameHint => 'Es: Salute';

  @override
  String get taskTitleRequired => 'Il titolo del compito è obbligatorio';

  @override
  String get moodFlowTitle => 'Come ti senti?';

  @override
  String get moodFlowSubtitle => 'Traccia il tuo benessere emotivo';

  @override
  String get moodSelection => 'Selezione umore';

  @override
  String get selectYourCurrentMood => 'Seleziona il tuo umore attuale';

  @override
  String get moodTerribleDesc => 'Mi sento molto giù';

  @override
  String get moodBadDesc => 'Sto passando un brutto momento';

  @override
  String get moodNeutralDesc => 'Mi sento bene';

  @override
  String get moodGoodDesc => 'Mi sento positivo';

  @override
  String get moodExcellentDesc => 'Mi sento fantastico';

  @override
  String get feelingMoreSpecific => 'Puoi essere più specifico?';

  @override
  String get selectSubEmotionDesc => 'Seleziona un\'emozione più specifica';

  @override
  String get whatsTheCause => 'Qual è la causa?';

  @override
  String get selectReasonDesc => 'Seleziona cosa sta influenzando il tuo umore';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodExcellent => 'Eccellente';

  @override
  String get howAreYouFeeling => 'Come ti senti?';

  @override
  String get selectYourMood => 'Seleziona il tuo umore';

  @override
  String get subEmotionSelection => 'Selezione sotto-emozione';

  @override
  String get selectSubEmotion => 'Seleziona sotto-emozione';

  @override
  String get subEmotionExhausted => 'Esausto';

  @override
  String get subEmotionHelpless => 'Impotente';

  @override
  String get subEmotionHopeless => 'Senza speranza';

  @override
  String get subEmotionHurt => 'Ferito';

  @override
  String get subEmotionDrained => 'Prosciugato';

  @override
  String get subEmotionAngry => 'Arrabbiato';

  @override
  String get subEmotionSad => 'Triste';

  @override
  String get subEmotionAnxious => 'Ansioso';

  @override
  String get subEmotionStressed => 'Stressato';

  @override
  String get subEmotionDemoralized => 'Demoralizzato';

  @override
  String get subEmotionIndecisive => 'Indeciso';

  @override
  String get subEmotionTired => 'Stanco';

  @override
  String get subEmotionOrdinary => 'Normale';

  @override
  String get subEmotionCalm => 'Calmo';

  @override
  String get subEmotionEmpty => 'Vuoto';

  @override
  String get subEmotionHappy => 'Felice';

  @override
  String get subEmotionCheerful => 'Allegro';

  @override
  String get subEmotionExcited => 'Eccitato';

  @override
  String get subEmotionEnthusiastic => 'Entusiasta';

  @override
  String get subEmotionDetermined => 'Determinato';

  @override
  String get subEmotionMotivated => 'Motivato';

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
  String get reasonWork => 'Lavoro';

  @override
  String get reasonRelationship => 'Relationship';

  @override
  String get reasonFinance => 'Finance';

  @override
  String get reasonHealth => 'Salute';

  @override
  String get reasonSocial => 'Social';

  @override
  String get reasonPersonalGrowth => 'Personal Growth';

  @override
  String get reasonWeather => 'Weather';

  @override
  String get reasonOther => 'Altro';

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
  String get skip => 'Salta';

  @override
  String get habitNotFound => 'Abitudine non trovata.';

  @override
  String get habitUpdatedMessage => 'Abitudine aggiornata.';

  @override
  String get invalidValue => 'Valore non valido';

  @override
  String get nameRequired => 'Il nome è obbligatorio';

  @override
  String get simpleHabitTargetOne => 'Abitudine semplice (obiettivo = 1)';

  @override
  String get typeNotChangeable => 'Il tipo non può essere modificato';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in Mira';

  @override
  String get onboardingWelcomeDesc =>
      'Il tuo tracker di abitudini personale che cresce con te. Scopriamo la tua personalità unica e suggeriamo abitudini su misura per te.';

  @override
  String get onboardingQuizIntro =>
      'Rispondi a qualche domanda per aiutarci a comprendere meglio la tua personalità. Si basa su ricerche psicologiche scientificamente validate.';

  @override
  String get onboardingQ1 =>
      'Mi piace provare nuove esperienze ed esplorare cose sconosciute.';

  @override
  String get onboardingQ2 =>
      'Mantengo il mio spazio organizzato e preferisco una routine quotidiana strutturata.';

  @override
  String get onboardingQ3 =>
      'Mi sento energico quando sono con altre persone e mi piacciono gli incontri sociali.';

  @override
  String get onboardingQ4 =>
      'Preferisco lavorare con gli altri e trovo la cooperazione più efficace della competizione.';

  @override
  String get onboardingQ5 =>
      'Affronto le situazioni stressanti con calma e raramente mi sento ansioso.';

  @override
  String get onboardingQ6 =>
      'Mi piacciono le attività creative come arte, musica o scrittura.';

  @override
  String get onboardingQ7 =>
      'Stabilisco obiettivi chiari per me stesso e lavoro con impegno per raggiungerli.';

  @override
  String get onboardingQ8 =>
      'Preferisco le attività di gruppo allo stare da solo.';

  @override
  String get onboardingQ9 =>
      'Spesso considero i sentimenti degli altri prima di prendere decisioni.';

  @override
  String get onboardingQ10 =>
      'Pianifico in anticipo eventi e compiti importanti.';

  @override
  String get onboardingQ11 =>
      'Mi piace provare approcci diversi invece di restare su un solo metodo.';

  @override
  String get onboardingQ12 =>
      'Rimango calmo sotto pressione e mi riprendo rapidamente dagli ostacoli.';

  @override
  String get likertStronglyDisagree => 'Completamente in disaccordo';

  @override
  String get likertDisagree => 'In disaccordo';

  @override
  String get likertNeutral => 'Neutrale';

  @override
  String get likertAgree => 'D\'accordo';

  @override
  String get likertStronglyAgree => 'Totalmente d\'accordo';

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
  String get selectHabitsToAdd =>
      'Seleziona le abitudini che desideri aggiungere alla tua routine quotidiana:';

  @override
  String get startJourney => 'Inizia il tuo percorso';

  @override
  String get skipOnboarding => 'Salta';

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
    return 'Eseguito backup: $id';
  }

  @override
  String get backupError => 'Backup Error';

  @override
  String restoreSuccess(Object content) {
    return 'Scaricato: $content';
  }

  @override
  String get restoreError => 'Restore Error';

  @override
  String get manageSubscription => 'Gestisci abbonamento';

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
  String get pastelColors => 'Colori pastello';

  @override
  String get habitNameHintTimer => 'Es: Meditazione, Esercizio...';

  @override
  String get habitNameHintNumerical => 'Es: Bere acqua, Leggere pagine...';

  @override
  String get habitDescriptionHint => 'Aggiungi una breve descrizione...';

  @override
  String get target => 'Obiettivo';

  @override
  String get amount => 'Quantità';

  @override
  String get custom => 'Personalizzato';

  @override
  String get customUnitHint => 'Es: porzione, serie, km...';

  @override
  String get unitAdet => 'pz';

  @override
  String get unitBardak => 'bicchiere';

  @override
  String get unitSayfa => 'pag';

  @override
  String get unitKm => 'km';

  @override
  String get unitLitre => 'litro';

  @override
  String get unitKalori => 'cal';

  @override
  String get unitAdim => 'passo';

  @override
  String get unitKez => 'volte';

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
  String get backupFailed => 'Backup fallito';

  @override
  String get restoreFailed => 'Ripristino fallito';

  @override
  String plansLoadError(Object error) {
    return 'Errore nel caricamento dei piani: $error';
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
  String get averageMood => 'Umore medio';

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
  String get noHistory => 'Nessuna cronologia';

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
  String get addTask => 'Aggiungi attività';

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
