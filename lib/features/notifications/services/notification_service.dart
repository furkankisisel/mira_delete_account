import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../data/notification_settings_repository.dart';
import '../../habit/domain/habit_model.dart';
import '../../../l10n/app_localizations.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  NotificationSettingsRepository? _settingsRepo;
  AppLocalizations? _l10n;

  void updateLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  static const String _timerChannelId = 'mira_timer_channel';
  static const String _timerChannelName = 'Timer Notifications';
  static const String _timerChannelDescription =
      'Live timer notifications with controls';
  static const int _timerNotificationId = 9999;

  Future<void> initialize() async {
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('ic_stat_miralogo');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _timerChannelId,
      _timerChannelName,
      description: _timerChannelDescription,
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    const habitReminderChannel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Daily reminders for your habits',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.createNotificationChannel(habitReminderChannel);

    // Request notification permissions
    final notificationPermission = await androidPlugin
        ?.requestNotificationsPermission();
    print('🔔 Notification permission: $notificationPermission');

    // Do not request exact alarm permission; we use inexact scheduling to avoid this requirement on Android 12+

    _initialized = true;
    print('✅ NotificationService initialized successfully');
  }

  Future<void> _configureLocalTimeZone() async {
    // Initialize timezone database and set the device's local timezone.
    tz.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
      final localized = timeZone.localizedName;
      final displayName = localized != null
          ? '${localized.name} (${localized.locale})'
          : timeZone.identifier;
      print('🕒 Local timezone set to $displayName');
    } catch (e) {
      print(
        '⚠️ Failed to set local timezone from device. Using default. Error: $e',
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification action taps
    print('🔔 Notification response received:');
    print('   actionId: ${response.actionId}');
    print('   payload: ${response.payload}');
    print('   notificationResponseType: ${response.notificationResponseType}');

    // Check action ID first (for button taps)
    if (response.actionId != null && response.actionId!.isNotEmpty) {
      print('   ✅ Calling action handler with: ${response.actionId}');
      _onTimerAction?.call(response.actionId!);
    } else {
      print('   ⚠️ No actionId found');
    }
  }

  // Callback for timer actions
  void Function(String action)? _onTimerAction;

  void setTimerActionHandler(void Function(String action)? handler) {
    _onTimerAction = handler;
  }

  Future<void> showTimerNotification({
    required String title,
    required String body,
    required bool isRunning,
  }) async {
    if (!_initialized) return;

    final androidDetails = AndroidNotificationDetails(
      _timerChannelId,
      _timerChannelName,
      channelDescription: _timerChannelDescription,
      importance: Importance.low, // Changed to low to prevent sound/heads-up
      priority: Priority.low,
      icon: 'ic_stat_miralogo',
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      onlyAlertOnce: true, // Critical: prevent re-alerting on update
      largeIcon: const DrawableResourceAndroidBitmap(
        '@drawable/ic_notification_large',
      ),
      actions: <AndroidNotificationAction>[
        if (isRunning)
          AndroidNotificationAction(
            'pause',
            _l10n?.timerPause ?? '⏸ Duraklat',
            showsUserInterface: true, // Must be true for actions to work
            cancelNotification: false,
          )
        else
          AndroidNotificationAction(
            'resume',
            _l10n?.timerResume ?? '▶ Devam',
            showsUserInterface: true, // Must be true for actions to work
            cancelNotification: false,
          ),
        AndroidNotificationAction(
          'stop',
          _l10n?.timerStop ?? '⏹ Bitir',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      _timerNotificationId,
      title,
      body,
      details,
      payload: 'timer',
    );
  }

  Future<void> cancelTimerNotification() async {
    if (!_initialized) return;
    await _plugin.cancel(_timerNotificationId);
  }

  Future<void> applySettings(NotificationSettingsRepository repo) async {
    if (!_initialized) return;
    _settingsRepo = repo;

    // Register callback for settings changes
    repo.setOnSettingsChangedCallback(() {
      print('⚙️ Notification settings changed, reapplying...');
      _onSettingsChanged();
    });

    print('✅ Notification settings applied');
    print('   Master enabled: ${repo.enabled}');
    print('   Habit reminders: ${repo.habitReminders}');
    print('   Sound: ${repo.sound}');
    print('   Vibration: ${repo.vibration}');
  }

  void _onSettingsChanged() {
    // When settings change, we could reschedule all notifications
    // For now, just log the change
    print('🔄 Settings changed - new notifications will use updated settings');
  }

  bool _shouldShowNotification() {
    return _settingsRepo?.enabled ?? true;
  }

  bool _shouldShowHabitReminder() {
    return (_settingsRepo?.enabled ?? true) &&
        (_settingsRepo?.habitReminders ?? true);
  }

  bool _shouldPlaySound() {
    return (_settingsRepo?.enabled ?? true) && (_settingsRepo?.sound ?? true);
  }

  bool _shouldVibrate() {
    return (_settingsRepo?.enabled ?? true) &&
        (_settingsRepo?.vibration ?? true);
  }

  // Habit Reminder Notifications
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (!_initialized || !habit.reminderEnabled || habit.reminderTime == null) {
      print(
        '⚠️ Cannot schedule reminder: initialized=$_initialized, enabled=${habit.reminderEnabled}, time=${habit.reminderTime}',
      );
      return;
    }

    // Check if habit reminders are enabled in settings
    if (!_shouldShowHabitReminder()) {
      print('⚠️ Habit reminders disabled in settings, skipping schedule');
      return;
    }

    final time = habit.reminderTime!;
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow in local TZ
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('📅 Scheduling reminder for ${habit.title}:');
    print('   Time: ${time.hour}:${time.minute}');
    print('   Scheduled for: $scheduledDate');
    print('   Scheduled for (UTC): ${scheduledDate.toUtc()}');
    print('   Current time: $now');
    print('   Current time (UTC): ${now.toUtc()}');
    print('   TZ Local Location: ${tz.local.name}');
    print('   Time until notification: ${scheduledDate.difference(now)}');

    // Use habit ID hash as notification ID to ensure uniqueness
    final notificationId = habit.id.hashCode.abs() % 2147483647;
    print('   Notification ID: $notificationId');

    // Apply sound and vibration settings
    final playSound = _shouldPlaySound();
    final vibrate = _shouldVibrate();
    print('   Sound: $playSound, Vibration: $vibrate');

    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_miralogo',
      playSound: playSound,
      enableVibration: vibrate,
      largeIcon: const DrawableResourceAndroidBitmap(
        '@drawable/ic_notification_large',
      ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final emoji = habit.emoji ?? '✅';
    final title = '$emoji ${habit.title}';
    final body = _l10n?.habitReminderBody ?? 'Alışkanlığını tamamlama zamanı!';

    try {
      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        // Use inexact scheduling to avoid exact alarm permission on Android 12+
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Try daily repeat at this time
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'habit:${habit.id}',
      );
      print('✅ Reminder scheduled successfully!');
    } on PlatformException catch (e) {
      // Some OEMs/OS versions still enforce exact alarms for repeating schedules
      // Fall back to scheduling a one-off inexact alarm for the next occurrence
      if (e.code == 'exact_alarms_not_permitted') {
        print(
          '⚠️ exact_alarms_not_permitted; falling back to one-shot inexact schedule',
        );
        try {
          await _plugin.zonedSchedule(
            notificationId,
            title,
            body,
            scheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            // No repeat component -> one-shot
            payload: 'habit:${habit.id}',
          );
          print(
            '✅ One-shot reminder scheduled (fallback). Will not auto-repeat.',
          );
        } catch (e2) {
          print('❌ Fallback scheduling failed: $e2');
        }
      } else {
        print('❌ Error scheduling reminder: $e');
      }
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
    }
  }

  Future<void> cancelHabitReminder(Habit habit) async {
    if (!_initialized) return;
    final notificationId = habit.id.hashCode.abs() % 2147483647;
    await _plugin.cancel(notificationId);
  }

  Future<void> cancelAllHabitReminders() async {
    if (!_initialized) return;
    // This will cancel all scheduled notifications
    await _plugin.cancelAll();
  }
}
