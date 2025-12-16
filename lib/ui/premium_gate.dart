import 'package:flutter/material.dart';
import 'package:mira/l10n/app_localizations.dart';

import '../services/premium_manager.dart';
import 'subscription_screen.dart';

/// Widgets to gate premium-only features.
/// Displays the child if the user is premium, otherwise shows an upsell dialog/UI.

class PremiumGate extends StatelessWidget {
  /// The widget to display if the user is premium.
  final Widget child;

  /// The widget to display if the user is NOT premium (optional upsell).
  /// If null, will show a default premium dialog.
  final Widget? nonPremiumFallback;

  /// Called when the user taps the premium CTA in the upsell.
  final VoidCallback? onPremiumTapped;

  const PremiumGate({
    super.key,
    required this.child,
    this.nonPremiumFallback,
    this.onPremiumTapped,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PremiumManager.instance.premiumStatusStream,
      initialData: PremiumManager.instance.isPremium,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;

        if (isPremium) {
          return child;
        }

        if (nonPremiumFallback != null) {
          return nonPremiumFallback!;
        }

        // Default upsell widget
        return _DefaultPremiumUpsell(onTapped: onPremiumTapped);
      },
    );
  }
}

class _DefaultPremiumUpsell extends StatelessWidget {
  final VoidCallback? onTapped;

  const _DefaultPremiumUpsell({this.onTapped});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, size: 32),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.thisFeatureIsPremium,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed:
                onTapped ??
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                ),
            child: Text(AppLocalizations.of(context)!.becomePremium),
          ),
        ],
      ),
    );
  }
}

/// Helper function: show premium feature dialog.
/// Call this when a user tries to access a premium feature but isn't premium.
/// If onUpgradeTapped is not provided, navigates to SubscriptionScreen by default.
Future<void> showPremiumDialog(
  BuildContext context, {
  VoidCallback? onUpgradeTapped,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.premiumFeature),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mustBePremiumToUse,
            ),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.premiumBenefits),
            const SizedBox(height: 8),
            Bullet(AppLocalizations.of(context)!.advancedAnalysisAndReports),
            Bullet(AppLocalizations.of(context)!.unlimitedDataStorage),
            Bullet(AppLocalizations.of(context)!.adFreeExperience),
            Bullet(AppLocalizations.of(context)!.freeTrial14Days),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onUpgradeTapped != null) {
                onUpgradeTapped();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.becomePremiumShort),
          ),
        ],
      );
    },
  );
}

class Bullet extends StatelessWidget {
  final String text;

  const Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Helper: Check if user is premium before proceeding with an action.
/// Shows a premium dialog if not premium and returns false.
/// User can tap "Premium Ol" to navigate to SubscriptionScreen.
Future<bool> requirePremium(BuildContext context) async {
  if (PremiumManager.instance.isPremium) {
    return true;
  }

  // Show dialog - if user taps "Premium Ol", they'll be navigated to SubscriptionScreen
  await showPremiumDialog(context);
  return false;
}
