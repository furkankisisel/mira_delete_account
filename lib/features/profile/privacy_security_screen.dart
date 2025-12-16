import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/privacy/privacy_service.dart';
import 'privacy_webview_screen.dart';
import '../../services/storage_service.dart';
import '../notifications/services/notification_service.dart';
import '../habit/domain/habit_repository.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize privacy service if not yet
    PrivacyService.instance.initialize();
  }

  // Minimal wrapper to expose url_launcher functions used above.
  // Kept private and synchronous since url_launcher provides top-level methods.
  // No facade needed; use url_launcher directly below.

  Future<void> _confirmAndDeleteAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: const Text(
          'Tüm uygulama verilerinizi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Clear local storages and notifications
    await StorageService.instance.clearAll();
    await NotificationService.instance.cancelAllHabitReminders();
    await HabitRepository.instance.wipeAllStoredData();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tüm veriler silindi')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacySecurity)),
      body: AnimatedBuilder(
        animation: PrivacyService.instance,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                secondary: const Icon(Icons.analytics_outlined),
                title: const Text('Tanılama verileri'),
                subtitle: const Text(
                  'Uygulama kullanımına dair anonim istatistikleri paylaş',
                ),
                value: PrivacyService.instance.diagnosticsAllowed,
                onChanged: (v) async {
                  await PrivacyService.instance.setDiagnosticsAllowed(v);
                },
              ),
            ),
            Card(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                secondary: const Icon(Icons.report_problem_outlined),
                title: const Text('Çökme raporları'),
                subtitle: const Text(
                  'Uygulama çökmelerinde anonim rapor gönder',
                ),
                value: PrivacyService.instance.crashReportsAllowed,
                onChanged: (v) async {
                  await PrivacyService.instance.setCrashReportsAllowed(v);
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Gizlilik Politikası'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final uri = Uri.parse(
                    'https://furkankisisel.github.io/mira_privacy_policy/privacy_policy.html',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PrivacyWebViewScreen(uri: uri),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
              ),
              title: const Text('Tüm verileri sil'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _confirmAndDeleteAll(context),
            ),
          ],
        ),
      ),
    );
  }
}
