import 'package:flutter/material.dart';

/// A reusable widget to display the Mira application logo.
///
/// Exposes simple sizing + semantic label options. The logo is a raster PNG
/// located at `assets/icons/miralogo.png`. If later an SVG variant is added,
/// this widget can internally switch based on asset availability.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.semanticLabel,
    this.color,
    this.fit = BoxFit.contain,
  });

  /// Width & height (square). Defaults to 96.
  final double size;

  /// Optional semantics label for accessibility / screen readers.
  final String? semanticLabel;

  /// Optional color tint. Leave null to render original colors.
  final Color? color;

  /// How to inscribe the image into the space.
  final BoxFit fit;

  static const String _pngPath = 'assets/icons/miralogo.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _pngPath,
      width: size,
      height: size,
      fit: fit,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      semanticLabel: semanticLabel,
    );

    // Provide semantics only if a label is supplied; otherwise rely on
    // decorative usage.
    if (semanticLabel == null) {
      return ExcludeSemantics(child: image);
    }
    return Semantics(image: true, label: semanticLabel, child: image);
  }
}
