import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PosShell extends StatelessWidget {
  const PosShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.point_of_sale),
        label: 'POS',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long),
        label: 'Orders',
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