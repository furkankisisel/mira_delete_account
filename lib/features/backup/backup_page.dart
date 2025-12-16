import 'package:flutter/material.dart';
import 'package:mira/l10n/app_localizations.dart';
import 'google_drive_backup_manager.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final TextEditingController _dataCtrl = TextEditingController(
    text: '{"example":"data"}',
  );
  String? _status;
  bool _busy = false;
  List<dynamic> _files = [];

  Future<void> _backup() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    final res = await GoogleDriveBackupManager.instance.backupToDrive(
      _dataCtrl.text,
    );
    setState(() {
      _busy = false;
      _status = res == null
          ? AppLocalizations.of(context)!.backupFailed
          : AppLocalizations.of(context)!.backupSuccess(res);
    });
  }

  Future<void> _refreshList() async {
    setState(() {
      _busy = true;
    });
    final files = await GoogleDriveBackupManager.instance.listBackups();
    setState(() {
      _busy = false;
      _files = files;
    });
  }

  Future<void> _restore(String fileId) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    final content = await GoogleDriveBackupManager.instance.restoreFromDrive(
      fileId,
    );
    setState(() {
      _busy = false;
      _status = content == null
          ? AppLocalizations.of(context)!.restoreFailed
          : AppLocalizations.of(context)!.restoreSuccess(
              content.substring(0, content.length > 100 ? 100 : content.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Yedekleme')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('JSON Veri (örnek):', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _dataCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _backup,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Drive\'a Yedekle'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _refreshList,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Listeyi Yenile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_status != null)
                Text(
                  _status!,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              const Divider(height: 24),
              Expanded(
                child: _files.isEmpty
                    ? const Center(child: Text('Yedek bulunamadı.'))
                    : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (_, i) {
                          final f = _files[i];
                          final name = f.name ?? 'adsız';
                          final id = f.id ?? '';
                          return ListTile(
                            title: Text(name),
                            subtitle: Text(id),
                            trailing: TextButton(
                              onPressed: _busy ? null : () => _restore(id),
                              child: const Text('Geri Yükle'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
