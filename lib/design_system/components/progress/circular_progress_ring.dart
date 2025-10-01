import 'dart:math' as math;
import 'package:flutter/material.dart';

class DsCircularProgressRing extends StatelessWidget {
  const DsCircularProgressRing({
    super.key,
    required this.value,
    required this.target,
  });
  final double value;
  final double target;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0, 1)),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => CustomPaint(
      painter: _RingPainter(progress: v, target: target.clamp(0, 1)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              v >= target ? Icons.check_circle : Icons.trending_up,
              size: 28,
              color: v >= target
                  ? const Color(0xFF547341)
                  : const Color(0xFF90B6C9),
            ),
            const SizedBox(height: 4),
            Text(
              '${(v * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -.5,
              ),
            ),
            Text(
              '${(target * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.target});
  final double progress;
  final double target;
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..color = Colors.black.withValues(alpha: .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, basePaint);
    final markerPaint = Paint()
      ..color = const Color(0xFFD8C27A).withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final targetAngle = target.clamp(0, 1) * math.pi * 2;
    canvas.drawArc(
      rect,
      -math.pi / 2 + targetAngle - .02,
      .04,
      false,
      markerPaint,
    );
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + math.pi * 2,
      colors: const [Color(0xFF90B6C9), Color(0xFFD8C27A)],
    );
    final progPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      progress.clamp(0, 1) * math.pi * 2,
      false,
      progPaint,
    );
    final thresholds = [0.25, 0.5, 0.75];
    for (int i = 0; i < thresholds.length; i++) {
      final innerStroke = 3.0;
      final innerR = radius - (i + 1) * (innerStroke * 2.8);
      if (innerR <= 0) break;
      final innerRect = Rect.fromCircle(center: center, radius: innerR);
      final th = thresholds[i];
      final achieved = progress >= th;
      final innerPaint = Paint()
        ..color = achieved
            ? const Color(0xFFD8C27A)
            : Colors.black.withValues(alpha: .12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStroke
        ..strokeCap = StrokeCap.round;
      final sweep = (progress.clamp(0, 1)).clamp(0.0, th) / th * math.pi * 2;
      canvas.drawArc(innerRect, -math.pi / 2, sweep, false, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.target != target;
}
