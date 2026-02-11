import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/bloc/table_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/bloc/table_event.dart';
import 'package:bhansa_ghar/online/ui/feature/tables/presentation/bloc/table_state.dart';
import 'table_widgets.dart';
import 'qr_display_dialog.dart';

class TablesList extends StatefulWidget {
  const TablesList({super.key});

  @override
  State<TablesList> createState() => _TablesListState();
}

class _TablesListState extends State<TablesList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<TableBloc>().add(TableSearched(_searchController.text));
  }

  void _onFilterChanged(String filter) {
    context.read<TableBloc>().add(TableFilterChanged(filter));
  }

  void _onTableTap(String tableId) {
    context.read<TableBloc>().add(TableQRCodesRequested(tableId));
    _showTableDetailsBottomSheet(tableId);
  }

  void _toggleTableStatus(String tableId) {
    context.read<TableBloc>().add(TableStatusToggled(tableId: tableId));
    Navigator.of(context).pop(); // Close bottom sheet
  }

  void _regenerateQR(String tableId) {
    context.read<TableBloc>().add(TableQRRegenerated(tableId: tableId));
    // Don't close the bottom sheet, instead refresh the table detail
    context.read<TableBloc>().add(TableQRCodesRequested(tableId));
  }

  void _deleteTable(String tableId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table'),
        content: const Text(
          'Are you sure you want to delete this table? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              context.read<TableBloc>().add(TableDeleted(tableId: tableId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void _showTableDetailsBottomSheet(String tableId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocListener<TableBloc, TableState>(
          listener: (context, state) {
            if (state is TableLoaded &&
                state.selectedTable?.qrCodeUrl != null) {
              // Show success message when QR code is available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR code regenerated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: BlocBuilder<TableBloc, TableState>(
            builder: (context, state) {
              if (state is TableLoaded && state.selectedTable != null) {
                final table = state.selectedTable!;

                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.8,
                  minChildSize: 0.6,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Handle
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Header with Actions
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Title and Close
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Table ${table.tableNumber}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: ${table.id}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: Icon(
                                        Icons.close,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Delete Button
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: () => _deleteTable(table.id),
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 18,
                                    ),
                                    label: const Text('Delete Table'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () =>
                                            _toggleTableStatus(table.id),
                                        icon: Icon(
                                          table.isActive
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 18,
                                        ),
                                        label: Text(
                                          table.isActive
                                              ? 'Deactivate'
                                              : 'Activate',
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () =>
                                            _regenerateQR(table.id),
                                        icon: const Icon(
                                          Icons.qr_code_scanner,
                                          size: 18,
                                        ),
                                        label: const Text('Regenerate QR'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Table Information
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 20,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Table Information',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(
                                          context,
                                          'Table Number',
                                          table.tableNumber.toString(),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          context,
                                          'Status',
                                          table.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          context,
                                          'Created',
                                          _formatDate(table.createdAt),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          context,
                                          'Last Updated',
                                          _formatDate(table.updatedAt),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // QR Code Section
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.qr_code,
                                              size: 20,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'QR Code',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (table.qrCodeUrl != null &&
                                            table.qrCodeUrl!.isNotEmpty) ...[
                                          Text(
                                            'Scan this QR code to access the menu',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 20),
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .shadow
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Image.network(
                                                table.qrCodeUrl!,
                                                width: 160,
                                                height: 160,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.qr_code_2,
                                                        size: 80,
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.outline,
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Text(
                                                        'QR Code not available',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .outline,
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                loadingBuilder:
                                                    (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return const SizedBox(
                                                        width: 160,
                                                        height: 160,
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {
                                                    final state = context
                                                        .read<TableBloc>()
                                                        .state;
                                                    if (state is TableLoaded) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            QRCodeDisplayDialog(
                                                              tableNumber: table
                                                                  .tableNumber
                                                                  .toString(),
                                                              tables:
                                                                  state.tables,
                                                            ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.qr_code,
                                                    size: 18,
                                                  ),
                                                  label: const Text(
                                                    'View All QR',
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: FilledButton.icon(
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Download feature coming soon',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.download,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Download'),
                                                  style: FilledButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.qr_code_2,
                                                  size: 64,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'QR Code not generated',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.onSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'The QR code will be generated automatically when the table is created.',
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: FilledButton.icon(
                                                    onPressed: () =>
                                                        _regenerateQR(table.id),
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                    ),
                                                    label: const Text(
                                                      'Generate QR Code',
                                                    ),
                                                    style: FilledButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 16,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        if (state is! TableLoaded) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TableBloc>().add(const TablesRefreshed());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search table...',
                        hintStyle: TextStyle(color: Color(0xFFB8A0A0)),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFB8A0A0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistics Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatItem(
                          label: 'Total',
                          value: state.totalTables.toString(),
                        ),
                        const StatDivider(),
                        StatItem(
                          label: 'Active',
                          value: state.activeTables.toString(),
                        ),
                        const StatDivider(),
                        StatItem(
                          label: 'Inactive',
                          value: state.inactiveTables.toString(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filter Chips
                  Text(
                    'Filter by Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: 'All',
                          isSelected: state.currentFilter == 'all',
                          count: state.totalTables,
                          onTap: () => _onFilterChanged('all'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: 'Active',
                          isSelected: state.currentFilter == 'active',
                          count: state.activeTables,
                          onTap: () => _onFilterChanged('active'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: 'Inactive',
                          isSelected: state.currentFilter == 'inactive',
                          count: state.inactiveTables,
                          onTap: () => _onFilterChanged('inactive'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tables Grid
                  if (state.filteredTables.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.table_chart_outlined,
                              size: 48,
                              color: Color(0xFF6B7280),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No tables found',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: state.filteredTables.length,
                      itemBuilder: (context, index) {
                        final table = state.filteredTables[index];
                        return TableCard(
                          table: table,
                          onTap: () => _onTableTap(table.id),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
