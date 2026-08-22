import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_provider.dart';

class PosShell extends ConsumerWidget {
  const PosShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    final isAdmin = user?.role == 'admin';
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.point_of_sale),
        label: 'POS',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: destinations,
      ),
    );
  }
}