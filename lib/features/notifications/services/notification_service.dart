import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/notification_settings_repository.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _timerChannelId = 'mira_timer_channel';
  static const String _timerChannelName = 'Timer Notifications';
  static const String _timerChannelDescription =
      'Live timer notifications with controls';
  static const int _timerNotificationId = 9999;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
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

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
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
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      onlyAlertOnce: true, // Critical: prevent re-alerting on update
      actions: <AndroidNotificationAction>[
        if (isRunning)
          AndroidNotificationAction(
            'pause',
            '⏸ Duraklat',
            showsUserInterface: true, // Must be true for actions to work
            cancelNotification: false,
          )
        else
          AndroidNotificationAction(
            'resume',
            '▶ Devam',
            showsUserInterface: true, // Must be true for actions to work
            cancelNotification: false,
          ),
        AndroidNotificationAction(
          'stop',
          '⏹ Bitir',
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
    // Placeholder: enable/disable scheduling based on repo.enabled
  }
}
