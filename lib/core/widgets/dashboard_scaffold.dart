import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../localization/app_localizations.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    // Close drawer on mobile after selection
    if (context.isMobile && _scaffoldKey.currentState?.isDrawerOpen == true) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  Future<void> _logout() async {
    ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final user = ref.watch(authNotifierProvider);

    final loc = AppLocalizations.of(context)!;

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.point_of_sale_outlined),
        selectedIcon: const Icon(Icons.point_of_sale),
        label: loc.pos,
      ),
      NavigationDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long),
        label: loc.orders,
      ),
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: loc.overview,
      ),
      NavigationDestination(
        icon: const Icon(Icons.inventory_2_outlined),
        selectedIcon: const Icon(Icons.inventory_2),
        label: loc.products,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: loc.reports,
      ),
      NavigationDestination(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        selectedIcon: const Icon(Icons.admin_panel_settings),
        label: loc.admin,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: loc.settings,
      ),
    ];

    // Desktop trailing (expand/collapse + logout)
    Widget desktopTrailing = const SizedBox.shrink();
    if (!isMobile) {
      desktopTrailing = Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: _railWidthAnimation.value > 100
                    ? loc.collapseMenu
                    : loc.expandMenu,
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
                title: Text(loc.logout),
                dense: true,
                onTap: _logout,
              ),
              const SizedBox(height: DesignTokens.spacingMd),
            ],
          ),
        ),
      );
    }

    // Mobile drawer (toggleable nav rail)
    Widget? mobileDrawer;
    if (isMobile) {
      mobileDrawer = NavigationDrawer(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          _goBranch(index);
        },
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B3A5C), Color(0xFF0D1B2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Boutiq Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  loc.navigation,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ...destinations.map((d) => NavigationDrawerDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.logout),
            onTap: _logout,
          ),
        ],
      );
    }

    // Mobile: leading menu button to open drawer
    Widget? mobileLeading;
    if (isMobile) {
      mobileLeading = IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: loc.openMenu,
      );
    }

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: mobileDrawer,
        appBar: AppBar(
          leading: mobileLeading,
          title: Text(_getCurrentTitle(context, widget.navigationShell.currentIndex)),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 12),
                      Text(loc.logout),
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
            ),
          ],
        ),
        body: widget.navigationShell,
      );
    }

    // Desktop: NavigationRail with animated expand/collapse
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
                  trailing: desktopTrailing,
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

  String _getCurrentTitle(BuildContext context, int index) {
    final loc = AppLocalizations.of(context)!;
    final titles = [
      loc.pos,
      loc.orders,
      loc.overview,
      loc.products,
      loc.reports,
      loc.admin,
      loc.settings,
    ];
    if (index < titles.length) return titles[index];
    return 'Boutiq';
  }
}