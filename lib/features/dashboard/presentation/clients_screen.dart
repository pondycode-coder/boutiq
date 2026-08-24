import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/client.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/entity_data_table.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/localization/app_localizations.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Client> _getFilteredClients() {
    final clients = HiveService.clientsBox.values.toList();
    if (_searchQuery.isEmpty) return clients;
    final query = _searchQuery.toLowerCase();
    return clients.where((c) =>
        c.name.toLowerCase().contains(query) ||
        c.nameFr.toLowerCase().contains(query) ||
        c.phone.toLowerCase().contains(query) ||
        c.clientType.toLowerCase().contains(query)).toList();
  }

  List<DataColumn> _getColumns() {
    return [
      buildColumn('Name'),
      buildColumn('Type'),
      buildColumn('Phone'),
      buildColumn('Region'),
      buildColumn('Status'),
      buildColumn('Actions', numeric: false, sortable: false),
    ];
  }

  List<DataRow> _getRows() {
    final clients = _getFilteredClients();
    clients.sort((a, b) => a.name.compareTo(b.name));
    return clients.map((c) {
      return DataRow(
        cells: [
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (c.nameFr.isNotEmpty)
                  Text(
                    c.nameFr,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          DataCell(
            Chip(
              label: Text(
                c.clientType,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.purple.withValues(alpha: 0.12),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          buildCell(c.phone.isEmpty ? '—' : c.phone),
          buildCell(c.region.isEmpty ? '—' : c.region),
          buildStatusChip(c.isActive ? AppLocalizations.of(context)!.activeField : 'Inactive'),
          buildActionCell<Client>(
            context,
            c,
            _editClient,
            _deleteClient,
          ),
        ],
      );
    }).toList();
  }

  Future<void> _addClient() async {
    final result = await _showClientDialog(context);
    if (result != null && context.mounted) {
      await HiveService.clientsBox.add(result);
      unawaited(SyncService.pushClients());
      ref.invalidate(clientsProvider);
    }
  }

  Future<void> _editClient(Client client) async {
    final result = await _showClientDialog(context, client: client);
    if (result != null && context.mounted) {
      final index = HiveService.clientsBox.values
          .toList()
          .indexWhere((cli) => cli.clientId == client.clientId);
      if (index >= 0) {
        await HiveService.clientsBox.putAt(index, result);
        unawaited(SyncService.pushClients());
        ref.invalidate(clientsProvider);
      }
    }
  }

  Future<void> _deleteClient(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteClientQuestion),
        content: Text(AppLocalizations.of(context)!.areYouSureDelete(client.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final index = HiveService.clientsBox.values
          .toList()
          .indexWhere((c) => c.clientId == client.clientId);
      if (index >= 0) {
        await HiveService.clientsBox.deleteAt(index);
        unawaited(SyncService.pushClients());
        ref.invalidate(clientsProvider);
      }
    }
  }

  Future<Client?> _showClientDialog(BuildContext context,
      {Client? client}) async {
    final isEditing = client != null;
    final nameController = TextEditingController(text: client?.name ?? '');
    final nameFrController = TextEditingController(text: client?.nameFr ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final addressController = TextEditingController(text: client?.address ?? '');
    final contactPersonController =
        TextEditingController(text: client?.contactPerson ?? '');
    final regionController = TextEditingController(text: client?.region ?? '');
    final divisionController = TextEditingController(text: client?.division ?? '');
    final subdivisionController =
        TextEditingController(text: client?.subdivision ?? '');
    String clientType = client?.clientType ?? 'retail';
    bool isActive = client?.isActive ?? true;

    return showDialog<Client>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? AppLocalizations.of(context)!.editClient : AppLocalizations.of(context)!.addClient),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nameField),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: nameFrController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nameFrField),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                DropdownButtonFormField<String>(
                  value: clientType,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.typeField),
                  items: [
                    DropdownMenuItem(value: 'retail', child: Text(AppLocalizations.of(context)!.retail)),
                    DropdownMenuItem(value: 'wholesale', child: Text(AppLocalizations.of(context)!.wholesale)),
                    DropdownMenuItem(value: 'corporate', child: Text(AppLocalizations.of(context)!.corporate)),
                  ],
                  onChanged: (v) => clientType = v ?? 'retail',
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneField),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: regionController,
                        decoration: const InputDecoration(labelText: 'Region'),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingMd),
                    Expanded(
                      child: TextField(
                        controller: divisionController,
                        decoration: const InputDecoration(labelText: 'Division'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: subdivisionController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.subdivisionField),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: contactPersonController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.contactPersonField),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.activeField),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v ?? true),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)),
                );
                return;
              }

              Navigator.pop(context, Client()
                ..clientId = client?.clientId ?? IdGenerator.generate()
                ..name = name
                ..nameFr = nameFrController.text.trim()
                ..clientType = clientType
                ..region = regionController.text.trim()
                ..division = divisionController.text.trim()
                ..subdivision = subdivisionController.text.trim()
                ..address = addressController.text.trim()
                ..phone = phoneController.text.trim()
                ..email = emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim()
                ..contactPerson = contactPersonController.text.trim()
                ..creditLimit = client?.creditLimit ?? 0
                ..currentBalance = client?.currentBalance ?? 0
                ..paymentTermsDays = client?.paymentTermsDays ?? 0
                ..preferredPaymentMethod = client?.preferredPaymentMethod ?? ''
                ..assignedRouteId = client?.assignedRouteId ?? ''
                ..isActive = isActive
                ..createdAt = client?.createdAt ?? DateTime.now()
                ..updatedAt = DateTime.now());
            },
            child: Text(isEditing ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.clients),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchClients,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: EntityDataTable<Client>(
        columns: _getColumns(),
        getRows: _getRows,
        onEdit: _editClient,
        onDelete: _deleteClient,
        onAdd: _addClient,
        addLabel: AppLocalizations.of(context)!.addClient,
        emptyMessage: AppLocalizations.of(context)!.noClients,
        emptyIcon: Icons.people_outline,
      ),
    );
  }
}

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  return HiveService.clientsBox.values.toList();
});