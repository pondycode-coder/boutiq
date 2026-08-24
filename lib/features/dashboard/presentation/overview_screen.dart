import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/order.dart';
import '../../../core/database/models/user.dart';
import '../../../core/database/models/product.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../core/widgets/dashboard_components.dart';
import '../../../core/widgets/dashboard_charts.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/localization/app_localizations.dart';

final overviewDataProvider = FutureProvider<OverviewData>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  final orders = HiveService.ordersBox.values
      .where((o) =>
          o.status != 'cancelled' &&
          !o.createdAt.isBefore(startOfWeekMidnight) &&
          o.createdAt.isBefore(endOfDay))
      .toList();

  final todayOrders = orders
      .where((o) => !o.createdAt.isBefore(startOfDay) && o.createdAt.isBefore(endOfDay))
      .toList();

  final totalSalesToday = todayOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
  final totalSalesWeek = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
  final orderCountToday = todayOrders.length;
  final orderCountWeek = orders.length;

  final paymentsToday = HiveService.cashPaymentsBox.values
      .where((p) =>
          !p.paidAt.isBefore(startOfDay) && p.paidAt.isBefore(endOfDay))
      .fold(0.0, (sum, p) => sum + (p.amountTendered - p.changeAmount));

  final productsCount = HiveService.productsBox.length;
  final activeProducts = HiveService.productsBox.values.where((p) => p.isActive).length;
  final lowStockProducts = HiveService.productsBox.values
      .where((p) => p.isActive && p.stockQuantity <= 10)
      .length;

  final staffCount = HiveService.usersBox.values.where((u) => u.isActive).length;

  final byDay = <int, double>{};
  for (int i = 0; i < 7; i++) {
    byDay[i] = 0;
  }
  for (final order in orders) {
    final dayIndex = order.createdAt.weekday - 1;
    byDay[dayIndex] = (byDay[dayIndex] ?? 0) + order.totalAmount;
  }
  final trendData = byDay.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final spots = trendData.asMap().entries.map((e) {
    return FlSpot(e.key.toDouble(), e.value.value);
  }).toList();

  final staffSales = <String, double>{};
  for (final order in orders) {
    final sid = order.salespersonId ?? 'Unknown';
    staffSales[sid] = (staffSales[sid] ?? 0) + order.totalAmount;
  }
  final staffEntries = staffSales.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topStaff = staffEntries.take(5).toList();
  final staffLabels = topStaff.map((e) {
    final user = HiveService.usersBox.values
        .where((u) => u.userId == e.key)
        .firstOrNull;
    return user?.name ?? e.key;
  }).toList();
  final staffValues = topStaff.map((e) => e.value).toList();

  return OverviewData(
    totalSalesToday: totalSalesToday,
    totalSalesWeek: totalSalesWeek,
    orderCountToday: orderCountToday,
    orderCountWeek: orderCountWeek,
    paymentsToday: paymentsToday,
    productsCount: productsCount,
    activeProducts: activeProducts,
    lowStockProducts: lowStockProducts,
    staffCount: staffCount,
    salesTrendSpots: spots,
    staffLabels: staffLabels,
    staffValues: staffValues,
  );
});

class OverviewData {
  const OverviewData({
    required this.totalSalesToday,
    required this.totalSalesWeek,
    required this.orderCountToday,
    required this.orderCountWeek,
    required this.paymentsToday,
    required this.productsCount,
    required this.activeProducts,
    required this.lowStockProducts,
    required this.staffCount,
    required this.salesTrendSpots,
    required this.staffLabels,
    required this.staffValues,
  });

  final double totalSalesToday;
  final double totalSalesWeek;
  final int orderCountToday;
  final int orderCountWeek;
  final double paymentsToday;
  final int productsCount;
  final int activeProducts;
  final int lowStockProducts;
  final int staffCount;
  final List<FlSpot> salesTrendSpots;
  final List<String> staffLabels;
  final List<double> staffValues;
}

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewDataProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => StateLayout(
          error: err.toString(),
          onRetry: () => ref.invalidate(overviewDataProvider),
          child: const SizedBox.shrink(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(overviewDataProvider);
            await SyncService.syncAll();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(
                  AppLocalizations.of(context)!.dashboard,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  _SyncStatusBadge(status: syncStatus),
                  const SizedBox(width: DesignTokens.spacingMd),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKpiGrid(context, data),
                      const SizedBox(height: DesignTokens.spacingXl),
                      SectionHeader(
                        title: AppLocalizations.of(context)!.salesTrend,
                        subtitle: AppLocalizations.of(context)!.last7days,
                      ),
                      const SizedBox(height: DesignTokens.spacingSm),
                      SalesTrendChart(data: data.salesTrendSpots),
                      const SizedBox(height: DesignTokens.spacingXl),
                      SectionHeader(
                        title: AppLocalizations.of(context)!.topStaffThisWeek,
                        subtitle: AppLocalizations.of(context)!.byTotalSales,
                      ),
                      const SizedBox(height: DesignTokens.spacingSm),
                      StaffPerformanceChart(
                        labels: data.staffLabels,
                        values: data.staffValues,
                      ),
                      const SizedBox(height: DesignTokens.spacingXl),
                      _buildQuickStats(context, data),
                      const SizedBox(height: DesignTokens.spacingXl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, OverviewData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth > 800 ? 1.6 : 1.4,
          crossAxisSpacing: DesignTokens.spacingMd,
          mainAxisSpacing: DesignTokens.spacingMd,
          children: [
            KpiCard(
              title: AppLocalizations.of(context)!.salesToday,
              value: 'XAF ${data.totalSalesToday.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              icon: Icons.attach_money,
              color: Colors.green,
              trend: '+12%',
              trendUp: true,
            ),
            KpiCard(
              title: AppLocalizations.of(context)!.ordersToday,
              value: data.orderCountToday.toString(),
              icon: Icons.receipt_long,
              color: Theme.of(context).colorScheme.primary,
              trend: '+5',
              trendUp: true,
            ),
            KpiCard(
              title: AppLocalizations.of(context)!.lowStockAlertLabel,
              value: data.lowStockProducts.toString(),
              icon: Icons.warning_amber_rounded,
              color: data.lowStockProducts > 0 ? Colors.red : Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, OverviewData data) {
    return const SizedBox.shrink();
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: DesignTokens.spacingXs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SyncStatusBadge extends ConsumerWidget {
  const _SyncStatusBadge({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    late Color badgeColor;
    late IconData icon;
    if (status.syncing) {
      badgeColor = Colors.amber;
      icon = Icons.sync;
    } else if (status.ok) {
      badgeColor = Colors.green;
      icon = Icons.cloud_done;
    } else {
      badgeColor = Colors.grey;
      icon = Icons.cloud_off;
    }

    return Container(
      margin: const EdgeInsets.only(right: DesignTokens.spacingMd),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMd,
        vertical: DesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            status.message,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}