import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/section_card.dart';
import '../../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final firebase = ref.watch(firebaseBootstrapProvider).asData?.value;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Control theme mode, account routing, and environment health.'),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Appearance',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (value) => ref.read(themeModeProvider.notifier).update(value.first),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Connections',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Firebase: ${firebase?.message ?? 'Checking...'}'),
                const SizedBox(height: 10),
                const Text('Google Sheets and RevenueCat keys are wired through setup documentation and runtime service classes.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Account',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person_outline_rounded), label: const Text('Profile')),
                OutlinedButton.icon(onPressed: () => context.go('/subscription'), icon: const Icon(Icons.workspace_premium_outlined), label: const Text('Subscription')),
                FilledButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
