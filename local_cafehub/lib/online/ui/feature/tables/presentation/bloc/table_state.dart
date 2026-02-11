import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/table/table_model.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {
  const TableInitial();
}

class TableLoading extends TableState {
  const TableLoading();
}

class TableLoaded extends TableState {
  final List<TableModel> tables;
  final String currentFilter; // all, available, occupied, reserved, preparing
  final String searchQuery;
  final TableModel? selectedTable;
  final List<String>? selectedTableQRCodes;

  const TableLoaded({
    required this.tables,
    this.currentFilter = 'all',
    this.searchQuery = '',
    this.selectedTable,
    this.selectedTableQRCodes,
  });

  // Get filtered and searched tables
  List<TableModel> get filteredTables {
    var filtered = tables;

    // Apply status filter
    if (currentFilter != 'all') {
      if (currentFilter == 'active') {
        filtered = filtered.where((table) => table.isActive).toList();
      } else if (currentFilter == 'inactive') {
        filtered = filtered.where((table) => !table.isActive).toList();
      }
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (table) => table.tableNumber.toString().toLowerCase().contains(
              searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    return filtered;
  }

  // Get statistics
  int get totalTables => tables.length;
  int get activeTables => tables.where((t) => t.isActive).length;
  int get inactiveTables => tables.where((t) => !t.isActive).length;

  TableLoaded copyWith({
    List<TableModel>? tables,
    String? currentFilter,
    String? searchQuery,
    TableModel? selectedTable,
    List<String>? selectedTableQRCodes,
  }) {
    return TableLoaded(
      tables: tables ?? this.tables,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTable: selectedTable ?? this.selectedTable,
      selectedTableQRCodes: selectedTableQRCodes ?? this.selectedTableQRCodes,
    );
  }

  @override
  List<Object?> get props => [
    tables,
    currentFilter,
    searchQuery,
    selectedTable,
    selectedTableQRCodes,
  ];
}

class TableError extends TableState {
  final String message;

  const TableError(this.message);

  @override
  List<Object?> get props => [message];
}

class TableQRCodesLoaded extends TableState {
  final String tableId;
  final List<String> qrCodes;

  const TableQRCodesLoaded({required this.tableId, required this.qrCodes});

  @override
  List<Object?> get props => [tableId, qrCodes];
}

class TableOperationLoading extends TableState {
  const TableOperationLoading();
}

class TableOperationSuccess extends TableState {
  final String message;

  const TableOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TableOperationError extends TableState {
  final String message;

  const TableOperationError({required this.message});

  @override
  List<Object?> get props => [message];
}
