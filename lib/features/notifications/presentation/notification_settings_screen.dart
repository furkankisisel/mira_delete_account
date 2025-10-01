import 'package:flutter/material.dart';
import '../../notifications/data/notification_settings_repository.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _loading = true;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await NotificationSettingsRepository.instance.initialize();
    setState(() {
      _enabled = NotificationSettingsRepository.instance.enabled;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Enable notifications'),
                  value: _enabled,
                  onChanged: (v) async {
                    setState(() => _enabled = v);
                    await NotificationSettingsRepository.instance.setEnabled(v);
                  },
                ),
                const ListTile(title: Text('More preferences coming soon...')),
              ],
            ),
    );
  }
}
