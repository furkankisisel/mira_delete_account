import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class FabMenu extends StatefulWidget {
  final VoidCallback onDailyTaskPressed;
  final VoidCallback onHabitPressed;
  final VoidCallback onListPressed;

  const FabMenu({
    super.key,
    required this.onDailyTaskPressed,
    required this.onHabitPressed,
    required this.onListPressed,
  });

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        // Show modal barrier overlay
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.60),
          barrierDismissible: true,
          builder: (context) => const SizedBox.shrink(),
        ).then((_) {
          // When dialog is dismissed, close the menu
          if (_isExpanded) {
            _toggle();
          }
        });
      } else {
        _controller.reverse();
        // Close any open dialog
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _handleMenuTap(VoidCallback callback) {
    _toggle();
    Future.delayed(const Duration(milliseconds: 100), callback);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items
        if (_isExpanded) ...[
          ScaleTransition(
            scale: _scaleAnimation,
            child: _FabMenuItem(
              icon: Icons.list_alt,
              label: l10n.createList,
              onPressed: () => _handleMenuTap(widget.onListPressed),
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onTertiary,
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _scaleAnimation,
            child: _FabMenuItem(
              icon: Icons.task_alt,
              label: l10n.dailyTask,
              onPressed: () => _handleMenuTap(widget.onDailyTaskPressed),
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _scaleAnimation,
            child: _FabMenuItem(
              icon: Icons.repeat,
              label: l10n.habit,
              onPressed: () => _handleMenuTap(widget.onHabitPressed),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}

class _FabMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: foregroundColor, size: 24),
          ),
        ],
      ),
    );
  }
}
