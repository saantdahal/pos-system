import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:bhansa_ghar/online/core/models/table/table_request.dart';
import 'package:bhansa_ghar/online/core/repositories/table_repository.dart';
import 'table_event.dart';
import 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableRepository _tableRepository;

  TableBloc({required TableRepository tableRepository})
    : _tableRepository = tableRepository,
      super(const TableInitial()) {
    on<TablesInitialized>(_onTablesInitialized);
    on<TablesRefreshed>(_onTablesRefreshed);
    on<TableStatusChanged>(_onTableStatusChanged);
    on<TableQRCodesRequested>(_onTableQRCodesRequested);
    on<TableFilterChanged>(_onTableFilterChanged);
    on<TableSearched>(_onTableSearched);
    on<TableCreated>(_onTableCreated);
    on<BulkTablesCreated>(_onBulkTablesCreated);
    on<TableUpdated>(_onTableUpdated);
    on<TableDeleted>(_onTableDeleted);
    on<TableQRRegenerated>(_onTableQRRegenerated);
    on<TableStatusToggled>(_onTableStatusToggled);
  }

  Future<void> _onTablesInitialized(
    TablesInitialized event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableLoading());
    try {
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
    } catch (e) {
      debugPrint('Error loading tables: $e');
      emit(TableError('Failed to load tables: $e'));
    }
  }

  Future<void> _onTablesRefreshed(
    TablesRefreshed event,
    Emitter<TableState> emit,
  ) async {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      emit(const TableLoading());
      try {
        final tables = await _tableRepository.listTables();
        emit(
          TableLoaded(
            tables: tables,
            currentFilter: currentState.currentFilter,
            searchQuery: currentState.searchQuery,
          ),
        );
      } catch (e) {
        debugPrint('Error refreshing tables: $e');
        emit(TableError('Failed to refresh tables'));
      }
    }
  }

  Future<void> _onTableStatusChanged(
    TableStatusChanged event,
    Emitter<TableState> emit,
  ) async {
    // This is for future use - table status management
    // For now, tables don't have status in backend, just is_active
  }

  Future<void> _onTableQRCodesRequested(
    TableQRCodesRequested event,
    Emitter<TableState> emit,
  ) async {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      try {
        // Get table details which include QR code info
        final tableDetail = await _tableRepository.getTableDetail(
          event.tableId,
        );

        emit(
          currentState.copyWith(
            selectedTable: tableDetail,
            selectedTableQRCodes: [
              tableDetail.qrCodeUrl ?? '',
            ], // Single QR code URL per table
          ),
        );
      } catch (e) {
        debugPrint('Error loading QR codes: $e');
        emit(TableError('Failed to load QR codes'));
      }
    }
  }

  Future<void> _onTableFilterChanged(
    TableFilterChanged event,
    Emitter<TableState> emit,
  ) async {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      emit(currentState.copyWith(currentFilter: event.filterStatus));
    }
  }

  Future<void> _onTableSearched(
    TableSearched event,
    Emitter<TableState> emit,
  ) async {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onTableCreated(
    TableCreated event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableOperationLoading());
    try {
      final request = TableRequest(tableNumber: event.tableNumber);
      await _tableRepository.createTable(request);

      // Refresh the table list
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
      emit(const TableOperationSuccess(message: 'Table created successfully'));
    } catch (e) {
      debugPrint('Error creating table: $e');
      emit(TableOperationError(message: 'Failed to create table: $e'));
    }
  }

  Future<void> _onBulkTablesCreated(
    BulkTablesCreated event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableOperationLoading());
    try {
      await _tableRepository.createBulkTables(event.count);

      // Refresh the table list
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
      emit(
        TableOperationSuccess(
          message:
              '${event.count} table${event.count == 1 ? '' : 's'} created successfully',
        ),
      );
    } catch (e) {
      debugPrint('Error creating bulk tables: $e');
      emit(TableOperationError(message: 'Failed to create tables: $e'));
    }
  }

  Future<void> _onTableUpdated(
    TableUpdated event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableOperationLoading());
    try {
      // Get current table to preserve existing values
      final currentTables = await _tableRepository.listTables();
      final currentTable = currentTables.firstWhere(
        (table) => table.id == event.tableId,
      );

      final request = TableRequest(
        tableNumber: event.tableNumber ?? currentTable.tableNumber,
        isActive: event.isActive,
      );
      await _tableRepository.updateTable(event.tableId, request);

      // Refresh the table list
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
      emit(const TableOperationSuccess(message: 'Table updated successfully'));
    } catch (e) {
      debugPrint('Error updating table: $e');
      emit(TableOperationError(message: 'Failed to update table: $e'));
    }
  }

  Future<void> _onTableDeleted(
    TableDeleted event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableOperationLoading());
    try {
      await _tableRepository.deleteTable(event.tableId);

      // Refresh the table list
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
      emit(const TableOperationSuccess(message: 'Table deleted successfully'));
    } catch (e) {
      debugPrint('Error deleting table: $e');
      emit(TableOperationError(message: 'Failed to delete table: $e'));
    }
  }

  Future<void> _onTableQRRegenerated(
    TableQRRegenerated event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableOperationLoading());
    try {
      await _tableRepository.regenerateTableQR(event.tableId);

      // Refresh the table list
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
      // Don't emit TableOperationSuccess to avoid breaking the UI
    } catch (e) {
      debugPrint('Error regenerating QR code: $e');
      emit(TableOperationError(message: 'Failed to regenerate QR code: $e'));
    }
  }

  Future<void> _onTableStatusToggled(
    TableStatusToggled event,
    Emitter<TableState> emit,
  ) async {
    emit(const TableOperationLoading());
    try {
      // Get current table to toggle status
      final currentTables = await _tableRepository.listTables();
      final tableToUpdate = currentTables.firstWhere(
        (table) => table.id == event.tableId,
      );

      final request = TableRequest(
        tableNumber: tableToUpdate.tableNumber,
        isActive: !tableToUpdate.isActive,
      );
      final updatedTable = await _tableRepository.updateTable(
        event.tableId,
        request,
      );

      // Refresh the table list
      final tables = await _tableRepository.listTables();
      emit(TableLoaded(tables: tables));
      emit(
        TableOperationSuccess(
          message:
              'Table ${updatedTable.isActive ? 'activated' : 'deactivated'} successfully',
        ),
      );
    } catch (e) {
      debugPrint('Error toggling table status: $e');
      emit(TableOperationError(message: 'Failed to toggle table status: $e'));
    }
  }
}
