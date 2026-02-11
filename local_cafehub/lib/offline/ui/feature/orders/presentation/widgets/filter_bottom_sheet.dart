import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_filter.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/presentation/bloc/order_state.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  final OrderFilter currentFilter;

  const FilterBottomSheet({super.key, required this.currentFilter});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedStatus;
  late String? _selectedTable;
  late SortOrder _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedStatus = List.from(widget.currentFilter.status);
    _selectedTable = widget.currentFilter.tableNumber;
    _selectedSort = widget.currentFilter.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.filterOrders,
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = [];
                    _selectedTable = null;
                    _selectedSort = SortOrder.newest;
                  });
                },
                child: Text(AppLocalizations.of(context)!.reset),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sort Order
          Text(
            AppLocalizations.of(context)!.sortBy,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSortChip(
                AppLocalizations.of(context)!.newestFirst,
                SortOrder.newest,
              ),
              const SizedBox(width: 12),
              _buildSortChip(
                AppLocalizations.of(context)!.oldestFirst,
                SortOrder.oldest,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter
          Text(
            AppLocalizations.of(context)!.status,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(AppLocalizations.of(context)!.received),
              _buildStatusChip(AppLocalizations.of(context)!.preparing),
              _buildStatusChip(AppLocalizations.of(context)!.ready),
              _buildStatusChip(AppLocalizations.of(context)!.completed),
            ],
          ),
          const SizedBox(height: 24),

          // Table Filter (Simplified for now - can be dynamic later)
          Text(
            AppLocalizations.of(context)!.table,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              // Extract unique table numbers from orders
              final tables = state.orders
                  .map((o) => o.tableNumber)
                  .where((t) => t != null)
                  .toSet()
                  .toList();

              if (tables.isEmpty) {
                return Text(
                  AppLocalizations.of(context)!.noTablesActive,
                  style: TextStyle(color: AppColors.getSubtitleColor(context)),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tables
                    .map((table) => _buildTableChip(table!))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final filter = OrderFilter(
                  status: _selectedStatus,
                  tableNumber: _selectedTable,
                  sortOrder: _selectedSort,
                );
                context.read<OrderBloc>().add(UpdateFilter(filter));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.applyFilters,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, SortOrder value) {
    final isSelected = _selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = value;
        });
      },
      backgroundColor: AppColors.getCardBackground(context),
      selectedColor: Colors.orange.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.orange : AppColors.getTextColor(context),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.orange
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus.contains(status);
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedStatus.add(status);
          } else {
            _selectedStatus.remove(status);
          }
        });
      },
      backgroundColor: AppColors.getCardBackground(context),
      selectedColor: Colors.orange.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.orange : AppColors.getTextColor(context),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.orange
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildTableChip(String table) {
    final isSelected = _selectedTable == table;
    return FilterChip(
      label: Text('${AppLocalizations.of(context)!.table} $table'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTable = selected ? table : null;
        });
      },
      backgroundColor: AppColors.getCardBackground(context),
      selectedColor: Colors.orange.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.orange : AppColors.getTextColor(context),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.orange
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      showCheckmark: false,
    );
  }
}
