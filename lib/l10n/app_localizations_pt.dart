// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get about => 'Sobre';

  @override
  String get account => 'Conta';

  @override
  String get achievements => 'Conquistas';

  @override
  String get activeDays => 'Dias ativos';

  @override
  String get add => 'Adicionar';

  @override
  String get addHabit => 'Adicionar hábito';

  @override
  String get addImage => 'Adicionar imagem';

  @override
  String get addNew => 'Adicionar novo';

  @override
  String get addNewHabit => 'Adicionar novo hábito';

  @override
  String get addSpecialDays => 'Adicionar dias especiais';

  @override
  String get addText => 'Adicionar texto';

  @override
  String get advancedHabit => 'Hábito Avançado';

  @override
  String get allLabel => 'Todos';

  @override
  String get alsoDeleteLinkedHabits => 'Excluir também hábitos vinculados';

  @override
  String get amountLabel => 'Valor';

  @override
  String get socialFeedTitle => 'Feed';

  @override
  String get spendingAdvisorTitle => 'Consultor de Despesas';

  @override
  String spendingAdvisorSafe(Object amount) {
    return 'Você pode gastar $amount por dia.';
  }

  @override
  String spendingAdvisorWarning(Object amount) {
    return 'Reduza o gasto diário em $amount para manter o controle.';
  }

  @override
  String get spendingAdvisorOnTrack =>
      'Ótimo! Você está no caminho certo com seu orçamento.';

  @override
  String get spendingAdvisorOverBudget =>
      'Você estourou o orçamento. Pare de gastar.';

  @override
  String get spendingAdvisorNoBudget =>
      'Defina um orçamento para receber conselhos.';

  @override
  String get appTitle => 'Mira';

  @override
  String get appearance => 'Aparência';

  @override
  String get notificationSettings => 'Configurações de notificação';

  @override
  String get notificationSettingsSubtitle =>
      'Configure suas preferências de notificação';

  @override
  String get enableNotifications => 'Ativar notificações';

  @override
  String get notificationsMasterSubtitle =>
      'Controle todas as notificações do aplicativo';

  @override
  String get notificationTypes => 'Tipos de notificações';

  @override
  String get habitReminders => 'Lembretes de hábitos';

  @override
  String get habitRemindersSubtitle => 'Lembretes diários para seus hábitos';

  @override
  String get notificationBehavior => 'Comportamento de notificações';

  @override
  String get sound => 'Som';

  @override
  String get soundSubtitle => 'Reproduzir som com notificações';

  @override
  String get vibration => 'Vibração';

  @override
  String get vibrationSubtitle => 'Vibrar com notificações';

  @override
  String get systemInfo => 'Informações do sistema';

  @override
  String get timezone => 'Fuso horário';

  @override
  String get notificationPermission => 'Permissão de notificação';

  @override
  String get exactAlarmPermission => 'Permissão de alarme exato (Android 12+)';

  @override
  String get granted => 'Concedido';

  @override
  String get notGranted => 'Não concedido';

  @override
  String get importantNotice => 'Aviso importante';

  @override
  String get notificationTroubleshooting =>
      'Para que as notificações funcionem corretamente:\n\n• DESATIVE a otimização de bateria\n• PERMITA atividade em segundo plano\n• Certifique-se de que as permissões de notificação estejam ATIVADAS\n• Verifique o modo \'Não perturbe\'';

  @override
  String approxVisionDurationDays(Object days) {
    return 'Esta visão dura cerca de $days dias';
  }

  @override
  String get assetsReloadHint =>
      'Pode ser necessário reiniciar completamente o aplicativo para carregar alguns recursos.';

  @override
  String get atLeast => 'Pelo menos';

  @override
  String get atMost => 'No máximo';

  @override
  String get backgroundPlate => 'Placa de fundo';

  @override
  String get badgeActive100dDesc => 'Estar ativo em 100 dias diferentes';

  @override
  String get badgeActive100dTitle => '100 Dias Ativo';

  @override
  String get badgeActive30dDesc => 'Estar ativo em 30 dias diferentes';

  @override
  String get badgeActive30dTitle => '30 Dias Ativo';

  @override
  String get badgeActive7dDesc => 'Estar ativo em 7 dias diferentes';

  @override
  String get badgeActive7dTitle => '7 Dias Ativo';

  @override
  String get badgeCategoryActivity => 'Atividade';

  @override
  String get badgeCategoryFinance => 'Finanças';

  @override
  String get badgeCategoryHabit => 'Hábito';

  @override
  String get badgeCategoryLevel => 'Nível';

  @override
  String get badgeCategoryVision => 'Visão';

  @override
  String get badgeCategoryXp => 'XP';

  @override
  String get badgeFin100Desc => 'Registrar 100 transações';

  @override
  String get badgeFin100Title => 'Financista 100';

  @override
  String get badgeFin10Desc => 'Registrar 10 transações';

  @override
  String get badgeFin10Title => 'Financista 10';

  @override
  String get badgeFin250Desc => 'Registrar 250 transações';

  @override
  String get badgeFin250Title => 'Financista 250';

  @override
  String get badgeFin50Desc => 'Registrar 50 transações';

  @override
  String get badgeFin50Title => 'Financista 50';

  @override
  String get badgeHabit100Desc => 'Completar 100 hábitos no total';

  @override
  String get badgeHabit100Title => 'Hábito 100';

  @override
  String get badgeHabit10Desc => 'Completar 10 hábitos no total';

  @override
  String get badgeHabit10Title => 'Hábito 10';

  @override
  String get badgeHabit200Desc => 'Completar 200 hábitos no total';

  @override
  String get badgeHabit200Title => 'Hábito 200';

  @override
  String get badgeHabit50Desc => 'Completar 50 hábitos no total';

  @override
  String get badgeHabit50Title => 'Hábito 50';

  @override
  String get badgeLevel10Desc => 'Alcançar o nível 10';

  @override
  String get badgeLevel10Title => 'Nível 10';

  @override
  String get badgeLevel20Desc => 'Alcançar o nível 20';

  @override
  String get badgeLevel20Title => 'Nível 20';

  @override
  String get badgeLevel5Desc => 'Alcançar o nível 5';

  @override
  String get badgeLevel5Title => 'Nível 5';

  @override
  String get badgeVision10Desc => 'Criar 10 visões';

  @override
  String get badgeVision10Title => 'Grande Mestre da Visão';

  @override
  String get badgeVision1Desc => 'Crie sua primeira visão';

  @override
  String get badgeVision1Title => 'Visionário';

  @override
  String get badgeVision5Desc => 'Criar 5 visões';

  @override
  String get badgeVision5Title => 'Mestre da Visão';

  @override
  String get badgeVisionHabits3Desc => 'Vincular 3+ hábitos a uma visão';

  @override
  String get badgeVisionHabits3Title => 'Conector';

  @override
  String get badgeXp1000Desc => 'Ganhar um total de 1000 XP';

  @override
  String get badgeXp1000Title => '1000 XP';

  @override
  String get badgeXp500Desc => 'Ganhar um total de 500 XP';

  @override
  String get badgeXp500Title => '500 XP';

  @override
  String get between1And360 => 'Entre 1 e 360';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Uma breve biografia sobre você';

  @override
  String get breakTime => 'Pausa';

  @override
  String get breakdownByCategory => 'Detalhamento por categoria';

  @override
  String get bringForward => 'Trazer para a frente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get category => 'Categoria';

  @override
  String get categoryName => 'Nome da Categoria';

  @override
  String get chooseBestCategory =>
      'Escolha a melhor categoria para o seu hábito';

  @override
  String get chooseColor => 'Escolha a Cor:';

  @override
  String get chooseEmoji => 'Escolha o Emoji:';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get close => 'Fechar';

  @override
  String get colorLabel => 'Cor';

  @override
  String get colorTheme => 'Tema de cor';

  @override
  String get countdownConfigureTitle => 'Configurar Contagem Regressiva';

  @override
  String get create => 'Criar';

  @override
  String get createAdvancedHabit => 'Criar Hábito Avançado';

  @override
  String get createDailyTask => 'Criar tarefa diária';

  @override
  String get createHabitTemplateTitle => 'Criar Modelo de Hábito';

  @override
  String get createList => 'Criar Lista';

  @override
  String get createNewCategory => 'Criar Nova Categoria';

  @override
  String get createVision => 'Criar Visão';

  @override
  String get createVisionTemplateTitle => 'Criar Modelo de Visão';

  @override
  String get customCategories => 'Categorias Personalizadas';

  @override
  String get customEmojiHint => 'Ex: ✨';

  @override
  String get customEmojiOptional => 'Emoji personalizado (opcional)';

  @override
  String get reminder => 'Lembrete';

  @override
  String get enableReminder => 'Ativar Lembrete';

  @override
  String get selectTime => 'Selecionar horário';

  @override
  String get customFrequency => 'Personalizado';

  @override
  String get daily => 'Diário';

  @override
  String get dailyCheck => 'Verificação diária';

  @override
  String get dailyLimit => 'Limite diário';

  @override
  String get dailyTask => 'Tarefa diária';

  @override
  String get darkTheme => 'Tema escuro';

  @override
  String get dashboard => 'Painel';

  @override
  String get date => 'Data';

  @override
  String dayRangeShort(Object end, Object start) {
    return 'Dia $start–$end';
  }

  @override
  String dayShort(Object day) {
    return 'Dia $day';
  }

  @override
  String daysAverageShort(Object days) {
    return '${days}d méd.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String deleteCategoryConfirmNamed(Object name) {
    return 'Excluir a categoria \"$name\"?';
  }

  @override
  String get deleteCategoryTitle => 'Excluir categoria';

  @override
  String get deleteCustomCategoryConfirm =>
      'Excluir esta categoria personalizada?';

  @override
  String get deleteEntryConfirm => 'Excluir esta entrada?';

  @override
  String deleteTransactionConfirm(Object title) {
    return 'Excluir o registro \"$title\"?';
  }

  @override
  String get deleteVisionMessage => 'Excluir esta visão?';

  @override
  String get deleteVisionTitle => 'Excluir visão';

  @override
  String get descHint => 'Detalhes sobre o seu hábito (opcional)';

  @override
  String get difficulty => 'Nível de Dificuldade';

  @override
  String get duration => 'Duração';

  @override
  String get durationAutoLabel => 'Duração (auto)';

  @override
  String get durationSelection => 'Seleção de duração';

  @override
  String get durationType => 'Tipo de Duração';

  @override
  String get earthTheme => 'Terra';

  @override
  String get earthThemeDesc => 'Cores da terra';

  @override
  String get easy => 'Fácil';

  @override
  String get edit => 'Editar';

  @override
  String get editCategory => 'Editar Categoria';

  @override
  String get editHabit => 'Editar Hábito';

  @override
  String get education => 'Educação';

  @override
  String get emojiLabel => 'Emoji';

  @override
  String get endDate => 'Data de Término';

  @override
  String get endDayOptionalLabel => 'Dia de término (opcional)';

  @override
  String get enterMonthlyPlanToComputeDailyLimit =>
      'Insira um plano mensal para calcular um limite diário.';

  @override
  String get enterNameAndDesc => 'Insira o nome e a descrição do seu hábito';

  @override
  String get enterYourName => 'Insira seu nome';

  @override
  String get entries => 'Entradas';

  @override
  String get everyNDaysQuestion => 'A cada quantos dias?';

  @override
  String get everyday => 'Todos os dias';

  @override
  String get exact => 'Exato';

  @override
  String examplePrefix(Object example) {
    return 'Exemplo: $example';
  }

  @override
  String get expenseDelta => 'Despesa Δ';

  @override
  String get expenseDistributionPie => 'Distribuição de despesas (pizza)';

  @override
  String get expenseEditTitle => 'Editar Despesa';

  @override
  String get expenseLabel => 'Despesa';

  @override
  String get expenseNewTitle => 'Nova Despesa';

  @override
  String failedToLoad(Object error) {
    return 'Falha ao carregar: $error';
  }

  @override
  String get filterTitle => 'Filtro';

  @override
  String get finance => 'Finanças';

  @override
  String financeAnalysisTitle(Object month) {
    return 'Análise Financeira · $month';
  }

  @override
  String get financeLast7Days => 'Finanças · Últimos 7 dias';

  @override
  String get finish => 'Concluir';

  @override
  String get historyTitle => 'History';

  @override
  String get fitness => 'Fitness';

  @override
  String get fixedDuration => 'Fixo';

  @override
  String get font => 'Fonte';

  @override
  String get forestTheme => 'Floresta';

  @override
  String get forestThemeDesc => 'Tema verde natural';

  @override
  String get forever => 'Para sempre';

  @override
  String get frequency => 'Frequência';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get fullScreen => 'Tela cheia';

  @override
  String get gallery => 'Galeria';

  @override
  String get general => 'Geral';

  @override
  String get generalNotifications => 'Notificações gerais';

  @override
  String get glasses => 'Copos';

  @override
  String get goldenTheme => 'Dourado';

  @override
  String get goldenThemeDesc => 'Tema dourado quente';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get habit => 'Hábito';

  @override
  String get habitDescription => 'Descrição';

  @override
  String get habitDetails => 'Detalhes do Hábito';

  @override
  String get habitName => 'Nome do Hábito';

  @override
  String get habitOfThisVision => 'Hábito desta visão';

  @override
  String get habits => 'Hábitos';

  @override
  String get hard => 'Difícil';

  @override
  String get headerFocusLabel => 'Foco';

  @override
  String get headerFocusReady => 'Pronto';

  @override
  String get headerHabitsLabel => 'Hábito';

  @override
  String get health => 'Saúde';

  @override
  String get hours => 'Horas';

  @override
  String get howOftenDoHabit =>
      'Decida com que frequência você fará seu hábito';

  @override
  String get howToEarn => 'Como ganhar';

  @override
  String get howToTrackHabit => 'Escolha como seu hábito será rastreado';

  @override
  String get ifCondition => 'Se';

  @override
  String get importFromLink => 'Importar do link';

  @override
  String get incomeDelta => 'Δ de renda';

  @override
  String get incomeEditTitle => 'Editar Renda';

  @override
  String get incomeLabel => 'Renda';

  @override
  String get incomeNewTitle => 'Nova Renda';

  @override
  String get input => 'Entrada';

  @override
  String get invalidLink => 'Link inválido.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSelection => 'Seleção de Idioma';

  @override
  String levelLabel(Object level) {
    return 'Nível $level';
  }

  @override
  String levelShort(Object level) {
    return 'N$level';
  }

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get linkHabits => 'Vincular hábitos';

  @override
  String get listLabel => 'Lista';

  @override
  String get loadingHabits => 'Carregando hábitos...';

  @override
  String get logout => 'Sair';

  @override
  String get manageLists => 'Gerenciar listas';

  @override
  String get medium => 'Médio';

  @override
  String get mindfulness => 'Mindfulness';

  @override
  String get minutes => 'Minutos';

  @override
  String get minutesSuffixShort => 'min';

  @override
  String get monthCount => 'Contagem de meses';

  @override
  String get monthCountHint => 'Ex: 12';

  @override
  String get monthSuffixShort => 'mês';

  @override
  String get monthly => 'Mensal';

  @override
  String get monthlyTrend => 'Tendência mensal';

  @override
  String get mood => 'Humor';

  @override
  String get moodBad => 'Ruim';

  @override
  String get moodGood => 'Bom';

  @override
  String get moodGreat => 'Ótimo';

  @override
  String get moodOk => 'Ok';

  @override
  String get moodTerrible => 'Terrível';

  @override
  String get mtdAverageShort => 'Média MTD';

  @override
  String get multiple => 'Múltiplo';

  @override
  String get mysticTheme => 'Místico';

  @override
  String get mysticThemeDesc => 'Tema roxo místico';

  @override
  String nDaysLabel(Object count) {
    return '$count dias';
  }

  @override
  String get nameHint => 'Ex: Treino diário';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get newHabits => 'Novos hábitos';

  @override
  String get next => 'Próximo';

  @override
  String get nextLabel => 'Próximo';

  @override
  String get nextYear => 'Próximo ano';

  @override
  String get noDataLast7Days => 'Sem dados nos últimos 7 dias';

  @override
  String get noDataThisMonth => 'Sem dados para este mês';

  @override
  String get noEndDate => 'Sem data de término';

  @override
  String get noEndDayDefaultsDaily =>
      'Quando nenhum dia de término é definido, este hábito aparecerá todos os dias por padrão.';

  @override
  String get noEntriesYet => 'Nenhuma entrada ainda';

  @override
  String get noExpenseInThisCategory => 'Nenhuma despesa nesta categoria';

  @override
  String get noExpenses => 'Nenhuma despesa';

  @override
  String get noExpensesThisMonth => 'Nenhuma despesa para este mês';

  @override
  String get noHabitsAddedYet => 'Nenhum hábito adicionado ainda.';

  @override
  String get noIncomeThisMonth => 'Nenhuma renda para este mês';

  @override
  String get noLinkedHabitsInVision => 'Nenhum hábito vinculado a esta visão.';

  @override
  String get noReadyVisionsFound => 'Nenhuma visão pronta encontrada.';

  @override
  String get noRecordsThisMonth => 'Nenhum registro para este mês';

  @override
  String get notAddedYet => 'Ainda não adicionado.';

  @override
  String get notUnlocked => 'Não desbloqueado';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get notifications => 'Notificações';

  @override
  String get numberLabel => 'Número';

  @override
  String get numericExample => 'Beber 8 copos de água por dia';

  @override
  String get numericSettings => 'Configurações de Meta Numérica';

  @override
  String get numericalDescription => 'Rastreamento de meta numérica';

  @override
  String get numericalGoalShort => 'Meta numérica';

  @override
  String get numericalType => 'Valor Numérico';

  @override
  String get oceanTheme => 'Oceano';

  @override
  String get oceanThemeDesc => 'Tema azul tranquilo';

  @override
  String get onDailyLimit => 'Você está no seu limite diário.';

  @override
  String get onPeriodic => 'Em intervalos específicos';

  @override
  String get onSpecificMonthDays => 'Em dias específicos do mês';

  @override
  String get onSpecificWeekdays => 'Em dias específicos da semana';

  @override
  String get onSpecificYearDays => 'Em dias específicos do ano';

  @override
  String get once => 'Uma vez';

  @override
  String get other => 'Outro';

  @override
  String get outline => 'Contorno';

  @override
  String get outlineColor => 'Cor do contorno';

  @override
  String get pages => 'Páginas';

  @override
  String get pause => 'Pausar';

  @override
  String get periodicSelection => 'Seleção Periódica';

  @override
  String get pickTodaysMood => 'Escolha o humor de hoje';

  @override
  String get plannedMonthlySpend => 'Gasto mensal planejado';

  @override
  String get plateColor => 'Cor da placa';

  @override
  String get previous => 'Anterior';

  @override
  String get previousYear => 'Ano anterior';

  @override
  String get privacySecurity => 'Privacidade e segurança';

  @override
  String get productivity => 'Produtividade';

  @override
  String get profile => 'Perfil';

  @override
  String get profileInfo => 'Informações do perfil';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get readyVisionsLoadFailed =>
      'Não foi possível carregar as visões prontas.';

  @override
  String get recurringMonthlyDesc =>
      'Adicionar automaticamente todos os meses na data selecionada';

  @override
  String get recurringMonthlyTitle => 'Recorrente (mensal)';

  @override
  String get reload => 'Recarregar';

  @override
  String get remainingToday => 'Restante hoje';

  @override
  String get reminderFrequency => 'Frequência do Lembrete';

  @override
  String get reminderSettings => 'Configurações de Lembrete';

  @override
  String get reminderTime => 'Hora do Lembrete';

  @override
  String get repeatEveryDay => 'Repete todos os dias';

  @override
  String get repeatEveryNDays => 'Repetir a Cada N Dias';

  @override
  String get reset => 'Redefinir';

  @override
  String get retry => 'Tentar novamente';

  @override
  String ruleEnteredDurationAtLeast(Object target) {
    return 'Regra: Duração inserida ≥ $target';
  }

  @override
  String ruleEnteredDurationAtMost(Object target) {
    return 'Regra: Duração inserida ≤ $target';
  }

  @override
  String ruleEnteredDurationExactly(Object target) {
    return 'Regra: Duração inserida = $target';
  }

  @override
  String ruleEnteredValueAtLeast(Object target) {
    return 'Regra: Valor inserido ≥ $target';
  }

  @override
  String ruleEnteredValueAtMost(Object target) {
    return 'Regra: Valor inserido ≤ $target';
  }

  @override
  String ruleEnteredValueExactly(Object target) {
    return 'Regra: Valor inserido = $target';
  }

  @override
  String get save => 'Salvar';

  @override
  String get saved => 'Salvo';

  @override
  String get savingsBudgetPlan => 'Plano de Poupança / Orçamento';

  @override
  String get scheduleHabit => 'Defina o cronograma do seu hábito';

  @override
  String get scheduleLabel => 'Cronograma';

  @override
  String get schedulingOptions => 'Opções de Agendamento';

  @override
  String get seconds => 'Segundos';

  @override
  String get select => 'Selecionar';

  @override
  String get selectAll => 'Selecionar Tudo';

  @override
  String get selectCategory => 'Selecionar Categoria';

  @override
  String get selectDate => 'Selecionar Data';

  @override
  String get selectEndDate => 'Selecionar data de término';

  @override
  String get selectFrequency => 'Selecionar Frequência';

  @override
  String get selectHabitType => 'Selecionar Tipo de Hábito';

  @override
  String get sendBackward => 'Enviar para trás';

  @override
  String get settings => 'Configurações';

  @override
  String get shareAsLink => 'Compartilhar como link';

  @override
  String get shareLinkCopied =>
      'Link de compartilhamento copiado para a área de transferência.';

  @override
  String get shareVision => 'Compartilhar visão';

  @override
  String get social => 'Social';

  @override
  String get soundAlerts => 'Alertas sonoros';

  @override
  String get specificDaysOfMonth => 'Dias Específicos do Mês';

  @override
  String get specificDaysOfWeek => 'Dias Específicos da Semana';

  @override
  String get specificDaysOfYear => 'Dias Específicos do Ano';

  @override
  String spendingLessThanDailyAvg(Object amount) {
    return 'Ótimo! Você está gastando $amount a menos que a média diária.';
  }

  @override
  String spendingMoreThanDailyAvg(Object amount) {
    return 'Atenção! Você está gastando $amount a mais que a média diária.';
  }

  @override
  String get start => 'Iniciar';

  @override
  String get startDate => 'Data de Início';

  @override
  String get startDayLabel => 'Dia de início (1-365)';

  @override
  String get statusLabel => 'Status';

  @override
  String get step => 'Passo';

  @override
  String stepOf(Object current, Object total) {
    return 'Passo $current de $total';
  }

  @override
  String get steps => 'Passos';

  @override
  String streakDays(Object count) {
    return 'Sequência de $count Dias';
  }

  @override
  String get streakIndicator => 'Indicador de sequência';

  @override
  String get streakIndicatorDesc => 'Mostrar efeitos de chama e gelo';

  @override
  String successfulDaysCount(Object count) {
    return '$count Dias de Sucesso';
  }

  @override
  String get systemTheme => 'Tema do sistema';

  @override
  String get targetDurationMinutes => 'Duração Alvo (minutos)';

  @override
  String targetShort(Object value) {
    return 'Meta: $value';
  }

  @override
  String get targetType => 'Tipo de Meta';

  @override
  String get targetValue => 'Valor Alvo';

  @override
  String get targetValueLabel => 'Valor Alvo';

  @override
  String get taskDescription => 'Descrição (Opcional)';

  @override
  String get taskTitle => 'Título da tarefa';

  @override
  String get templateDetailsNotFound => 'Detalhes do modelo não encontrados';

  @override
  String get templatesTabManual => 'Manual';

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
  String get textLabel => 'Texto';

  @override
  String get theme => 'Tema';

  @override
  String get themeDetails => 'Detalhes do Tema';

  @override
  String get themeSelection => 'Seleção de Tema';

  @override
  String get thisMonth => 'Este mês';

  @override
  String get timerCreateTimerHabitFirst =>
      'Crie um hábito de temporizador primeiro';

  @override
  String get timerDescription => 'Rastreamento baseado em tempo';

  @override
  String get timerExample => 'Fazer um treino de 30 minutos';

  @override
  String get timerHabitLabel => 'Hábito de Temporizador';

  @override
  String timerPendingDurationLabel(Object duration) {
    return 'Duração pendente: $duration';
  }

  @override
  String timerPendingLabel(Object duration) {
    return 'Pendente: $duration';
  }

  @override
  String get timerPomodoroBreakPhase => 'Pausa';

  @override
  String timerPomodoroCompletedWork(Object count) {
    return 'Trabalho Concluído: $count';
  }

  @override
  String get timerPomodoroLongBreakIntervalLabel =>
      'Ciclo de Pausa Longa (ex: 4)';

  @override
  String get timerPomodoroLongBreakMinutesLabel => 'Pausa Longa (min)';

  @override
  String get timerPomodoroSettings => 'Configurações do Pomodoro';

  @override
  String get timerPomodoroShortBreakMinutesLabel => 'Pausa Curta (min)';

  @override
  String get timerPomodoroSkipPhase => 'Pular Fase';

  @override
  String get timerPomodoroWorkMinutesLabel => 'Trabalho (min)';

  @override
  String get timerPomodoroWorkPhase => 'Trabalho';

  @override
  String get timerSaveDurationTitle => 'Salvar Duração';

  @override
  String get timerSaveSessionTitle => 'Salvar Sessão';

  @override
  String get timerQuickPresets => 'Quick Presets';

  @override
  String get timerSessionAlreadySaved => 'Esta sessão já foi salva';

  @override
  String get totalDuration => 'Duração Total';

  @override
  String get timerSetDurationFirst => 'Defina a duração primeiro';

  @override
  String get timerSettings => 'Configurações do Temporizador';

  @override
  String get timerTabCountdown => 'Contagem Regressiva';

  @override
  String get timerTabPomodoro => 'Pomodoro';

  @override
  String get timerTabStopwatch => 'Cronômetro';

  @override
  String get timerType => 'Temporizador';

  @override
  String get checkboxType => 'Checkbox';

  @override
  String get subtasksType => 'Subtasks';

  @override
  String get times => 'Vezes';

  @override
  String get titleHint => 'Ex: Compras, Freelance, etc.';

  @override
  String get titleOptional => 'Título (opcional)';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get unit => 'Unidade';

  @override
  String get unitHint => 'Unidade (copo, passo, página...)';

  @override
  String get update => 'Atualizar';

  @override
  String get vision => 'Visão';

  @override
  String visionAutoDurationInfo(Object day) {
    return 'Esta visão usará o último dia no modelo: $day.';
  }

  @override
  String get visionCreateTitle => 'Criar Visão';

  @override
  String get visionDurationNote =>
      'Nota: Quando a visão começa, uma duração total é definida; se o dia de término exceder essa duração, será encurtado automaticamente.';

  @override
  String get visionEditTitle => 'Editar Visão';

  @override
  String get visionEndDayInvalid => 'O dia de término deve estar entre 1 e 365';

  @override
  String get visionEndDayLess =>
      'O dia de término não pode ser menor que o dia de início';

  @override
  String get visionEndDayQuestion => 'Em que dia da visão ela deve terminar?';

  @override
  String get visionEndDayRequired => 'Insira o dia de término';

  @override
  String get visionNoEndDurationInfo =>
      'Nenhum dia de término especificado. A visão começará em aberto.';

  @override
  String get visionPlural => 'Visões';

  @override
  String get visionStartDayInvalid =>
      'O dia de início deve estar entre 1 e 365';

  @override
  String get visionStartDayQuestion => 'Em que dia da visão ela deve começar?';

  @override
  String get visionDurationDaysLabel => 'Duração (dias)';

  @override
  String get visionStartFailed => 'Não foi possível iniciar a visão.';

  @override
  String visionStartedMessage(Object title) {
    return 'Visão iniciada: $title';
  }

  @override
  String get visionStartLabel => 'Vision start: ';

  @override
  String get visual => 'Visual';

  @override
  String get weekdaysShortFri => 'Sex';

  @override
  String get weekdaysShortMon => 'Seg';

  @override
  String get fortuneTitle => 'Ovos da sorte';

  @override
  String get fortuneQuestionPrompt => 'Faça sua pergunta';

  @override
  String get fortuneQuestionHint => 'O que você gostaria de saber?';

  @override
  String get fortuneEggsSubtitle => 'Escolha um ovo para revelar sua sorte';

  @override
  String get fortuneResultTitle => 'Sua sorte';

  @override
  String get fortuneNoQuestion => 'Você ainda não fez uma pergunta';

  @override
  String get fortuneDisclaimer => 'A adivinhação é apenas para entretenimento';

  @override
  String fortuneEggSemantic(int index) {
    return 'Ovo da sorte $index';
  }

  @override
  String get fortunePlay => 'Jogar';

  @override
  String get shuffle => 'Embaralhar';

  @override
  String get ok => 'OK';

  @override
  String get weekdaysShortSat => 'Sáb';

  @override
  String get weekdaysShortSun => 'Dom';

  @override
  String get weekdaysShortThu => 'Qui';

  @override
  String get weekdaysShortTue => 'Ter';

  @override
  String get weekdaysShortWed => 'Qua';

  @override
  String get weekly => 'Semanal';

  @override
  String get weeklyEmailSummary => 'Resumo semanal por email';

  @override
  String get weeklySummaryEmail => 'Email de resumo semanal';

  @override
  String get whichDaysActive => 'Quais dias devem estar ativos?';

  @override
  String get whichMonthDays => 'Quais dias do mês?';

  @override
  String get whichWeekdays => 'Quais dias da semana?';

  @override
  String get worldTheme => 'Mundo';

  @override
  String get worldThemeDesc => 'Harmonia de todas as cores';

  @override
  String xpProgressSummary(Object current, Object toNext, Object total) {
    return '$current / $total XP • $toNext XP para o próximo nível';
  }

  @override
  String get yesNoDescription => 'Rastreamento simples de sim/não';

  @override
  String get yesNoExample => 'Eu meditei hoje?';

  @override
  String get yesNoType => 'Sim/Não';

  @override
  String get analysis => 'Análise';

  @override
  String get apply => 'Aplicar';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get simpleTypeShort => 'Simples';

  @override
  String get completedSelectedDay => 'Concluído (dia selecionado)';

  @override
  String get incompleteSelectedDay => 'Incompleto (dia selecionado)';

  @override
  String get manageListsSubtitle =>
      'Adicionar uma nova lista, renomear ou excluir.';

  @override
  String get editListTitle => 'Editar lista';

  @override
  String get listNameLabel => 'Nome da lista';

  @override
  String get deleteListTitle => 'Excluir lista';

  @override
  String get deleteListMessage =>
      'Esta lista será excluída. Escolha o que fazer com os itens vinculados:';

  @override
  String get unassignLinkedHabits => 'Desatribuir hábitos vinculados';

  @override
  String get unassignLinkedDailyTasks =>
      'Desatribuir tarefas diárias vinculadas';

  @override
  String listCreatedMessage(Object title) {
    return 'Lista criada: $title';
  }

  @override
  String get removeFromList => 'Remover da lista';

  @override
  String get createNewList => 'Criar nova lista';

  @override
  String get dailyTasksSection => 'Tarefas Diárias';

  @override
  String get addToList => 'Adicionar à lista';

  @override
  String get deleteTaskConfirmTitle => 'Excluir tarefa?';

  @override
  String get deleteTaskConfirmMessage =>
      'Deseja excluir esta tarefa diária? Esta ação pode ser desfeita.';

  @override
  String get undo => 'Desfazer';

  @override
  String get habitsSection => 'Hábitos';

  @override
  String get noItemsMatchFilters =>
      'Nenhum item corresponde aos filtros selecionados';

  @override
  String dailyTaskCreatedMessage(Object title) {
    return 'Tarefa diária criada: $title';
  }

  @override
  String habitDeletedMessage(Object title) {
    return 'Hábito excluído: $title';
  }

  @override
  String habitCreatedMessage(Object title) {
    return 'Hábito criado: $title';
  }

  @override
  String deleteHabitConfirm(Object title) {
    return 'Excluir o hábito \"$title\"?';
  }

  @override
  String get enterValueTitle => 'Inserir Valor';

  @override
  String get valueLabel => 'Valor';

  @override
  String get currentStreak => 'Sequência Atual';

  @override
  String get longestStreak => 'Maior Sequência';

  @override
  String daysCount(Object count) {
    return '$count dias';
  }

  @override
  String get success => 'Sucesso';

  @override
  String get successfulDayLegend => 'Dia de sucesso';

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
  String get periodic => 'Periódico';

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
  String get motivation => 'Motivação';

  @override
  String motivationBody(Object percent, Object period) {
    return 'Ótimo trabalho! $period você alcançou uma taxa de sucesso de $percent%.';
  }

  @override
  String get weeklyProgress => 'Progresso Semanal';

  @override
  String get monthlyProgress => 'Progresso Mensal';

  @override
  String get yearlyProgress => 'Progresso Anual';

  @override
  String get overall => 'Geral';

  @override
  String get overallProgress => 'Progresso Geral';

  @override
  String get totalSuccessfulDays => 'Total de Dias de Sucesso';

  @override
  String get totalUnsuccessfulDays => 'Total de Dias sem Sucesso';

  @override
  String get totalProgress => 'Progresso Total';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisYear => 'Este ano';

  @override
  String get badges => 'Distintivos';

  @override
  String get yearly => 'Anual';

  @override
  String get newList => 'Nova lista';

  @override
  String taskDeletedMessage(Object title) {
    return 'Tarefa excluída: $title';
  }

  @override
  String get clear => 'Limpar';

  @override
  String get createHabitTitle => 'Criar Hábito';

  @override
  String get addDate => 'Adicionar data';

  @override
  String get listNameHint => 'Ex: Saúde';

  @override
  String get taskTitleRequired => 'O título da tarefa é obrigatório';

  @override
  String get moodFlowTitle => 'Como você está se sentindo?';

  @override
  String get moodFlowSubtitle => 'Acompanhe seu bem-estar emocional';

  @override
  String get moodSelection => 'Seleção de humor';

  @override
  String get selectYourCurrentMood => 'Selecione seu humor atual';

  @override
  String get moodTerribleDesc => 'Me sentindo muito mal';

  @override
  String get moodBadDesc => 'Passando por um momento difícil';

  @override
  String get moodNeutralDesc => 'Me sentindo bem';

  @override
  String get moodGoodDesc => 'Me sentindo positivo';

  @override
  String get moodExcellentDesc => 'Me sentindo incrível';

  @override
  String get feelingMoreSpecific => 'Pode ser mais específico?';

  @override
  String get selectSubEmotionDesc => 'Selecione uma emoção mais específica';

  @override
  String get whatsTheCause => 'Qual é a causa?';

  @override
  String get selectReasonDesc => 'Selecione o que está afetando seu humor';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodExcellent => 'Excelente';

  @override
  String get howAreYouFeeling => 'Como você está se sentindo?';

  @override
  String get selectYourMood => 'Selecione seu humor';

  @override
  String get subEmotionSelection => 'Seleção de sub-emoção';

  @override
  String get selectSubEmotion => 'Selecionar sub-emoção';

  @override
  String get subEmotionExhausted => 'Exausto';

  @override
  String get subEmotionHelpless => 'Impotente';

  @override
  String get subEmotionHopeless => 'Sem esperança';

  @override
  String get subEmotionHurt => 'Machucado';

  @override
  String get subEmotionDrained => 'Esgotado';

  @override
  String get subEmotionAngry => 'Irritado';

  @override
  String get subEmotionSad => 'Triste';

  @override
  String get subEmotionAnxious => 'Ansioso';

  @override
  String get subEmotionStressed => 'Estressado';

  @override
  String get subEmotionDemoralized => 'Desmoralizado';

  @override
  String get subEmotionIndecisive => 'Indeciso';

  @override
  String get subEmotionTired => 'Cansado';

  @override
  String get subEmotionOrdinary => 'Normal';

  @override
  String get subEmotionCalm => 'Calmo';

  @override
  String get subEmotionEmpty => 'Vazio';

  @override
  String get subEmotionHappy => 'Feliz';

  @override
  String get subEmotionCheerful => 'Alegre';

  @override
  String get subEmotionExcited => 'Empolgado';

  @override
  String get subEmotionEnthusiastic => 'Entusiasmado';

  @override
  String get subEmotionDetermined => 'Determinado';

  @override
  String get subEmotionMotivated => 'Motivado';

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
  String get reasonWork => 'Trabalho';

  @override
  String get reasonRelationship => 'Relationship';

  @override
  String get reasonFinance => 'Finance';

  @override
  String get reasonHealth => 'Saúde';

  @override
  String get reasonSocial => 'Social';

  @override
  String get reasonPersonalGrowth => 'Personal Growth';

  @override
  String get reasonWeather => 'Weather';

  @override
  String get reasonOther => 'Outro';

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
  String get skip => 'Pular';

  @override
  String get habitNotFound => 'Hábito não encontrado.';

  @override
  String get habitUpdatedMessage => 'Hábito atualizado.';

  @override
  String get invalidValue => 'Valor inválido';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get simpleHabitTargetOne => 'Hábito simples (meta = 1)';

  @override
  String get typeNotChangeable => 'O tipo não pode ser alterado';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Mira';

  @override
  String get onboardingWelcomeDesc =>
      'Seu rastreador de hábitos pessoal que cresce com você. Vamos descobrir sua personalidade única e sugerir hábitos feitos sob medida para você.';

  @override
  String get onboardingQuizIntro =>
      'Responda a algumas perguntas para nos ajudar a compreender melhor a sua personalidade. Isto baseia-se em pesquisas psicológicas validadas cientificamente.';

  @override
  String get onboardingQ1 =>
      'Gosto de experimentar novas experiências e explorar coisas desconhecidas.';

  @override
  String get onboardingQ2 =>
      'Mantenho meu espaço organizado e prefiro uma rotina diária estruturada.';

  @override
  String get onboardingQ3 =>
      'Sinto-me energizado quando estou com outras pessoas e gosto de encontros sociais.';

  @override
  String get onboardingQ4 =>
      'Prefiro trabalhar com outras pessoas e acho a cooperação mais eficaz do que a competição.';

  @override
  String get onboardingQ5 =>
      'Lido com situações estressantes com calma e raramente me sinto ansioso.';

  @override
  String get onboardingQ6 =>
      'Gosto de atividades criativas como arte, música ou escrita.';

  @override
  String get onboardingQ7 =>
      'Defino metas claras para mim e trabalho com dedicação para alcançá-las.';

  @override
  String get onboardingQ8 =>
      'Prefiro atividades em grupo a passar tempo sozinho.';

  @override
  String get onboardingQ9 =>
      'Frequentemente considero os sentimentos dos outros antes de tomar decisões.';

  @override
  String get onboardingQ10 =>
      'Planejo com antecedência eventos e tarefas importantes.';

  @override
  String get onboardingQ11 =>
      'Gosto de tentar diferentes abordagens em vez de insistir em um único método.';

  @override
  String get onboardingQ12 =>
      'Mantenho a calma sob pressão e me recupero rapidamente de contratempos.';

  @override
  String get likertStronglyDisagree => 'Discordo totalmente';

  @override
  String get likertDisagree => 'Discordo';

  @override
  String get likertNeutral => 'Neutro';

  @override
  String get likertAgree => 'Concordo';

  @override
  String get likertStronglyAgree => 'Concordo totalmente';

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
      'Selecione os hábitos que deseja adicionar à sua rotina diária:';

  @override
  String get startJourney => 'Comece sua jornada';

  @override
  String get skipOnboarding => 'Pular';

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
    return 'Backup realizado: $id';
  }

  @override
  String get backupError => 'Backup Error';

  @override
  String restoreSuccess(Object content) {
    return 'Baixado: $content';
  }

  @override
  String get restoreError => 'Restore Error';

  @override
  String get manageSubscription => 'Gerenciar Assinatura';

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
  String get pastelColors => 'Cores pastel';

  @override
  String get habitNameHintTimer => 'Ex: Meditação, Exercício...';

  @override
  String get habitNameHintNumerical => 'Ex: Beber água, Ler páginas...';

  @override
  String get habitDescriptionHint => 'Adicionar uma breve descrição...';

  @override
  String get target => 'Meta';

  @override
  String get amount => 'Quantidade';

  @override
  String get custom => 'Personalizado';

  @override
  String get customUnitHint => 'Ex: porção, série, km...';

  @override
  String get unitAdet => 'un';

  @override
  String get unitBardak => 'copo';

  @override
  String get unitSayfa => 'pág';

  @override
  String get unitKm => 'km';

  @override
  String get unitLitre => 'litro';

  @override
  String get unitKalori => 'cal';

  @override
  String get unitAdim => 'passo';

  @override
  String get unitKez => 'vezes';

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
  String get backupFailed => 'Falha no backup';

  @override
  String get restoreFailed => 'Falha na restauração';

  @override
  String plansLoadError(Object error) {
    return 'Erro ao carregar planos: $error';
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
  String get averageMood => 'Humor médio';

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
  String get noHistory => 'Sem histórico';

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
  String get addTask => 'Adicionar tarefa';

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
