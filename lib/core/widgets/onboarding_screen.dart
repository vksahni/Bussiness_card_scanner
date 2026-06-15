import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingCard(
        title: 'Capture cards in the field',
        description: 'Scan business cards with camera capture, manual crop adjustment, QR extraction, and offline-safe local storage.',
        icon: Icons.document_scanner_rounded,
      ),
      _OnboardingCard(
        title: 'Review AI extraction before sync',
        description: 'OCR fields are parsed into a structured lead record with confidence scoring, edit mode, and duplicate prevention.',
        icon: Icons.auto_awesome_rounded,
      ),
      _OnboardingCard(
        title: 'Operate like a SaaS pipeline',
        description: 'Push records to shared team sheets, cloud sync queues, company workspaces, and subscription-gated automations.',
        icon: Icons.hub_rounded,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text('Red-team your lead capture.', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('CardSync AI centralizes card scanning, OCR, spreadsheets, sync, and team workflows into one Android app.'),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: pages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              FilledButton(
                onPressed: () => context.go('/login'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                child: const Text('Continue to Workspace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
