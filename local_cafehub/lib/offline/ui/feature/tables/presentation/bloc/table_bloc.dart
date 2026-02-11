import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/table_repository.dart';
import 'table_event.dart';
import 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableRepository _tableRepository;

  TableBloc({required TableRepository tableRepository})
    : _tableRepository = tableRepository,
      super(const TableState()) {
    on<LoadTables>(_onLoadTables);
    on<SetNumberOfTables>(_onSetNumberOfTables);
    on<UpdateTableStatus>(_onUpdateTableStatus);
    on<DeleteTable>(_onDeleteTable);
  }

  Future<void> _onLoadTables(LoadTables event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: TableStatus.loading));
    try {
      final tables = await _tableRepository.getTables();
      emit(state.copyWith(status: TableStatus.loaded, tables: tables));
    } catch (e) {
      emit(
        state.copyWith(status: TableStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSetNumberOfTables(
    SetNumberOfTables event,
    Emitter<TableState> emit,
  ) async {
    try {
      await _tableRepository.setNumberOfTables(event.count);
      add(LoadTables());
    } catch (e) {
      emit(
        state.copyWith(status: TableStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateTableStatus(
    UpdateTableStatus event,
    Emitter<TableState> emit,
  ) async {
    try {
      await _tableRepository.updateTable(event.table);
      add(LoadTables());
    } catch (e) {
      emit(
        state.copyWith(status: TableStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteTable(
    DeleteTable event,
    Emitter<TableState> emit,
  ) async {
    try {
      await _tableRepository.deleteTable(event.id);
      add(LoadTables());
    } catch (e) {
      emit(
        state.copyWith(status: TableStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
