import 'package:equatable/equatable.dart';
import '../../data/models/table.dart';

enum TableStatus { initial, loading, loaded, error }

class TableState extends Equatable {
  final TableStatus status;
  final List<TableModel> tables;
  final String? errorMessage;

  const TableState({
    this.status = TableStatus.initial,
    this.tables = const [],
    this.errorMessage,
  });

  TableState copyWith({
    TableStatus? status,
    List<TableModel>? tables,
    String? errorMessage,
  }) {
    return TableState(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tables, errorMessage];
}
