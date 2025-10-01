import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/habit/domain/habit_repository.dart';
import '../../features/habit/domain/habit_types.dart';

/// Zamanlayıcı modları
enum TimerMode { stopwatch, countdown, pomodoro }

class TimerSession {
  TimerSession({
    required this.mode,
    required this.duration,
    required this.startedAt,
    required this.endedAt,
    this.label,
    this.completed = true,
    this.assigned = false,
  });
  final TimerMode mode;
  final Duration duration;
  final DateTime startedAt;
  final DateTime endedAt;
  final String? label;
  final bool completed;
  bool assigned;
}

/// Paneldeki mini widget ve tam ekran zamanlayıcı arasında paylaşılan denetleyici.
class TimerController extends ChangeNotifier {
  TimerController._();
  static final TimerController instance = TimerController._();

  Timer? _timer;
  DateTime? _currentStart; // aktif çalışma başlangıç zamanı

  // Stopwatch (kronometre)
  Duration _elapsed = Duration.zero;
  bool _stopwatchRunning = false;

  // Countdown (geri sayım)
  Duration _countdownTotal = Duration.zero;
  Duration _countdownRemaining = Duration.zero;
  bool _countdownRunning = false;

  // Pomodoro
  bool _pomodoroRunning = false;
  bool _pomodoroWorkPhase = true; // true = çalışma, false = mola
  Duration _pomodoroWorkDuration = const Duration(minutes: 25);
  Duration _pomodoroShortBreak = const Duration(minutes: 5);
  Duration _pomodoroLongBreak = const Duration(minutes: 15);
  Duration _pomodoroRemaining = const Duration(minutes: 25);
  int _pomodoroCompletedWorkSessions = 0; // biten çalışma sayısı
  int _pomodoroLongBreakInterval = 4; // kaç çalışma sonra uzun mola

  TimerMode _activeMode = TimerMode.stopwatch;
  final List<TimerSession> _sessions = [];
  String? _activeTimerHabitId; // Oturumların yazılacağı timer habit id'si
  Duration _pending = Duration.zero; // Henüz habit'e aktarılmamış süre toplamı

  List<TimerSession> get sessions => List.unmodifiable(_sessions);
  String? get activeTimerHabitId => _activeTimerHabitId;
  Duration get pendingDuration => _pending;
  bool get hasPending => _pending > Duration.zero;

  void setActiveTimerHabit(String? habitId) {
    _activeTimerHabitId = habitId;
    notifyListeners();
  }

  // Getters
  TimerMode get activeMode => _activeMode;
  Duration get elapsed => _elapsed;
  bool get isRunning => switch (_activeMode) {
    TimerMode.stopwatch => _stopwatchRunning,
    TimerMode.countdown => _countdownRunning,
    TimerMode.pomodoro => _pomodoroRunning,
  };

  Duration get countdownRemaining => _countdownRemaining;
  Duration get countdownTotal => _countdownTotal;

  Duration get pomodoroRemaining => _pomodoroRemaining;
  bool get pomodoroWorkPhase => _pomodoroWorkPhase;
  int get pomodoroCompletedWorkSessions => _pomodoroCompletedWorkSessions;
  Duration get pomodoroWorkDuration => _pomodoroWorkDuration;
  Duration get pomodoroShortBreakDuration => _pomodoroShortBreak;
  Duration get pomodoroLongBreakDuration => _pomodoroLongBreak;
  int get pomodoroLongBreakInterval => _pomodoroLongBreakInterval;

  bool get hasCountdown => _countdownTotal > Duration.zero;

  /// Aktif veya o an çalışan modun ekranda gösterilecek formatlı süresi.
  String get formattedTime {
    if (_pomodoroRunning) return _format(_pomodoroRemaining);
    if (_countdownRunning) return _format(_countdownRemaining);
    return _format(_elapsed);
  }

  String formatDuration(Duration d) => _format(d);

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours.toString().padLeft(2, '0');
    // Her zaman saat:dakika:saniye göster (00:MM:SS)
    return '$hours:$minutes:$seconds';
  }

  // MODE SELECTION
  void setMode(TimerMode mode) {
    if (_activeMode == mode) return;
    _stopAll();
    _activeMode = mode;
    _currentStart = DateTime.now();
    notifyListeners();
  }

  void _stopAll() {
    _timer?.cancel();
    _stopwatchRunning = false;
    _countdownRunning = false;
    _pomodoroRunning = false;
  }

  // STOPWATCH API (geriye dönük uyumluluk)
  void start() {
    setMode(TimerMode.stopwatch);
    if (_stopwatchRunning) return;
    _stopwatchRunning = true;
    // Eğer daha önce başlamış ve pause edilmişse _currentStart null ise yeniden başlat
    _currentStart ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void pause() {
    switch (_activeMode) {
      case TimerMode.stopwatch:
        if (!_stopwatchRunning) return;
        // Kaydetme yok, sadece durdur
        _currentStart = null;
        _stopwatchRunning = false;
        break;
      case TimerMode.countdown:
        if (!_countdownRunning) return;
        _countdownRunning = false;
        break;
      case TimerMode.pomodoro:
        if (!_pomodoroRunning) return;
        _pomodoroRunning = false;
        break;
    }
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    switch (_activeMode) {
      case TimerMode.stopwatch:
        // Kayıt yapmadan sıfırla
        _elapsed = Duration.zero;
        _stopwatchRunning = false;
        _currentStart = null;
        break;
      case TimerMode.countdown:
        _countdownRemaining = _countdownTotal;
        _countdownRunning = false;
        break;
      case TimerMode.pomodoro:
        _pomodoroReset(full: true);
        break;
    }
    _timer?.cancel();
    notifyListeners();
  }

  // COUNTDOWN API
  void setCountdown(Duration duration) {
    _countdownTotal = duration;
    _countdownRemaining = duration;
    notifyListeners();
  }

  void startCountdown() {
    if (_countdownTotal == Duration.zero) return; // ayarlanmamış
    setMode(TimerMode.countdown);
    if (_countdownRunning) return;
    _countdownRunning = true;
    _currentStart ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  // POMODORO API
  void startPomodoro() {
    setMode(TimerMode.pomodoro);
    if (_pomodoroRunning) return;
    _pomodoroRunning = true;
    _currentStart ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void skipPomodoroPhase() {
    if (_activeMode != TimerMode.pomodoro) return;
    _advancePomodoroPhase();
    notifyListeners();
  }

  void setPomodoroConfig({
    required Duration work,
    required Duration shortBreak,
    required Duration longBreak,
    required int longBreakInterval,
  }) {
    // Minimum değerleri garanti altına al
    if (work.inMinutes < 1) work = const Duration(minutes: 1);
    if (shortBreak.inMinutes < 1) shortBreak = const Duration(minutes: 1);
    if (longBreak.inMinutes < 1) longBreak = const Duration(minutes: 1);
    if (longBreakInterval < 1) longBreakInterval = 1;

    _pomodoroWorkDuration = work;
    _pomodoroShortBreak = shortBreak;
    _pomodoroLongBreak = longBreak;
    _pomodoroLongBreakInterval = longBreakInterval;

    // Çalışma fazındaysak kalan süreyi yeni çalışma süresine güncelle
    if (_activeMode == TimerMode.pomodoro) {
      if (_pomodoroWorkPhase) {
        _pomodoroRemaining = _pomodoroWorkDuration;
      } else {
        // Mola fazındaysa uygun mola süresine ayarla
        final isLong =
            _pomodoroCompletedWorkSessions % _pomodoroLongBreakInterval == 0 &&
            _pomodoroCompletedWorkSessions > 0;
        _pomodoroRemaining = isLong ? _pomodoroLongBreak : _pomodoroShortBreak;
      }
    }
    notifyListeners();
  }

  void _pomodoroReset({bool full = false}) {
    _pomodoroRunning = false;
    if (full) {
      _pomodoroCompletedWorkSessions = 0;
      _pomodoroWorkPhase = true;
    }
    _pomodoroRemaining = _pomodoroWorkDuration;
  }

  void _advancePomodoroPhase() {
    if (_pomodoroWorkPhase) {
      // Çalışma bitti -> mola
      _pomodoroCompletedWorkSessions++;
      // Çalışma oturumunu kaydet
      _recordSession(
        TimerMode.pomodoro,
        _pomodoroWorkDuration,
        label: 'Çalışma',
      );
      _pomodoroWorkPhase = false;
      final isLongBreak =
          _pomodoroCompletedWorkSessions % _pomodoroLongBreakInterval == 0;
      _pomodoroRemaining = isLongBreak
          ? _pomodoroLongBreak
          : _pomodoroShortBreak;
    } else {
      // Mola bitti -> çalışma
      // (İstersen mola oturumlarını ekleyebilirsin)
      _pomodoroWorkPhase = true;
      _pomodoroRemaining = _pomodoroWorkDuration;
      _currentStart = DateTime.now();
    }
  }

  // TICK
  void _onTick(Timer timer) {
    switch (_activeMode) {
      case TimerMode.stopwatch:
        if (_stopwatchRunning) {
          _elapsed += const Duration(seconds: 1);
        }
        break;
      case TimerMode.countdown:
        if (_countdownRunning) {
          if (_countdownRemaining > Duration.zero) {
            _countdownRemaining -= const Duration(seconds: 1);
            if (_countdownRemaining < Duration.zero) {
              _countdownRemaining = Duration.zero;
            }
            if (_countdownRemaining == Duration.zero) {
              _countdownRunning = false;
              _timer?.cancel();
              // Otomatik kayıt yok; kullanıcı Bitir'e basınca kaydedilecek
            }
          }
        }
        break;
      case TimerMode.pomodoro:
        if (_pomodoroRunning) {
          if (_pomodoroRemaining > Duration.zero) {
            _pomodoroRemaining -= const Duration(seconds: 1);
            if (_pomodoroRemaining <= Duration.zero) {
              _pomodoroRemaining = Duration.zero;
              // Otomatik faz geçişi veya kayıt yok; kullanıcı Bitir'e basacak
              _pomodoroRunning = false;
              _timer?.cancel();
            }
          }
        }
        break;
    }
    notifyListeners();
  }

  /// Bitir: O anki süreyi oturum olarak kaydet ve pending'e ekle
  void finish() {
    switch (_activeMode) {
      case TimerMode.stopwatch:
        if (_elapsed > Duration.zero) {
          _recordSession(TimerMode.stopwatch, _elapsed, completed: true);
        }
        _elapsed = Duration.zero;
        _stopwatchRunning = false;
        _currentStart = null;
        break;
      case TimerMode.countdown:
        final done = _countdownTotal - _countdownRemaining;
        if (done > Duration.zero) {
          _recordSession(TimerMode.countdown, done, completed: true);
        }
        _countdownRunning = false;
        _countdownRemaining = _countdownTotal;
        break;
      case TimerMode.pomodoro:
        if (_pomodoroWorkPhase) {
          final done = _pomodoroWorkDuration - _pomodoroRemaining;
          if (done > Duration.zero) {
            _recordSession(
              TimerMode.pomodoro,
              done,
              label: 'Çalışma',
              completed: true,
            );
          }
        }
        _pomodoroRunning = false;
        _pomodoroReset(full: false);
        break;
    }
    _timer?.cancel();
    notifyListeners();
  }

  void _recordSession(
    TimerMode mode,
    Duration duration, {
    String? label,
    bool completed = true,
  }) {
    if (duration <= Duration.zero) return;
    final end = DateTime.now();
    final start = _currentStart ?? end.subtract(duration);
    _sessions.insert(
      0,
      TimerSession(
        mode: mode,
        duration: duration,
        startedAt: start,
        endedAt: end,
        label: label,
        completed: completed,
      ),
    );
    // trim optional (keep last 200)
    if (_sessions.length > 200) {
      _sessions.removeRange(200, _sessions.length);
    }
    _currentStart = null;
    // Artık otomatik habit güncellemesi yok; pending'e ekle
    _pending += duration;
    notifyListeners();
  }

  void clearHistory() {
    _sessions.clear();
    notifyListeners();
  }

  Future<bool> assignSessionToHabit(int index, String habitId) async {
    if (index < 0 || index >= _sessions.length) return false;
    final session = _sessions[index];
    if (session.assigned) return false; // zaten kaydedildi
    final repo = HabitRepository.instance;
    final habit = repo.findById(habitId);
    if (habit == null || habit.habitType != HabitType.timer) return false;
    // Habit'e süre ekle
    repo.addTimerProgress(habitId, session.duration);
    session.assigned = true;
    // Pendingten düş
    if (_pending >= session.duration) {
      _pending -= session.duration;
    } else {
      _pending = Duration.zero;
    }
    notifyListeners();
    return true;
  }

  Future<void> savePendingToHabit(String habitId) async {
    if (_pending <= Duration.zero) return;
    final repo = HabitRepository.instance;
    final habit = repo.findById(habitId);
    if (habit == null || habit.habitType != HabitType.timer) return;
    repo.addTimerProgress(habitId, _pending);
    _pending = Duration.zero;
    notifyListeners();
  }

  void discardPending() {
    if (_pending <= Duration.zero) return;
    _pending = Duration.zero;
    notifyListeners();
  }
}
