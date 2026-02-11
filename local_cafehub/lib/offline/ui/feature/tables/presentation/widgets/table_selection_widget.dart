import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import '../../data/models/table.dart';
import '../bloc/table_bloc.dart';
import '../bloc/table_event.dart';
import '../bloc/table_state.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class TableSelectionWidget extends StatefulWidget {
  final String? selectedTableId;
  final Function(TableModel?) onTableSelected;

  const TableSelectionWidget({
    super.key,
    this.selectedTableId,
    required this.onTableSelected,
  });

  @override
  State<TableSelectionWidget> createState() => _TableSelectionWidgetState();
}

class _TableSelectionWidgetState extends State<TableSelectionWidget> {
  String? _selectedTableId;

  @override
  void initState() {
    super.initState();
    _selectedTableId = widget.selectedTableId;
    context.read<TableBloc>().add(LoadTables());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        if (state.status == TableStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == TableStatus.error) {
          return Center(
            child: Text(
              '${AppLocalizations.of(context)!.serverError} ${state.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state.tables.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.noTablesConfigured,
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectTable,
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Option to select no table
                _buildTableChip(
                  context,
                  label: AppLocalizations.of(context)!.noTable,
                  isSelected: _selectedTableId == null,
                  onTap: () {
                    setState(() {
                      _selectedTableId = null;
                    });
                    widget.onTableSelected(null);
                  },
                ),
                // Table options
                ...state.tables.map((table) {
                  return _buildTableChip(
                    context,
                    label:
                        '${AppLocalizations.of(context)!.table} ${table.tableNumber}',
                    isSelected: _selectedTableId == table.id,
                    isOccupied: table.isOccupied,
                    onTap: () {
                      setState(() {
                        _selectedTableId = table.id;
                      });
                      widget.onTableSelected(table);
                    },
                  );
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    bool isOccupied = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.orange
              : AppColors.getTextField(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.orange
                : AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOccupied && !isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.circle, size: 8, color: Colors.red),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextColor(context),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
