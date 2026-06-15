import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (label: 'Dashboard', icon: Icons.dashboard_rounded, path: '/dashboard'),
    (label: 'Scan', icon: Icons.document_scanner_rounded, path: '/scanner'),
    (label: 'Sheets', icon: Icons.grid_view_rounded, path: '/spreadsheet'),
    (label: 'Plans', icon: Icons.workspace_premium_rounded, path: '/subscription'),
    (label: 'Settings', icon: Icons.settings_rounded, path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _destinations.indexWhere((item) => location.startsWith(item.path));
    final safeIndex = index == -1 ? 0 : index;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final body = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF6F2), Color(0xFFF3ECE8), Color(0xFFE9E2DD)],
            ),
          ),
          child: child,
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: safeIndex,
                  onDestinationSelected: (value) => context.go(_destinations[value].path),
                  minExtendedWidth: 220,
                  extended: true,
                  destinations: _destinations
                      .map((item) => NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label)))
                      .toList(),
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: (value) => context.go(_destinations[value].path),
            destinations: _destinations
                .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
                .toList(),
          ),
        );
      },
    );
  }
}
