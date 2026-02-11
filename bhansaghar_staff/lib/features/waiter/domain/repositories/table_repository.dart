import 'package:bhansaghar_staff/core/models/table/table_status_response.dart';
import 'package:bhansaghar_staff/core/services/table_service.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/table_model.dart';

abstract class WaiterTableRepository {
  Future<List<WaiterTable>> getTables();
  Future<void> updateTableStatus(int tableId, TableStatus status);
  Stream<List<WaiterTable>> watchTables();
}

class WaiterTableRepositoryImpl extends WaiterTableRepository {
  final TableService tableService;

  List<WaiterTable> _cachedTables = [];

  WaiterTableRepositoryImpl({required this.tableService});

  /// Convert TableStatusEnum to TableStatus enum
  static TableStatus _convertStatus(TableStatusEnum apiStatus) {
    switch (apiStatus) {
      case TableStatusEnum.available:
        return TableStatus.available;
      case TableStatusEnum.occupied:
        return TableStatus.occupied;
      case TableStatusEnum.ready:
        return TableStatus.ready;
      case TableStatusEnum.serving:
        // Map serving to occupied for UI purposes
        return TableStatus.occupied;
      case TableStatusEnum.dirty:
        return TableStatus.dirty;
    }
  }

  @override
  Future<List<WaiterTable>> getTables() async {
    try {
      // Fetch tables from real backend API
      final apiTables = await tableService.getTables();

      _cachedTables = apiTables
          .map(
            (table) => WaiterTable(
              id: table.number,
              name: 'Table ${table.number}',
              status: _convertStatus(table.status),
              capacity: table.capacity,
              restaurantName: 'Restaurant', // Will be updated by BLoC
              lastUpdated: DateTime.now(),
            ),
          )
          .toList();

      // Sort by table number
      _cachedTables.sort((a, b) => a.id.compareTo(b.id));

      return _cachedTables;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTableStatus(int tableId, TableStatus status) async {
    try {
      // Map TableStatus to TableStatusEnum
      final apiStatus = _mapToApiStatus(status);

      // Call backend API to update status
      await tableService.updateTableStatus(
        tableNumber: tableId,
        newStatus: apiStatus,
      );

      // Update cached data
      final index = _cachedTables.indexWhere((table) => table.id == tableId);
      if (index != -1) {
        _cachedTables[index] = _cachedTables[index].copyWith(
          status: status,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<WaiterTable>> watchTables() async* {
    yield _cachedTables;
    // Poll backend for updates every 5 seconds
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final updatedTables = await getTables();
        yield updatedTables;
      } catch (e) {
        // Continue polling even if there's an error
        yield _cachedTables;
      }
    }
  }

  /// Convert TableStatus enum to TableStatusEnum for API calls
  static TableStatusEnum _mapToApiStatus(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return TableStatusEnum.available;
      case TableStatus.occupied:
        return TableStatusEnum.occupied;
      case TableStatus.ready:
        return TableStatusEnum.ready;
      case TableStatus.serving:
        return TableStatusEnum.occupied;
      case TableStatus.dirty:
        return TableStatusEnum.dirty;
    }
  }
}
