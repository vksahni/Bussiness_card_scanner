import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/company/presentation/company_dashboard_screen.dart';
import '../features/company/presentation/employee_management_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/ocr/presentation/ocr_review_screen.dart';
import '../features/scanner/presentation/scanner_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/spreadsheet/presentation/spreadsheet_screen.dart';
import '../features/subscription/presentation/subscription_screen.dart';
import '../models/business_card_record.dart';
import '../providers/app_providers.dart';
import '../core/widgets/app_shell.dart';
import '../core/widgets/splash_screen.dart';
import '../core/widgets/onboarding_screen.dart';

class AppRouter {
  static GoRouter buildRouter(Ref ref) {
    ref.watch(authStateProvider);
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerScreen(),
            ),
            GoRoute(
              path: '/spreadsheet',
              builder: (context, state) => const SpreadsheetScreen(),
            ),
            GoRoute(
              path: '/subscription',
              builder: (context, state) => const SubscriptionScreen(),
            ),
            GoRoute(
              path: '/company',
              builder: (context, state) => const CompanyDashboardScreen(),
            ),
            GoRoute(
              path: '/employees',
              builder: (context, state) => const EmployeeManagementScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/ocr-review',
          builder: (context, state) {
            final record = state.extra as BusinessCardRecord;
            return OcrReviewScreen(record: record);
          },
        ),
      ],
      redirect: (context, state) {
        final auth = ref.read(currentUserProvider);
        final publicPaths = {'/splash', '/onboarding', '/login'};
        if (auth == null && !publicPaths.contains(state.matchedLocation)) {
          return '/login';
        }
        if (auth != null && state.matchedLocation == '/login') {
          return '/dashboard';
        }
        return null;
      },
    );
  }
}
