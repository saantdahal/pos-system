import 'package:equatable/equatable.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object?> get props => [];
}

class TablesInitialized extends TableEvent {
  const TablesInitialized();
}

class TablesRefreshed extends TableEvent {
  const TablesRefreshed();
}

class TableStatusChanged extends TableEvent {
  final String tableId;
  final String newStatus;

  const TableStatusChanged({required this.tableId, required this.newStatus});

  @override
  List<Object?> get props => [tableId, newStatus];
}

class TableQRCodesRequested extends TableEvent {
  final String tableId;

  const TableQRCodesRequested(this.tableId);

  @override
  List<Object?> get props => [tableId];
}

class TableFilterChanged extends TableEvent {
  final String filterStatus; // all, available, occupied, reserved, preparing

  const TableFilterChanged(this.filterStatus);

  @override
  List<Object?> get props => [filterStatus];
}

class TableSearched extends TableEvent {
  final String query;

  const TableSearched(this.query);

  @override
  List<Object?> get props => [query];
}

class TableCreated extends TableEvent {
  final int tableNumber;

  const TableCreated({required this.tableNumber});

  @override
  List<Object?> get props => [tableNumber];
}

class BulkTablesCreated extends TableEvent {
  final int count;

  const BulkTablesCreated({required this.count});

  @override
  List<Object?> get props => [count];
}

class TableUpdated extends TableEvent {
  final String tableId;
  final int? tableNumber;
  final bool? isActive;

  const TableUpdated({required this.tableId, this.tableNumber, this.isActive});

  @override
  List<Object?> get props => [tableId, tableNumber, isActive];
}

class TableDeleted extends TableEvent {
  final String tableId;

  const TableDeleted({required this.tableId});

  @override
  List<Object?> get props => [tableId];
}

class TableQRRegenerated extends TableEvent {
  final String tableId;

  const TableQRRegenerated({required this.tableId});

  @override
  List<Object?> get props => [tableId];
}

class TableStatusToggled extends TableEvent {
  final String tableId;

  const TableStatusToggled({required this.tableId});

  @override
  List<Object?> get props => [tableId];
}
