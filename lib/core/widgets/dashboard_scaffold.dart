import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../theme/design_tokens.dart';

class DashboardScaffold extends ConsumerStatefulWidget {
  const DashboardScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends ConsumerState<DashboardScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _railAnimationController;
  late final Animation<double> _railWidthAnimation;

  @override
  void initState() {
    super.initState();
    _railAnimationController = AnimationController(
      vsync: this,
      duration: DesignTokens.animationNormal,
    );
    _railWidthAnimation = Tween<double>(
      begin: 72,
      end: 240,
    ).animate(CurvedAnimation(
      parent: _railAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _railAnimationController.dispose();
    super.dispose();
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _logout() async {
    ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final user = ref.watch(authNotifierProvider);

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale),
        label: 'POS',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Overview',
      ),
      const NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Products',
      ),
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    Widget trailing = const SizedBox.shrink();
    if (!isMobile) {
      trailing = Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: _railWidthAnimation.value > 100
                    ? 'Collapse menu'
                    : 'Expand menu',
                icon: AnimatedRotation(
                  turns: _railWidthAnimation.value > 100 ? 0.5 : 0,
                  duration: DesignTokens.animationFast,
                  child: const Icon(Icons.menu),
                ),
                onPressed: () {
                  if (_railAnimationController.isCompleted) {
                    _railAnimationController.reverse();
                  } else {
                    _railAnimationController.forward();
                  }
                },
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                dense: true,
                onTap: _logout,
              ),
              const SizedBox(height: DesignTokens.spacingMd),
            ],
          ),
        ),
      );
    } else {
      trailing = PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'logout') _logout();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 12),
                Text('Logout'),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.only(right: DesignTokens.spacingMd),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user?.name.characters.first ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getCurrentTitle(widget.navigationShell.currentIndex)),
          actions: [trailing],
        ),
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          destinations: destinations,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AnimatedBuilder(
            animation: _railAnimationController,
            builder: (context, child) {
              return SizedBox(
                width: _railWidthAnimation.value,
                child: NavigationRail(
                  extended: _railWidthAnimation.value > 100,
                  minExtendedWidth: 240,
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    _goBranch(index);
                  },
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            selectedIcon: d.selectedIcon,
                            label: Text(d.label),
                          ))
                      .toList(),
                  trailing: trailing,
                ),
              );
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }

  String _getCurrentTitle(int index) {
    const titles = [
      'POS',
      'Orders',
      'Overview',
      'Products',
      'Settings',
    ];
    if (index < titles.length) return titles[index];
    return 'Boutiq';
  }
}