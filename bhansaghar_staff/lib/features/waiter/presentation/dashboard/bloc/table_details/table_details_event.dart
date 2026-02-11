part of 'table_details_bloc.dart';

abstract class TableDetailsEvent {
  const TableDetailsEvent();
}

class LoadTableDetailsEvent extends TableDetailsEvent {
  final int tableId;

  const LoadTableDetailsEvent(this.tableId);
}

class CleanTableEvent extends TableDetailsEvent {
  const CleanTableEvent();
}

class MarkTableReadyEvent extends TableDetailsEvent {
  const MarkTableReadyEvent();
}

class CallKitchenEvent extends TableDetailsEvent {
  const CallKitchenEvent();
}

class UpdateTableStatusEvent extends TableDetailsEvent {
  final String newStatus;

  const UpdateTableStatusEvent(this.newStatus);
}
