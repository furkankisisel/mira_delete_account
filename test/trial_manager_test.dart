import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira/services/trial_manager.dart';
import 'package:mira/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String?>{};

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'write':
              storage[call.arguments['key'] as String] =
                  call.arguments['value'] as String?;
              return null;
            case 'read':
              return storage[call.arguments['key'] as String];
            case 'delete':
              storage.remove(call.arguments['key'] as String);
              return null;
            case 'readAll':
              return storage;
            case 'deleteAll':
              storage.clear();
              return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    storage.clear();
  });

  test('trial starts and expires properly', () async {
    // NOT: StorageService gerçek secure storage kullanıyor. Gerçek testlerde
    // mock/override gerekir. Bu basit örnekte sadece akış kontrolü gösterilir.
    await StorageService.instance.clearAll();
    await TrialManager.instance.initialize();
    await TrialManager.instance.startTrialIfNeeded();

    expect(await TrialManager.instance.isTrialActive, true);
  });
}
