import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/iap_service.dart';
import '../services/trial_manager.dart';

/// Basit abonelik ekranı: plan kartları ve satın alma/restore
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize IAP (non-blocking). No auto-trial.
    IAPService.instance.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = IAPService.instance.products;
    final haveProducts = products.isNotEmpty;
    final monthly = haveProducts
        ? products.where((e) => e.id == AppConstants.productMonthly).toList()
        : const [];
    final yearly = haveProducts
        ? products.where((e) => e.id == AppConstants.productYearly).toList()
        : const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '14 gün deneme dahildir',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _PlanCard(
                    title: 'Aylık',
                    subtitle: AppConstants.productMonthly,
                    price: monthly.isNotEmpty ? monthly.first.price : null,
                    enabled: haveProducts && !_loading,
                    onBuy: !haveProducts || _loading
                        ? null
                        : () async {
                            final p = monthly.isNotEmpty ? monthly.first : null;
                            if (p == null) return;
                            setState(() => _loading = true);
                            await IAPService.instance.buy(p);
                            setState(() => _loading = false);
                          },
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    title: 'Yıllık',
                    subtitle: AppConstants.productYearly,
                    price: yearly.isNotEmpty ? yearly.first.price : null,
                    enabled: haveProducts && !_loading,
                    onBuy: !haveProducts || _loading
                        ? null
                        : () async {
                            final p = yearly.isNotEmpty ? yearly.first : null;
                            if (p == null) return;
                            setState(() => _loading = true);
                            await IAPService.instance.buy(p);
                            setState(() => _loading = false);
                          },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () => IAPService.instance.restore(),
                  child: const Text('Satın alımları geri yükle'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await IAPService.instance
                              .refreshEntitlementsFromServer();
                          await IAPService.instance.clientCleanupIfNeeded();
                          setState(() => _loading = false);
                        },
                  child: const Text('Durumu yenile'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await IAPService.instance.queryProducts();
                          if (mounted) setState(() => _loading = false);
                        },
                  child: const Text('Planları yenile'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: TrialManager.instance.entitlementStream,
              builder: (context, snapshot) {
                final ent = snapshot.data ?? Entitlement.none;
                return Text('Durum: ${ent.name}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    this.price,
    this.enabled = true,
    required this.onBuy,
  });
  final String title;
  final String subtitle;
  final String? price;
  final bool enabled;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (price != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      price!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ElevatedButton(
                  onPressed: enabled ? onBuy : null,
                  child: const Text('Satın al'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
