import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../application/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AuthNotifier.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.dailySalesReport)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.restrictedAdmin),
        ),
      );
    }
    final report = ref.watch(dailySalesReportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.dailySalesReport)),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (r) {
          final byPerson = r.bySalesperson();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.today,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(label: AppLocalizations.of(context)!.orders, value: '${r.orderCount}'),
                      _SummaryRow(
                        label: AppLocalizations.of(context)!.totalSalesLabel,
                        value: CameroonConfig.formatCurrency(r.totalSales),
                      ),
                      _SummaryRow(
                        label: AppLocalizations.of(context)!.vatCollected,
                        value: CameroonConfig.formatCurrency(r.totalVat),
                      ),
                      _SummaryRow(
                        label: AppLocalizations.of(context)!.cashInDrawer,
                        value: CameroonConfig.formatCurrency(r.payments),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.bySalesperson,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (byPerson.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(AppLocalizations.of(context)!.noSalesToday),
                )
              else
                ...byPerson.map(
                  (s) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(s.salesperson.name.characters.first),
                      ),
                      title: Text(s.salesperson.name),
                      subtitle: Text('${s.orderCount} orders'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CameroonConfig.formatCurrency(s.totalSales),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cash: ${CameroonConfig.formatCurrency(s.cashReceived)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}