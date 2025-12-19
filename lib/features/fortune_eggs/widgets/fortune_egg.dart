import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Public API: eight themes only
enum EggTheme {
  fire,
  dragon,
  crystal,
  moon,
  galaxy,
  lava,
  ice,
  thunder,
  // New themes
  earth,
  sun,
  wood,
  marble,
  speckled2,
}

class FortuneEgg extends StatelessWidget {
  const FortuneEgg({
    super.key,
    required this.theme,
    this.size = 140,
    this.isSelected = false,
    this.semanticLabel,
    this.onTap,
    this.crackProgress = 0.0,
  });

  final EggTheme theme;
  final double size;
  final bool isSelected;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final double crackProgress; // 0.0..1.0

  @override
  Widget build(BuildContext context) {
    final painter = switch (theme) {
      EggTheme.fire => _FireEggPainter(),
      EggTheme.dragon => _DragonEggPainter(),
      EggTheme.crystal => _CrystalEggPainter(),
      EggTheme.moon => _MoonEggPainter(),
      EggTheme.galaxy => _GalaxyEggPainter(),
      EggTheme.lava => _LavaEggPainter(),
      EggTheme.ice => _IceEggPainter(),
      EggTheme.thunder => _ThunderEggPainter(),
      EggTheme.earth => _EarthEggPainter(),
      EggTheme.sun => _SunEggPainter(),
      EggTheme.wood => _WoodEggPainter(),
      EggTheme.marble => _MarbleEggPainter(),
      EggTheme.speckled2 => _Speckled2EggPainter(),
    };

    final egg = SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base: container (shadow+rim) + themed fill/decals
          CustomPaint(
            painter: _EggContainerPainter(),
            foregroundPainter: painter,
            size: Size.square(size),
          ),
          // Overlay: progressive cracks
          if (crackProgress > 0)
            CustomPaint(
              painter: _EggCrackPainter(
                progress: crackProgress.clamp(0.0, 1.0),
              ),
              size: Size.square(size),
            ),
        ],
      ),
    );

    final content = AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      scale: isSelected ? 1.06 : 1.0,
      child: egg,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onTap != null,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }
}

// Shared container (shadow + rim)
class _EggContainerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final eggRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final padding = size.width * 0.06;
    final r = eggRect.deflate(padding);
    final path = _eggPath(r);

    // Drop shadow (reduced for subtlety)
    canvas.save();
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.translate(0, size.height * 0.035);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Rim
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.007
      ..color = Colors.black.withOpacity(0.25);
    canvas.drawPath(path, rim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Single egg path, elongated and tapered (after 180° rotation, on-screen bottom is narrower)
Path _eggPath(Rect r) {
  final path = Path();
  final cx = r.center.dx;
  final w = r.width;
  final h = r.height;
  final topY = r.top + h * 0.20; // geometrical top (will be on-screen bottom)
  final bottomY = r.bottom - h * 0.18; // geometrical bottom (on-screen top)

  path.moveTo(cx, topY);
  path.cubicTo(cx + w * 0.22, topY, cx + w * 0.40, bottomY, cx, bottomY);
  path.cubicTo(cx - w * 0.40, bottomY, cx - w * 0.22, topY, cx, topY);
  path.close();
  return path;
}

// Progressive crack overlay painter
class _EggCrackPainter extends CustomPainter {
  _EggCrackPainter({required this.progress});
  final double progress; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect.deflate(size.width * 0.06));

    // Clip to egg silhouette so cracks don't bleed out
    canvas.save();
    canvas.clipPath(eggPath);

    final p = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * (0.012 + 0.01 * progress);

    // Main crack spine from upper third toward bottom
    final b = eggPath.getBounds();
    final start = Offset(
      b.center.dx,
      b.top + b.height * (0.28 - 0.05 * progress),
    );
    final path = Path()..moveTo(start.dx, start.dy);
    // Zig-zag segments grow with progress
    final segs = (6 + (progress * 8)).toInt();
    final dx = b.width * 0.06;
    final dy = b.height * (0.45 + 0.15 * progress) / segs;
    for (var i = 0; i < segs; i++) {
      final dir = i.isEven ? 1 : -1;
      path.relativeLineTo(dx * dir, dy);
    }
    canvas.drawPath(path, p);

    // Branch cracks
    final branch = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = p.strokeWidth * 0.7;

    void drawBranch(Offset origin, double len, double angle) {
      final end = origin + Offset.fromDirection(angle, len * progress);
      canvas.drawLine(origin, end, branch);
    }

    final samplePoints = <Offset>[];
    for (var i = 2; i < segs; i += 2) {
      samplePoints.add(start + Offset((i.isEven ? dx : -dx), dy * i));
    }
    for (final o in samplePoints) {
      drawBranch(o, b.width * 0.12, -0.9);
      drawBranch(o, b.width * 0.1, 0.8);
      if (progress > 0.6) {
        drawBranch(o, b.width * 0.08, 2.4);
      }
    }

    // Tiny debris/white highlight for realism
    if (progress > 0.7) {
      final debris = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.strokeWidth * 0.4;
      for (final o in samplePoints.take(3)) {
        final d = Path()
          ..moveTo(o.dx + 1, o.dy + 1)
          ..relativeLineTo(2, 1);
        canvas.drawPath(d, debris);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EggCrackPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// 1) Fire
class _FireEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, 0.3),
        radius: 0.8,
        colors: [Color(0xFFFF6B35), Color(0xFFE63946), Color(0xFFB71C1C)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final flame = Paint()..color = const Color(0xFFFFA500).withOpacity(0.7);

    Path f(Offset c, double w, double h) {
      return Path()
        ..moveTo(c.dx, c.dy + h * 0.4)
        ..quadraticBezierTo(
          c.dx + w * 0.3,
          c.dy,
          c.dx - w * 0.2,
          c.dy - h * 0.4,
        )
        ..quadraticBezierTo(
          c.dx - w * 0.35,
          c.dy - h * 0.15,
          c.dx,
          c.dy + h * 0.4,
        );
    }

    canvas.drawPath(
      f(
        Offset(b.center.dx, b.bottom - b.height * 0.25),
        b.width * 0.5,
        b.height * 0.7,
      ),
      flame,
    );

    final sparkle = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(
      Rect.fromLTWH(
        b.left + b.width * 0.18,
        b.top + b.height * 0.14,
        b.width * 0.32,
        b.height * 0.26,
      ),
      sparkle,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2) Dragon
class _DragonEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF1B5E20)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final scalePaint = Paint()
      ..color = const Color(0xFF1B5E20).withOpacity(0.35);
    const rows = 8, cols = 6;
    for (int rI = 0; rI < rows; rI++) {
      for (int cI = 0; cI < cols; cI++) {
        final off = (rI % 2) * 0.5;
        final x = b.left + (cI + off) * b.width / cols + b.width * 0.1;
        final y = b.top + rI * b.height / rows + b.height * 0.1;
        if (x < b.left || x > b.right || y < b.top || y > b.bottom) continue;
        final s = size.width * 0.06;
        final p = Path()
          ..moveTo(x, y - s * 0.5)
          ..quadraticBezierTo(x + s * 0.5, y, x, y + s * 0.5)
          ..quadraticBezierTo(x - s * 0.5, y, x, y - s * 0.5);
        canvas.drawPath(p, scalePaint);
      }
    }

    // Horns, kept inside silhouette
    final hornPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
      ).createShader(rect);
    final leftHorn = Path()
      ..moveTo(b.left + b.width * 0.3, b.top + b.height * 0.07)
      ..lineTo(b.left + b.width * 0.26, b.top + b.height * 0.24)
      ..lineTo(b.left + b.width * 0.36, b.top + b.height * 0.24)
      ..close();
    final rightHorn = Path()
      ..moveTo(b.right - b.width * 0.3, b.top + b.height * 0.07)
      ..lineTo(b.right - b.width * 0.36, b.top + b.height * 0.24)
      ..lineTo(b.right - b.width * 0.26, b.top + b.height * 0.24)
      ..close();
    canvas.drawPath(leftHorn, hornPaint);
    canvas.drawPath(rightHorn, hornPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3) Crystal
class _CrystalEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, 0.2),
        radius: 1.0,
        colors: [Color(0xFFFFD700), Color(0xFFFF8F00), Color(0xFFE65100)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final crystalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      ).createShader(rect);

    void drawCrystal(Offset c, double s) {
      final p = Path()
        ..moveTo(c.dx, c.dy - s * 0.6)
        ..lineTo(c.dx + s * 0.3, c.dy - s * 0.2)
        ..lineTo(c.dx + s * 0.2, c.dy + s * 0.4)
        ..lineTo(c.dx - s * 0.2, c.dy + s * 0.4)
        ..lineTo(c.dx - s * 0.3, c.dy - s * 0.2)
        ..close();
      canvas.drawPath(p, crystalPaint);
      final hi = Paint()..color = Colors.white.withOpacity(0.3);
      final hp = Path()
        ..moveTo(c.dx - s * 0.1, c.dy - s * 0.3)
        ..lineTo(c.dx + s * 0.1, c.dy - s * 0.4)
        ..lineTo(c.dx + s * 0.15, c.dy - s * 0.1)
        ..lineTo(c.dx - s * 0.05, c.dy)
        ..close();
      canvas.drawPath(hp, hi);
    }

    drawCrystal(
      Offset(b.center.dx, b.top + b.height * 0.15),
      size.width * 0.15,
    );
    drawCrystal(
      Offset(b.left + b.width * 0.25, b.top + b.height * 0.3),
      size.width * 0.12,
    );
    drawCrystal(
      Offset(b.right - b.width * 0.25, b.top + b.height * 0.3),
      size.width * 0.12,
    );
    drawCrystal(
      Offset(b.left + b.width * 0.35, b.center.dy),
      size.width * 0.10,
    );
    drawCrystal(
      Offset(b.right - b.width * 0.35, b.center.dy),
      size.width * 0.10,
    );
    drawCrystal(
      Offset(b.center.dx, b.bottom - b.height * 0.25),
      size.width * 0.08,
    );

    canvas.restore();

    final sparkle = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(
      Rect.fromLTWH(
        b.left + b.width * 0.15,
        b.top + b.height * 0.1,
        b.width * 0.4,
        b.height * 0.3,
      ),
      sparkle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4) Moon
class _MoonEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 1.2,
        colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF0A1A3A)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final crescentPaint = Paint()..color = const Color(0xFFFFD700);

    void crescent(Offset c, double r) {
      final outer = Path()..addOval(Rect.fromCircle(center: c, radius: r));
      final inner = Path()
        ..addOval(
          Rect.fromCircle(center: c.translate(r * 0.4, 0), radius: r * 0.8),
        );
      final cres = Path.combine(PathOperation.difference, outer, inner);
      canvas.drawPath(cres, crescentPaint);
    }

    crescent(Offset(b.center.dx, b.top + b.height * 0.3), size.width * 0.12);
    crescent(Offset(b.left + b.width * 0.3, b.center.dy), size.width * 0.10);
    crescent(
      Offset(b.right - b.width * 0.25, b.bottom - b.height * 0.3),
      size.width * 0.08,
    );

    final star = Paint()..color = const Color(0xFFFFF59D);
    void twinkle(Offset c, double s) {
      canvas.drawCircle(c, s, star);
      final lp = Paint()
        ..color = star.color
        ..strokeWidth = s * 0.3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(c.translate(-s * 1.5, 0), c.translate(s * 1.5, 0), lp);
      canvas.drawLine(c.translate(0, -s * 1.5), c.translate(0, s * 1.5), lp);
    }

    twinkle(
      Offset(b.left + b.width * 0.2, b.top + b.height * 0.2),
      size.width * 0.02,
    );
    twinkle(
      Offset(b.right - b.width * 0.15, b.top + b.height * 0.25),
      size.width * 0.02,
    );
    twinkle(
      Offset(b.left + b.width * 0.15, b.center.dy + b.height * 0.1),
      size.width * 0.02,
    );
    twinkle(
      Offset(b.center.dx + b.width * 0.2, b.center.dy - b.height * 0.05),
      size.width * 0.02,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 5) Galaxy
class _GalaxyEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, 0.3),
        radius: 1.5,
        colors: [
          Color(0xFF1A237E),
          Color(0xFF4A148C),
          Color(0xFF0D0221),
          Color(0xFF000000),
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final nebula = Paint()
      ..color = const Color(0xFFCE93D8).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final cloud = Path()
      ..moveTo(b.left + b.width * 0.1, b.top + b.height * 0.3)
      ..quadraticBezierTo(
        b.center.dx,
        b.top + b.height * 0.1,
        b.right - b.width * 0.2,
        b.top + b.height * 0.4,
      )
      ..quadraticBezierTo(
        b.center.dx + b.width * 0.1,
        b.center.dy,
        b.center.dx - b.width * 0.15,
        b.bottom - b.height * 0.3,
      )
      ..quadraticBezierTo(
        b.left + b.width * 0.2,
        b.center.dy + b.height * 0.1,
        b.left + b.width * 0.1,
        b.top + b.height * 0.3,
      );
    canvas.drawPath(cloud, nebula);

    final star = Paint()..color = const Color(0xFFFFF9C4);
    void starAt(double x, double y, double s) {
      final c = Offset(b.left + b.width * x, b.top + b.height * y);
      canvas.drawCircle(c, size.width * s, star);
    }

    for (final data in const [
      [0.2, 0.15, 0.015],
      [0.8, 0.2, 0.012],
      [0.15, 0.35, 0.018],
      [0.7, 0.4, 0.010],
    ]) {
      starAt(data[0], data[1], data[2]);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 6) Lava
class _LavaEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 1.2,
        colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final crack = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018
      ..strokeCap = StrokeCap.round;

    Path fissure(Offset start, double w, double h) {
      final p = Path()..moveTo(start.dx, start.dy);
      final pts = [
        Offset(w * 0.2, h * 0.15),
        Offset(w * -0.15, h * 0.2),
        Offset(w * 0.25, h * 0.2),
        Offset(w * -0.2, h * 0.25),
      ];
      var x = start.dx, y = start.dy;
      for (final d in pts) {
        x += d.dx;
        y += d.dy;
        p.lineTo(x, y);
      }
      return p;
    }

    canvas.drawPath(
      fissure(
        Offset(b.center.dx, b.top + b.height * 0.25),
        b.width * 0.6,
        b.height * 0.5,
      ),
      crack,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 9) Earth
class _EarthEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    // soil band
    final band = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromLTWH(b.left, b.bottom - b.height * 0.2, b.width, b.height * 0.2),
      band,
    );

    // small leaf decal
    final leaf = Paint()..color = Colors.white.withOpacity(0.9);
    final leafPath = Path()
      ..moveTo(b.center.dx - b.width * 0.12, b.top + b.height * 0.25)
      ..quadraticBezierTo(
        b.center.dx,
        b.top + b.height * 0.15,
        b.center.dx + b.width * 0.06,
        b.top + b.height * 0.32,
      )
      ..quadraticBezierTo(
        b.center.dx + b.width * 0.02,
        b.top + b.height * 0.28,
        b.center.dx - b.width * 0.12,
        b.top + b.height * 0.25,
      )
      ..close();
    canvas.drawPath(leafPath, leaf);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 10) Sun
class _SunEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 1.0,
        colors: [Color(0xFFFFECB3), Color(0xFFFFB74D), Color(0xFFFF7043)],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    // subtle sun rays
    final ray = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 8; i++) {
      final a = (i / 8) * math.pi * 2;
      final start = Offset(
        b.center.dx + math.cos(a) * b.width * 0.1,
        b.center.dy + math.sin(a) * b.height * 0.08,
      );
      final end = Offset(
        b.center.dx + math.cos(a) * b.width * 0.45,
        b.center.dy + math.sin(a) * b.height * 0.45,
      );
      canvas.drawLine(start, end, ray..strokeWidth = size.width * 0.02);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 11) Wood
class _WoodEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD7CCC8), Color(0xFF8D6E63)],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final grain = Paint()
      ..color = Colors.brown.withOpacity(0.16)
      ..strokeWidth = size.width * 0.012
      ..style = PaintingStyle.stroke;
    for (
      double y = b.top + b.height * 0.1;
      y < b.bottom;
      y += b.height * 0.06
    ) {
      final p = Path()..moveTo(b.left, y + math.sin(y) * 0.002);
      p.quadraticBezierTo(
        b.center.dx,
        y + b.height * 0.03,
        b.right,
        y + math.sin(y + 10) * 0.002,
      );
      canvas.drawPath(p, grain);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 12) Marble
class _MarbleEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF5F5F5), Color(0xFFCFD8DC)],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final vein = Paint()
      ..color = Colors.grey.withOpacity(0.18)
      ..strokeWidth = size.width * 0.008
      ..style = PaintingStyle.stroke;
    final p = Path()
      ..moveTo(b.left + b.width * 0.15, b.top + b.height * 0.25)
      ..cubicTo(
        b.left + b.width * 0.35,
        b.top + b.height * 0.1,
        b.left + b.width * 0.65,
        b.top + b.height * 0.5,
        b.right - b.width * 0.15,
        b.bottom - b.height * 0.15,
      );
    canvas.drawPath(p, vein);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 13) Speckled 2 (quail-ish)
class _Speckled2EggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8F3E6), Color(0xFFEDE7D9)],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final spot = Paint()..color = Colors.brown.withOpacity(0.7);
    final rnd = math.Random(42);
    for (int i = 0; i < 28; i++) {
      final x = b.left + rnd.nextDouble() * b.width;
      final y = b.top + rnd.nextDouble() * b.height;
      final r = (rnd.nextDouble() * 0.03 + 0.01) * b.width;
      canvas.drawOval(Rect.fromCircle(center: Offset(x, y), radius: r), spot);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 7) Ice
class _IceEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB3E5FC), Color(0xFF4FC3F7), Color(0xFF01579B)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawPath(eggPath, gradient);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final shard = Paint()..color = Colors.white.withOpacity(0.55);
    void tri(Offset c, double w, double h) {
      final p = Path()
        ..moveTo(c.dx, c.dy - h * 0.5)
        ..lineTo(c.dx + w * 0.5, c.dy + h * 0.5)
        ..lineTo(c.dx - w * 0.5, c.dy + h * 0.5)
        ..close();
      canvas.drawPath(p, shard);
    }

    tri(
      Offset(b.center.dx, b.top + b.height * 0.2),
      b.width * 0.22,
      b.height * 0.28,
    );
    tri(
      Offset(b.left + b.width * 0.25, b.center.dy),
      b.width * 0.18,
      b.height * 0.22,
    );
    tri(
      Offset(b.right - b.width * 0.25, b.center.dy),
      b.width * 0.18,
      b.height * 0.22,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 8) Thunder
class _ThunderEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eggPath = _eggPath(rect);

    final base = Paint()
      ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
        const Color(0xFF3F51B5),
        const Color(0xFF1A237E),
      ]);
    canvas.drawPath(eggPath, base);

    final b = eggPath.getBounds();
    canvas.save();
    canvas.clipPath(eggPath);

    final bolt = Paint()
      ..color = const Color(0xFFFFF176)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;

    Path lightning(Offset start, double w, double h) {
      final p = Path()..moveTo(start.dx, start.dy);
      final rnd = [
        Offset(w * 0.2, h * 0.1),
        Offset(w * -0.1, h * 0.2),
        Offset(w * 0.25, h * 0.2),
        Offset(w * -0.15, h * 0.25),
        Offset(w * 0.3, h * 0.25),
      ];
      var x = start.dx, y = start.dy;
      for (final d in rnd) {
        x += d.dx;
        y += d.dy;
        p.lineTo(x, y);
      }
      return p;
    }

    canvas.drawPath(
      lightning(
        Offset(b.center.dx - b.width * 0.2, b.top + b.height * 0.2),
        b.width * 0.6,
        b.height * 0.6,
      ),
      bolt,
    );
    canvas.drawPath(
      lightning(
        Offset(b.center.dx + b.width * 0.1, b.top + b.height * 0.1),
        b.width * 0.5,
        b.height * 0.55,
      ),
      bolt..color = bolt.color.withOpacity(0.8),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
