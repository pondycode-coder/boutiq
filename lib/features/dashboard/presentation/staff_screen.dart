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
          buildStatusChip(u.isActive ? 'Active' : 'Inactive'),
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
        title: const Text('Delete Staff?'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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
        title: Text(isEditing ? 'Edit Staff' : 'Add Staff'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'PIN (leave blank to keep)' : 'PIN *',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role *'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'salesperson', child: Text('Salesperson')),
                  ],
                  onChanged: (v) => role = v ?? 'salesperson',
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                CheckboxListTile(
                  title: const Text('Active'),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final pin = pinController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }
              if (!isEditing && pin.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN is required for new staff')),
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
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staff...',
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
        addLabel: 'Add Staff',
        emptyMessage: 'No staff members',
        emptyIcon: Icons.group_outlined,
      ),
    );
  }
}

final staffProvider = FutureProvider<List<User>>((ref) async {
  return HiveService.usersBox.values.toList();
});