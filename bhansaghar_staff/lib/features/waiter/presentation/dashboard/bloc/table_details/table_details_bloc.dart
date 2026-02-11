import 'package:bloc/bloc.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/table_details_model.dart';

part 'table_details_event.dart';
part 'table_details_state.dart';

class TableDetailsBloc extends Bloc<TableDetailsEvent, TableDetailsState> {
  TableDetailsBloc() : super(const TableDetailsInitial()) {
    on<LoadTableDetailsEvent>(_onLoadTableDetails);
    on<CleanTableEvent>(_onCleanTable);
    on<MarkTableReadyEvent>(_onMarkTableReady);
    on<CallKitchenEvent>(_onCallKitchen);
    on<UpdateTableStatusEvent>(_onUpdateTableStatus);
  }

  Future<void> _onLoadTableDetails(
    LoadTableDetailsEvent event,
    Emitter<TableDetailsState> emit,
  ) async {
    emit(const TableDetailsLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final mockTable = TableDetailsModel(
        id: event.tableId,
        tableNumber: 12,
        capacity: 4,
        status: 'occupied',
        specialInstructions: 'Special: VIP table',
        recentOrders: [
          TableOrderModel(
            id: 1,
            itemName: 'Chicken Momo',
            quantity: 2,
            time: '12:45 PM',
            additionalInfo: 'Steamed',
            status: 'served',
          ),
          TableOrderModel(
            id: 2,
            itemName: 'Iced Tea',
            quantity: 2,
            time: '12:55 PM',
            additionalInfo: 'Less Sugar',
            status: 'pending',
          ),
        ],
        hasLiveOrders: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      emit(TableDetailsLoaded(mockTable));
    } catch (e) {
      emit(TableDetailsError('Failed to load table details: $e'));
    }
  }

  Future<void> _onCleanTable(
    CleanTableEvent event,
    Emitter<TableDetailsState> emit,
  ) async {
    if (state is TableDetailsLoaded) {
      final currentState = state as TableDetailsLoaded;
      emit(TableDetailsUpdating(currentState.table));

      try {
        await Future.delayed(const Duration(milliseconds: 600));

        emit(TableDetailsUpdated(currentState.table, 'Table marked for cleaning'));
      } catch (e) {
        emit(TableDetailsError('Failed to clean table: $e'));
      }
    }
  }

  Future<void> _onMarkTableReady(
    MarkTableReadyEvent event,
    Emitter<TableDetailsState> emit,
  ) async {
    if (state is TableDetailsLoaded) {
      final currentState = state as TableDetailsLoaded;
      emit(TableDetailsUpdating(currentState.table));

      try {
        await Future.delayed(const Duration(milliseconds: 600));

        final updatedTable = currentState.table.copyWith(status: 'available');
        emit(TableDetailsUpdated(updatedTable, 'Table marked as ready'));
        emit(TableDetailsLoaded(updatedTable));
      } catch (e) {
        emit(TableDetailsError('Failed to mark table ready: $e'));
      }
    }
  }

  Future<void> _onCallKitchen(
    CallKitchenEvent event,
    Emitter<TableDetailsState> emit,
  ) async {
    if (state is TableDetailsLoaded) {
      final currentState = state as TableDetailsLoaded;

      try {
        await Future.delayed(const Duration(milliseconds: 400));

        emit(TableDetailsUpdated(currentState.table, 'Kitchen called'));
      } catch (e) {
        emit(TableDetailsError('Failed to call kitchen: $e'));
      }
    }
  }

  Future<void> _onUpdateTableStatus(
    UpdateTableStatusEvent event,
    Emitter<TableDetailsState> emit,
  ) async {
    if (state is TableDetailsLoaded) {
      final currentState = state as TableDetailsLoaded;
      emit(TableDetailsUpdating(currentState.table));

      try {
        await Future.delayed(const Duration(milliseconds: 600));

        final updatedTable = currentState.table.copyWith(status: event.newStatus);
        emit(TableDetailsUpdated(updatedTable, 'Table status updated'));
        emit(TableDetailsLoaded(updatedTable));
      } catch (e) {
        emit(TableDetailsError('Failed to update table status: $e'));
      }
    }
  }
}
