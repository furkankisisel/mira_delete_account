import 'package:flutter/material.dart';

class DsLinearProgress extends StatelessWidget {
  const DsLinearProgress({super.key, required this.value});
  final double value; // 0..1
  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.onSurface.withValues(alpha: .12);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        return Container(
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: maxW * v,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF90B6C9), Color(0xFFD8C27A)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
