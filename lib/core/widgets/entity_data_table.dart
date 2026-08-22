import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/database/hive_service.dart';
import '../../core/database/models/product.dart';
import '../../core/database/models/user.dart';
import '../../core/database/models/client.dart';
import '../../core/sync/sync_service.dart';
import '../../core/theme/design_tokens.dart';

class EntityDataTable<T> extends ConsumerStatefulWidget {
  const EntityDataTable({
    super.key,
    required this.columns,
    required this.getRows,
    required this.onEdit,
    required this.onDelete,
    this.onAdd,
    this.addLabel = 'Add',
    this.emptyMessage = 'No data',
    this.emptyIcon,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.rowsPerPage = 10,
  });

  final List<DataColumn> columns;
  final List<DataRow> Function() getRows;
  final Future<void> Function(T item) onEdit;
  final Future<void> Function(T item) onDelete;
  final Future<void> Function()? onAdd;
  final String addLabel;
  final String emptyMessage;
  final IconData? emptyIcon;
  final int? sortColumnIndex;
  final bool sortAscending;
  final Function(int, bool)? onSort;
  final int rowsPerPage;

  @override
  ConsumerState<EntityDataTable<T>> createState() => _EntityDataTableState<T>();
}

class _EntityDataTableState<T> extends ConsumerState<EntityDataTable<T>> {
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending;
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    widget.onSort?.call(columnIndex, ascending);
  }

  void _nextPage() {
    final rows = widget.getRows();
    final totalPages = (rows.length / widget.rowsPerPage).ceil();
    if (_currentPage < totalPages - 1) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  List<DataRow> _getPaginatedRows() {
    final rows = widget.getRows();
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, rows.length);
    return rows.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = widget.getRows();
    final paginatedRows = _getPaginatedRows();
    final totalPages = (rows.length / widget.rowsPerPage).ceil();

    return Column(
      children: [
        if (widget.onAdd != null)
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(widget.addLabel),
                ),
              ],
            ),
          ),
        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMd,
            vertical: DesignTokens.spacingSm,
          ),
          elevation: DesignTokens.elevationLevel1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (rows.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: widget.columns,
                    rows: paginatedRows,
                    headingRowColor: WidgetStateProperty.resolveWith((states) =>
                        theme.colorScheme.surfaceContainerHighest),
                    headingRowHeight: 48,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 64,
                    columnSpacing: DesignTokens.spacingLg,
                    horizontalMargin: DesignTokens.spacingLg,
                    dividerThickness: 1,
                    showCheckboxColumn: false,
                    onSelectAll: null,
                  ),
                ),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingXl),
                  child: Column(
                    children: [
                      Icon(
                        widget.emptyIcon ?? Icons.inbox_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: DesignTokens.spacingMd),
                      Text(
                        widget.emptyMessage,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${_currentPage + 1} of $totalPages (${rows.length} items)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _currentPage > 0 ? _previousPage : null,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous',
                          ),
                          IconButton(
                            onPressed:
                                _currentPage < totalPages - 1 ? _nextPage : null,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

DataColumn buildColumn(
  String label, {
  bool numeric = false,
  bool sortable = true,
  VoidCallback? onSort,
}) {
  return DataColumn(
    label: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    ),
    numeric: numeric,
    onSort: sortable ? (colIndex, ascending) => onSort?.call() : null,
  );
}

DataCell buildCell(String text, {TextStyle? style}) {
  return DataCell(
    Text(
      text,
      style: style ??
          GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

DataCell buildCurrencyCell(double amount, {required String currency}) {
  return DataCell(
    Text(
      '$currency ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

DataCell buildStatusChip(String status) {
  Color color;
  switch (status.toLowerCase()) {
    case 'active':
    case 'paid':
      color = Colors.green;
      break;
    case 'pending':
      color = Colors.orange;
      break;
    case 'cancelled':
    case 'refunded':
    case 'inactive':
      color = Colors.red;
      break;
    default:
      color = Colors.grey;
  }
  return DataCell(
    Chip(
      label: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    ),
  );
}

DataCell buildActionCell<T>(
  BuildContext context,
  T item,
  Future<void> Function(T) onEdit,
  Future<void> Function(T) onDelete,
) {
  final theme = Theme.of(context);
  return DataCell(
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
          onPressed: () => onEdit(item),
          tooltip: 'Edit',
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
          onPressed: () => onDelete(item),
          tooltip: 'Delete',
          visualDensity: VisualDensity.compact,
        ),
      ],
    ),
  );
}