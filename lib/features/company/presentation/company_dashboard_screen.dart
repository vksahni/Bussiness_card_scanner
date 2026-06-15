import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/section_card.dart';
import '../../../providers/app_providers.dart';

class CompanyDashboardScreen extends ConsumerWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org = ref.watch(organizationsProvider).first;
    final cards = ref.watch(cardsProvider).asData?.value ?? const [];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Company Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${org.name} admin workspace for employee oversight, shared sheets, and subscription-backed team sync.'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatTile(title: 'Employees', value: '${org.employeeCount}'),
              _StatTile(title: 'Total scans', value: '${org.totalScans}'),
              _StatTile(title: 'Failed sync logs', value: '${cards.where((e) => e.syncStatus.name == 'failed').length}'),
              _StatTile(title: 'Shared sheet', value: org.sharedSheetId),
            ],
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Admin Controls',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(onPressed: () => context.go('/employees'), icon: const Icon(Icons.group_rounded), label: const Text('Manage Employees')),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.analytics_rounded), label: const Text('View Analytics')),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.description_rounded), label: const Text('Export Reports')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value});

  final String title;
  final String value;

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
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
