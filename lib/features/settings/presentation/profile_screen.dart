import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_card.dart';
import '../../../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          SectionCard(
            title: user?.displayName ?? 'Guest',
            subtitle: user?.email ?? 'No active user',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role: ${user?.role.name ?? 'n/a'}'),
                Text('Plan: ${user?.plan.name ?? 'n/a'}'),
                Text('Email verified: ${user?.emailVerified ?? false}'),
                Text('Organization: ${user?.organizationId ?? 'Personal workspace'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
