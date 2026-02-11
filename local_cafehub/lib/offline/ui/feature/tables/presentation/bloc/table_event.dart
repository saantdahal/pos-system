import 'package:equatable/equatable.dart';
import '../../data/models/table.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object?> get props => [];
}

class LoadTables extends TableEvent {}

class SetNumberOfTables extends TableEvent {
  final int count;

  const SetNumberOfTables(this.count);

  @override
  List<Object?> get props => [count];
}

class UpdateTableStatus extends TableEvent {
  final TableModel table;

  const UpdateTableStatus(this.table);

  @override
  List<Object?> get props => [table];
}

class DeleteTable extends TableEvent {
  final String id;

  const DeleteTable(this.id);

  @override
  List<Object?> get props => [id];
}
