part of 'table_details_bloc.dart';


abstract class TableDetailsState {
  const TableDetailsState();
}

class TableDetailsInitial extends TableDetailsState {
  const TableDetailsInitial();
}

class TableDetailsLoading extends TableDetailsState {
  const TableDetailsLoading();
}

class TableDetailsLoaded extends TableDetailsState {
  final TableDetailsModel table;

  const TableDetailsLoaded(this.table);

  TableDetailsLoaded copyWith({
    TableDetailsModel? table,
  }) {
    return TableDetailsLoaded(table ?? this.table);
  }
}

class TableDetailsUpdating extends TableDetailsState {
  final TableDetailsModel table;

  const TableDetailsUpdating(this.table);
}

class TableDetailsUpdated extends TableDetailsState {
  final TableDetailsModel table;
  final String message;

  const TableDetailsUpdated(this.table, this.message);
}

class TableDetailsError extends TableDetailsState {
  final String message;

  const TableDetailsError(this.message);
}
