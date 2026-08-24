import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../core/database/hive_service.dart';
import '../../../core/database/models/user.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/entity_data_table.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/localization/app_localizations.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _getFilteredStaff() {
    final staff = HiveService.usersBox.values.toList();
    if (_searchQuery.isEmpty) return staff;
    final query = _searchQuery.toLowerCase();
    return staff.where((u) =>
        u.name.toLowerCase().contains(query) ||
        u.phone.toLowerCase().contains(query) ||
        u.role.toLowerCase().contains(query)).toList();
  }

  List<DataColumn> _getColumns() {
    return [
      buildColumn('Name'),
      buildColumn('Phone'),
      buildColumn('Role'),
      buildColumn('Status'),
      buildColumn('Created', numeric: false, sortable: true),
      buildColumn('Actions', numeric: false, sortable: false),
    ];
  }

  List<DataRow> _getRows() {
    final staff = _getFilteredStaff();
    staff.sort((a, b) => a.name.compareTo(b.name));
    return staff.map((u) {
      return DataRow(
        cells: [
          buildCell(u.name),
          buildCell(u.phone.isEmpty ? '—' : u.phone),
          DataCell(
            Chip(
              label: Text(
                u.role,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: u.role == 'admin'
                  ? Colors.blue
                  : Colors.green,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          buildStatusChip(u.isActive ? AppLocalizations.of(context)!.activeField : 'Inactive'),
          buildCell(
            '${u.createdAt.day}/${u.createdAt.month}/${u.createdAt.year}',
          ),
          buildActionCell<User>(
            context,
            u,
            _editStaff,
            _deleteStaff,
          ),
        ],
      );
    }).toList();
  }

  Future<void> _addStaff() async {
    final result = await _showStaffDialog(context);
    if (result != null && context.mounted) {
      await HiveService.usersBox.add(result);
      unawaited(SyncService.pushUsers());
      ref.invalidate(staffProvider);
    }
  }

  Future<void> _editStaff(User user) async {
    final result = await _showStaffDialog(context, user: user);
    if (result != null && context.mounted) {
      final index = HiveService.usersBox.values
          .toList()
          .indexWhere((usr) => usr.userId == user.userId);
      if (index >= 0) {
        await HiveService.usersBox.putAt(index, result);
        unawaited(SyncService.pushUsers());
        ref.invalidate(staffProvider);
      }
    }
  }

  Future<void> _deleteStaff(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteStaffQuestion),
        content: Text(AppLocalizations.of(context)!.areYouSureDelete(user.name)),
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
      final index = HiveService.usersBox.values
          .toList()
          .indexWhere((u) => u.userId == user.userId);
      if (index >= 0) {
        await HiveService.usersBox.deleteAt(index);
        unawaited(SyncService.pushUsers());
        ref.invalidate(staffProvider);
      }
    }
  }

  Future<User?> _showStaffDialog(BuildContext context,
      {User? user}) async {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final pinController = TextEditingController(text: user?.pin ?? '');
    String role = user?.role ?? 'salesperson';
    bool isActive = user?.isActive ?? true;

    return showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? AppLocalizations.of(context)!.editStaff : AppLocalizations.of(context)!.addStaff),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nameField),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.phoneField),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(
                    labelText: isEditing ? AppLocalizations.of(context)!.pinField : AppLocalizations.of(context)!.pinFieldRequired,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.roleField),
                  items: [
                    DropdownMenuItem(value: 'admin', child: Text(AppLocalizations.of(context)!.admin)),
                    DropdownMenuItem(value: 'salesperson', child: Text(AppLocalizations.of(context)!.salesperson)),
                  ],
                  onChanged: (v) => role = v ?? 'salesperson',
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
              final phone = phoneController.text.trim();
              final pin = pinController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)),
                );
                return;
              }
              if (!isEditing && pin.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.pinRequired)),
                );
                return;
              }

              Navigator.pop(context, User()
                ..userId = user?.userId ?? IdGenerator.generate()
                ..name = name
                ..phone = phone
                ..pin = pin.isEmpty ? (user?.pin ?? '') : pin
                ..role = role
                ..isActive = isActive
                ..email = user?.email
                ..vendorId = user?.vendorId ?? ''
                ..storeId = user?.storeId ?? ''
                ..createdAt = user?.createdAt ?? DateTime.now()
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
        title: Text(AppLocalizations.of(context)!.staff),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchStaff,
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
      body: EntityDataTable<User>(
        columns: _getColumns(),
        getRows: _getRows,
        onEdit: _editStaff,
        onDelete: _deleteStaff,
        onAdd: _addStaff,
        addLabel: AppLocalizations.of(context)!.addStaff,
        emptyMessage: AppLocalizations.of(context)!.noStaffMembers,
        emptyIcon: Icons.group_outlined,
      ),
    );
  }
}

final staffProvider = FutureProvider<List<User>>((ref) async {
  return HiveService.usersBox.values.toList();
});