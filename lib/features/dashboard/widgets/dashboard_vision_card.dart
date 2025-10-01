import 'package:flutter/material.dart';
import '../../vision/data/vision_repository.dart';
import '../../vision/data/vision_model.dart';
import 'dart:io' as io;
import '../../../l10n/app_localizations.dart';

class DashboardVisionCard extends StatefulWidget {
  const DashboardVisionCard({super.key});

  @override
  State<DashboardVisionCard> createState() => _DashboardVisionCardState();
}

class _DashboardVisionCardState extends State<DashboardVisionCard> {
  final _repo = VisionRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fill = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.12),
      theme.colorScheme.surfaceContainerHighest,
    );
    return StreamBuilder<List<Vision>>(
      stream: _repo.stream,
      initialData: _repo.all(),
      builder: (context, snap) {
        final items = List<Vision>.from(snap.data ?? const [])
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        // Son eklenen ilk 5
        final recent = items.take(5).toList();
        if (recent.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.terrain, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.visionPlural,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final v = recent[i];
                    return _VisionThumb(vision: v);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VisionThumb extends StatelessWidget {
  const _VisionThumb({required this.vision});
  final Vision vision;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = vision.coverImage != null && vision.coverImage!.isNotEmpty;
    final isFile = hasImage
        ? (vision.coverImage!.startsWith('/') ||
              vision.coverImage!.contains('\\') ||
              vision.coverImage!.contains(':\\'))
        : false;
    final bgColor = Color(vision.colorValue);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 140,
        height: 110,
        decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.85)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.05),
                child: isFile
                    ? Image.file(io.File(vision.coverImage!), fit: BoxFit.cover)
                    : Image.asset(vision.coverImage!, fit: BoxFit.cover),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor.withValues(alpha: 0.85),
                      bgColor.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            // Gradient for readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasImage)
                    Text(
                      vision.emoji ?? '🎯',
                      style: const TextStyle(fontSize: 22),
                    ),
                  const Spacer(),
                  Text(
                    vision.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (hasImage && (vision.emoji != null && vision.emoji!.isNotEmpty))
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vision.emoji!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
