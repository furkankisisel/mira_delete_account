import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mira/l10n/app_localizations.dart';

import '../config/constants.dart'; // constants.dart dosyasının güncel olduğundan emin olun
import '../models/mira_plan.dart';
import '../services/iap_service.dart';
import '../services/premium_manager.dart';

/// Premium subscription plans screen.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = true;
  String? _error;
  int _selectedPlanIndex = 0;
  MiraPlan? _monthlyPlan;
  MiraPlan? _yearlyPlan;
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isApplyingPromoCode = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      debugPrint('[SubscriptionScreen] Loading plans...');

      // Service init edilmemişse burada garantiye alalım
      if (!IAPService.instance.isReady) {
        await IAPService.instance.init();
      }

      await IAPService.instance.loadProducts();
      final plans = IAPService.instance.plans;

      debugPrint(
        '[SubscriptionScreen] Plans loaded: ${plans.length} plans available',
      );

      // --- GÜNCELLENEN KISIM BAŞLANGIÇ ---
      // Artık BasePlanId değil, doğrudan Ürün ID'sine (mira_month / mira_year) bakıyoruz.

      try {
        _monthlyPlan = plans.firstWhere(
          (p) => p.id == AppConstants.monthlyProductId, // mira_month
        );
      } catch (_) {
        debugPrint('[SubscriptionScreen] Aylık plan bulunamadı.');
        _monthlyPlan = null;
      }

      try {
        _yearlyPlan = plans.firstWhere(
          (p) => p.id == AppConstants.yearlyProductId, // mira_year
        );
      } catch (_) {
        debugPrint('[SubscriptionScreen] Yıllık plan bulunamadı.');
        _yearlyPlan = null;
      }
      // --- GÜNCELLENEN KISIM BİTİŞ ---

      // Varsayılan seçimi ayarla
      _selectedPlanIndex = (_monthlyPlan != null)
          ? 0
          : ((_yearlyPlan != null) ? 0 : -1);

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[SubscriptionScreen] Error loading plans: $e');
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.plansLoadError(e.toString());
          _loading = false;
        });
      }
    }
  }

  Future<void> _buyPlan(MiraPlan plan) async {
    try {
      debugPrint(
        '[SubscriptionScreen] User selected plan: ${plan.id} (${plan.label})',
      );

      // UI feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.processingWait),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      await IAPService.instance.buyPlan(plan);
    } catch (e) {
      debugPrint('[SubscriptionScreen] Error buying plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToLoad(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await IAPService.instance.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.checkingPurchases),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.restoreError}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir promosyon kodu girin')),
      );
      return;
    }

    setState(() => _isApplyingPromoCode = true);

    try {
      final success = await PremiumManager.instance.activatePromoCode(code);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '🎉 Promosyon kodu başarıyla uygulandı! Premium erişiminiz aktifleştirildi.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          _promoCodeController.clear();
          // Go back after successful activation
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        } else {
          final hasUsed = PremiumManager.instance.hasUsedPromoCode;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hasUsed
                    ? 'Bu hesapta daha önce bir promosyon kodu kullanılmış.'
                    : 'Geçersiz promosyon kodu. Lütfen kontrol edip tekrar deneyin.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplyingPromoCode = false);
      }
    }
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.premiumPlans),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _buildPlansView(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: _restorePurchases,
                icon: const Icon(Icons.restore),
                label: Text(AppLocalizations.of(context)!.restorePurchases),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.trialInfo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlansView() {
    final available = <MiraPlan>[];
    if (_monthlyPlan != null) available.add(_monthlyPlan!);
    if (_yearlyPlan != null) available.add(_yearlyPlan!);

    if (available.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noPlansAvailable),
      );
    }

    if (_selectedPlanIndex < 0 || _selectedPlanIndex >= available.length) {
      _selectedPlanIndex = 0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPromoCodeSection(),
          const SizedBox(height: 24),
          for (var i = 0; i < available.length; i++)
            _buildPlanCard(
              plan: available[i],
              isSelected: _selectedPlanIndex == i,
              onSelect: () => setState(() => _selectedPlanIndex = i),
              onBuy: () => _buyPlan(available[i]),
            ),
          const SizedBox(height: 24),
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 12),
        Text(
          'Mira Premium',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.unlockAllFeatures,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required MiraPlan plan,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onBuy,
  }) {
    final theme = Theme.of(context);

    // --- GÜNCELLENEN KISIM ---
    // Planın aylık olup olmadığını anlamak için ID kontrolü
    final isMonthly = plan.id == AppConstants.monthlyProductId;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.4)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Radio butonu görünümü
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMonthly
                            ? AppLocalizations.of(context)!.flexiblePlan
                            : AppLocalizations.of(context)!.annualPlanDesc,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.formattedPrice,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      isMonthly
                          ? AppLocalizations.of(context)!.perMonth
                          : AppLocalizations.of(context)!.perYear,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onBuy,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.continueButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.premiumFeatures,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _featureItem(l10n.featureDetailedAnalysis),
          _featureItem(l10n.featureUnlimitedPalmReading),
          _featureItem(l10n.featureAIInsights),
          _featureItem(l10n.featureAdFree),
          _featureItem(l10n.featurePrioritySupport),
        ],
      ),
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    final theme = Theme.of(context);
    final hasUsedCode = PremiumManager.instance.hasUsedPromoCode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondaryContainer.withOpacity(0.3),
            theme.colorScheme.tertiaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Promosyon Kodu',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasUsedCode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premium erişiminiz promosyon kodu ile aktifleştirildi ✨',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            TextField(
              controller: _promoCodeController,
              decoration: InputDecoration(
                hintText: 'Promosyon kodunuzu girin',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.discount_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              enabled: !_isApplyingPromoCode,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isApplyingPromoCode ? null : _applyPromoCode,
                icon: _isApplyingPromoCode
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.redeem_rounded),
                label: Text(
                  _isApplyingPromoCode ? 'Uygulanıyor...' : 'Kodu Uygula',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
