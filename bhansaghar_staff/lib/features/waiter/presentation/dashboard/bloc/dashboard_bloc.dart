import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:bhansaghar_staff/features/waiter/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/table_repository.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';

class WaiterDashboardBloc
    extends Bloc<WaiterDashboardEvent, WaiterDashboardState> {
  final WaiterTableRepository waiterTableRepository;
  final WaiterProfileRepository profileRepository;

  WaiterDashboardBloc({
    required this.waiterTableRepository,
    required this.profileRepository,
  }) : super(const WaiterDashboardInitial()) {
    on<WaiterDashboardInitialize>(_onDashboardInitialize);
    on<WaiterDashboardRefresh>(_onDashboardRefresh);
    on<WaiterUpdateTableStatus>(_onUpdateTableStatus);
    on<WaiterTablesUpdated>(_onTablesUpdated);
  }

  Future<void> _onDashboardInitialize(
    WaiterDashboardInitialize event,
    Emitter<WaiterDashboardState> emit,
  ) async {
    try {
      emit(const WaiterDashboardLoading());

      // Fetch both tables and restaurant name in parallel
      final tablesResult = await waiterTableRepository.getTables();
      final profile = await profileRepository.getProfile();

      // Get restaurant name from location (staff assigned restaurant)
      final restaurantName = profile.location.isNotEmpty
          ? profile.location
          : 'Restaurant';

      debugPrint(
        '✅ Dashboard initialized: ${tablesResult.length} tables for $restaurantName',
      );

      emit(
        WaiterDashboardLoaded(
          tables: tablesResult,
          restaurantName: restaurantName,
        ),
      );
    } catch (e) {
      debugPrint('❌ Dashboard init error: ${e.toString()}');
      emit(WaiterDashboardError('Failed to load tables: ${e.toString()}'));
    }
  }

  Future<void> _onDashboardRefresh(
    WaiterDashboardRefresh event,
    Emitter<WaiterDashboardState> emit,
  ) async {
    if (state is WaiterDashboardLoaded) {
      try {
        final currentState = state as WaiterDashboardLoaded;
        final tables = await waiterTableRepository.getTables();
        emit(currentState.copyWith(tables: tables));
      } catch (e) {
        emit(WaiterDashboardError('Failed to refresh tables: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateTableStatus(
    WaiterUpdateTableStatus event,
    Emitter<WaiterDashboardState> emit,
  ) async {
    if (state is WaiterDashboardLoaded) {
      try {
        final currentState = state as WaiterDashboardLoaded;
        await waiterTableRepository.updateTableStatus(
          event.tableId,
          event.newStatus,
        );

        // Update the table in the current list
        final updatedTables = currentState.tables.map((table) {
          if (table.id == event.tableId) {
            return table.copyWith(status: event.newStatus);
          }
          return table;
        }).toList();

        emit(currentState.copyWith(tables: updatedTables));
      } catch (e) {
        emit(
          WaiterDashboardError(
            'Failed to update table status: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onTablesUpdated(
    WaiterTablesUpdated event,
    Emitter<WaiterDashboardState> emit,
  ) async {
    if (state is WaiterDashboardLoaded) {
      final currentState = state as WaiterDashboardLoaded;
      emit(currentState.copyWith(tables: event.tables));
    }
  }
}
