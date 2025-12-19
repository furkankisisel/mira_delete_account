import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../services/premium_manager.dart';
import '../config/constants.dart';
import '../l10n/app_localizations.dart';
import 'subscription_screen.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  bool _isPremium = false;
  DateTime? _expiryDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    setState(() {
      _isLoading = true;
    });

    _isPremium = PremiumManager.instance.isPremium;
    _expiryDate = PremiumManager.instance.expiryDate;

    // Listen to premium status changes
    PremiumManager.instance.premiumStatusStream.listen((value) {
      if (mounted) {
        setState(() {
          _isPremium = value;
          _expiryDate = PremiumManager.instance.expiryDate;
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'dd MMMM yyyy',
      Localizations.localeOf(context).toString(),
    ).format(date);
  }

  int _daysRemaining() {
    if (_expiryDate == null) return 0;
    final now = DateTime.now();
    return _expiryDate!.difference(now).inDays;
  }

  Future<void> _openPlaySubscriptionPage() async {
    final skuUrl = Uri.parse(
      'https://play.google.com/store/account/subscriptions?sku=${AppConstants.subscriptionProductId}&package=${AppConstants.packageName}',
    );
    final fallbackUrl = Uri.parse(
      'https://play.google.com/store/account/subscriptions?package=${AppConstants.packageName}',
    );

    try {
      if (await canLaunchUrl(skuUrl)) {
        await launchUrl(skuUrl, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        return;
      }
      // If neither can be opened, show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cannotOpenPlayStore),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorPrefix}$e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.manageSubscription), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageSubscription), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Status Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPremium
                      ? [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.7),
                        ]
                      : [
                          theme.colorScheme.surfaceContainerHighest,
                          theme.colorScheme.surfaceContainer,
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isPremium
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : Colors.black12,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _isPremium ? Icons.workspace_premium : Icons.lock_outline,
                    size: 64,
                    color: _isPremium
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isPremium ? l10n.miraPlusActive : l10n.miraPlusInactive,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isPremium
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isPremium && _expiryDate != null) ...[
                    Text(
                      '${l10n.validity}: ${_formatDate(_expiryDate!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _isPremium
                            ? Colors.white.withOpacity(0.9)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_daysRemaining()} ${l10n.daysLeft}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else if (!_isPremium)
                    Text(
                      l10n.subscribeToEnjoyPremium,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            // Premium Features for non-premium users
            if (!_isPremium) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.premiumFeatures,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FeatureTile(
                      icon: Icons.add_task_outlined,
                      title: l10n.featureAdvancedHabits,
                      description: l10n.detailedCharts,
                    ),
                    _FeatureTile(
                      icon: Icons.visibility_outlined,
                      title: l10n.featureVisionCreation,
                      description: l10n.backupToDrive,
                    ),
                    _FeatureTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.featureAdvancedFinance,
                      description: l10n.uninterruptedUsage,
                    ),
                    _FeatureTile(
                      icon: Icons.palette_outlined,
                      title: l10n.featurePremiumThemes,
                      description: l10n.pomodoroAndCustomTimers,
                    ),
                    _FeatureTile(
                      icon: Icons.backup_outlined,
                      title: l10n.featureBackup,
                      description: l10n.aiPoweredRecommendations,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium),
                        label: Text(
                          l10n.buyPremium,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Subscription Management Actions for premium users
            if (_isPremium) ...[
              const SizedBox(height: 16),
              _ActionCard(
                title: l10n.manageOnGooglePlay,
                subtitle: l10n.manageSubscriptionDesc,
                icon: Icons.open_in_new,
                onTap: _openPlaySubscriptionPage,
              ),
              _ActionCard(
                title: l10n.billingHistory,
                subtitle: l10n.viewInvoicesOnPlayStore,
                icon: Icons.receipt_long,
                onTap: _openPlaySubscriptionPage,
              ),
              _ActionCard(
                title: l10n.subscriptionDetails,
                subtitle: l10n.seeFullSubscriptionInfo,
                icon: Icons.info_outline,
                onTap: () {
                  _showSubscriptionDetails(context);
                },
              ),
            ],

            // Help Section
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helpAndSupport,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HelpTile(
                    question: l10n.howToCancel,
                    answer: l10n.cancelInstructions,
                  ),
                  _HelpTile(
                    question: l10n.whatHappensIfCancel,
                    answer: l10n.cancelEffect,
                  ),
                  _HelpTile(
                    question: l10n.ifTrialCancelled,
                    answer: l10n.trialCancelEffect,
                  ),
                  _HelpTile(
                    question: l10n.canIGetRefund,
                    answer: l10n.refundPolicy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.subscriptionDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              l10n.statusLabel,
              _isPremium ? l10n.active : l10n.inactive,
            ),
            if (_expiryDate != null)
              _DetailRow(l10n.endDate, _formatDate(_expiryDate!)),
            if (_expiryDate != null)
              _DetailRow(
                l10n.daysRemaining,
                '${_daysRemaining()} ${l10n.daysLeft}',
              ),
            const Divider(height: 24),
            Text(
              l10n.usePlayStoreToManage,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openPlaySubscriptionPage();
            },
            child: Text(l10n.goToPlayStore),
          ),
        ],
      ),
    );
  }
}

// Widget components
class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final String question;
  final String answer;

  const _HelpTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
