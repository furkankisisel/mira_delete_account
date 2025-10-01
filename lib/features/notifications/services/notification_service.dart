import '../data/notification_settings_repository.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;

  Future<void> initialize() async {
    // Placeholder: wire up real notifications later
    _initialized = true;
  }

  Future<void> applySettings(NotificationSettingsRepository repo) async {
    if (!_initialized) return;
    // Placeholder: enable/disable scheduling based on repo.enabled
  }
}
