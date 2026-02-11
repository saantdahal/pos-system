import 'package:equatable/equatable.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/table_model.dart';

abstract class WaiterDashboardEvent extends Equatable {
  const WaiterDashboardEvent();

  @override
  List<Object> get props => [];
}

class WaiterDashboardInitialize extends WaiterDashboardEvent {
  const WaiterDashboardInitialize();
}

class WaiterDashboardRefresh extends WaiterDashboardEvent {
  const WaiterDashboardRefresh();
}

class WaiterUpdateTableStatus extends WaiterDashboardEvent {
  final int tableId;
  final TableStatus newStatus;

  const WaiterUpdateTableStatus({
    required this.tableId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [tableId, newStatus];
}

class WaiterTablesUpdated extends WaiterDashboardEvent {
  final List<WaiterTable> tables;

  const WaiterTablesUpdated(this.tables);

  @override
  List<Object> get props => [tables];
}
