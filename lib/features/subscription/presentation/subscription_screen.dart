import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_card.dart';
import '../../../providers/app_providers.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Subscriptions', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Free trial gates, plan entitlements, and restore-purchase workflow are prepared for RevenueCat / Play Billing rollout.'),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Current State',
            child: subscription.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan: ${data.plan.name}'),
                  Text('Active: ${data.isActive}'),
                  Text('Remaining free scans: ${data.remainingFreeScans}'),
                  Text('Trial ends: ${data.trialEndsAt ?? 'n/a'}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.read(subscriptionServiceProvider).restore(),
                    child: const Text('Restore Purchases'),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('$error'),
            ),
          ),
          const SizedBox(height: 16),
          const _PlanCard(
            title: 'Free',
            features: ['20 scans or 7-day trial', 'Local spreadsheet only', 'Offline storage'],
          ),
          const SizedBox(height: 12),
          const _PlanCard(
            title: 'Pro',
            features: ['Unlimited scans', 'Google Sheets sync', 'Excel export', 'Cloud backup'],
          ),
          const SizedBox(height: 12),
          const _PlanCard(
            title: 'Company',
            features: ['Shared team sheets', 'Employee accounts', 'Analytics dashboard', 'Admin controls'],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.features,
  });

  final String title;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(feature),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
