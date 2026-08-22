import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/sabc_theme.dart';
import 'core/database/hive_service.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/application/auth_provider.dart';
import 'features/auth/presentation/pin_login_screen.dart';
import 'features/pos/presentation/pos_shell.dart';
import 'features/pos/presentation/pos_screen.dart';
import 'features/orders/presentation/order_list_screen.dart';
import 'features/reports/presentation/reports_screen.dart';
import 'features/dashboard/presentation/overview_screen.dart';
import 'features/dashboard/presentation/products_screen.dart';
import 'features/dashboard/presentation/staff_screen.dart';
import 'features/dashboard/presentation/clients_screen.dart';
import 'features/dashboard/presentation/settings_screen.dart';
import 'core/widgets/dashboard_scaffold.dart';
import 'core/database/models/user.dart';
import 'core/database/supabase_service.dart';
import 'core/sync/sync_service.dart';
import 'core/sync/sync_status.dart';
import 'core/utils/id_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  await SupabaseService.initialize();
  await _seedDefaultAdmin();
  runApp(UncontrolledProviderScope(
    container: appContainer,
    child: const CashRegisterApp(),
  ));
  unawaited(SyncService.syncAll());
  _startPeriodicSync();
}

void _startPeriodicSync() {
  Timer.periodic(const Duration(seconds: 60), (_) async {
    await SyncService.syncAll();
  });
}

Future<void> _seedDefaultAdmin() async {
  if (HiveService.usersBox.isNotEmpty) return;
  final now = DateTime.now();
  await HiveService.usersBox.add(User()
    ..userId = IdGenerator.generate()
    ..name = 'Admin'
    ..phone = ''
    ..pin = '1234'
    ..role = 'admin'
    ..isActive = true
    ..createdAt = now
    ..updatedAt = now);
}

bool _isLoggedIn() => AuthNotifier.currentUser != null;

final _router = GoRouter(
  initialLocation: '/login',
  refreshListenable: AuthNotifier.refresh,
  redirect: (context, state) {
    final isLoggedIn = _isLoggedIn();
    final isAdmin = AuthNotifier.isAdmin;
    final loggingIn = state.matchedLocation == '/login';
    if (!isLoggedIn && !loggingIn) return '/login';
    if (isLoggedIn && loggingIn) {
      return isAdmin ? '/dashboard' : '/pos';
    }
    if (isLoggedIn && !isAdmin) {
      final loc = state.matchedLocation;
      if (loc.startsWith('/dashboard')) {
        return '/pos';
      }
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const PinLoginScreen()),
    // Salesperson shell (POS + Orders)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PosShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderListScreen(),
            ),
          ],
        ),
      ],
    ),
    // Admin dashboard shell (POS, Orders, Overview, Products, Settings)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          DashboardScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const OverviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/products',
              builder: (context, state) => const ProductsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Staff & Clients accessible via routes but not in bottom nav
    GoRoute(
      path: '/dashboard/staff',
      builder: (context, state) => const StaffScreen(),
    ),
    GoRoute(
      path: '/dashboard/clients',
      builder: (context, state) => const ClientsScreen(),
    ),
  ],
);

class CashRegisterApp extends StatelessWidget {
  const CashRegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Boutiq',
      theme: SABCTheme.lightTheme,
      routerConfig: _router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}