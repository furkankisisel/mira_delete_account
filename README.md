# mira

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## App Logo

The application logo asset lives at `assets/icons/miralogo.png`.

You can render it in code via the provided `AppLogo` widget:

```dart
import 'package:mira/core/design_system/widgets/app_logo.dart';

Widget build(BuildContext context) {
	return const Center(child: AppLogo(size: 128));
}
```

Optional parameters:

- `size` (double): width & height (square), default 96.
- `semanticLabel` (String?): accessibility label. If omitted the image is treated as decorative.
- `color` (Color?): apply a tint if you need monochrome usage (e.g., in a splash or adaptive theming context).

### Launcher Icons (Optional)

To use the same artwork for platform launcher icons, you can add the [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) dev dependency and a config snippet:

```yaml
dev_dependencies:
	flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
	android: true
	ios: true
	image_path: assets/icons/miralogo.png
	adaptive_icon_background: "#121212"
	adaptive_icon_foreground: assets/icons/miralogo.png
```

Then run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

(The adaptive configuration can be refined by providing separate foreground/background assets.)

