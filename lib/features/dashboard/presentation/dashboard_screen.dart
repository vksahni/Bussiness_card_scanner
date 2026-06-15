import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/section_card.dart';
import '../../../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final cards = ref.watch(cardsProvider).asData?.value ?? const [];
    final subscription = ref.watch(subscriptionProvider).asData?.value;
    final organizations = ref.watch(organizationsProvider);
    final org = organizations.isEmpty ? null : organizations.first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(cardsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Welcome back, ${user?.displayName ?? 'Operator'}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Personal scans, company sync, and spreadsheet operations stay live even when the device goes offline.'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MetricCard(title: 'Total cards', value: '${cards.length}', icon: Icons.badge_rounded),
                _MetricCard(title: 'Pending sync', value: '${cards.where((e) => e.syncStatus.name != 'synced').length}', icon: Icons.sync_problem_rounded),
                _MetricCard(title: 'Plan', value: subscription?.plan.name.toUpperCase() ?? 'FREE', icon: Icons.workspace_premium_rounded),
                _MetricCard(title: 'Trial / scans', value: '${subscription?.remainingFreeScans ?? 20} left', icon: Icons.hourglass_bottom_rounded),
              ],
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Quick Actions',
              subtitle: 'Jump into the main lead-capture flow.',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(onPressed: () => context.go('/scanner'), icon: const Icon(Icons.photo_camera_back_rounded), label: const Text('Scan Card')),
                  OutlinedButton.icon(onPressed: () => context.go('/spreadsheet'), icon: const Icon(Icons.grid_view_rounded), label: const Text('Open Spreadsheet')),
                  OutlinedButton.icon(onPressed: () => context.go('/subscription'), icon: const Icon(Icons.payments_rounded), label: const Text('Upgrade Plan')),
                  OutlinedButton.icon(onPressed: () => context.go('/company'), icon: const Icon(Icons.apartment_rounded), label: const Text('Company Hub')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (org != null)
              SectionCard(
                title: 'Company Snapshot',
                subtitle: 'Shared sheet: ${org.sharedSheetId}',
                child: Row(
                  children: [
                    Expanded(child: Text('Employees: ${org.employeeCount}\nTotal scans: ${org.totalScans}\nAdmin: ${org.adminEmail}')),
                    OutlinedButton(
                      onPressed: () => context.go('/employees'),
                      child: const Text('Manage Team'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Recent Captures',
              subtitle: 'Latest locally stored and synced business cards.',
              child: cards.isEmpty
                  ? const Text('No scans yet. Open the scanner to capture the first business card.')
                  : Column(
                      children: cards.take(5).map((record) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(record.personName.isEmpty ? '?' : record.personName.substring(0, 1))),
                          title: Text(record.personName.isEmpty ? 'Untitled contact' : record.personName),
                          subtitle: Text('${record.companyName} • ${record.scanDate.toShortDate()}'),
                          trailing: Chip(label: Text(record.syncStatus.name)),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 18),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
