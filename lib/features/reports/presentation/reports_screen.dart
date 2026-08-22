import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../application/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AuthNotifier.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Sales Report')),
        body: const Center(
          child: Text('Restricted: Admin only'),
        ),
      );
    }
    final report = ref.watch(dailySalesReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Sales Report')),
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
                        'Today',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'Orders', value: '${r.orderCount}'),
                      _SummaryRow(
                        label: 'Total sales',
                        value: CameroonConfig.formatCurrency(r.totalSales),
                      ),
                      _SummaryRow(
                        label: 'VAT collected',
                        value: CameroonConfig.formatCurrency(r.totalVat),
                      ),
                      _SummaryRow(
                        label: 'Cash in drawer',
                        value: CameroonConfig.formatCurrency(r.payments),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'By salesperson',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (byPerson.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No sales today'),
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