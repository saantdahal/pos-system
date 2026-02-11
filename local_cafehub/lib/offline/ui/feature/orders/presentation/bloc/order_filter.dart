import 'package:equatable/equatable.dart';

enum SortOrder { newest, oldest }

class OrderFilter extends Equatable {
  final List<String> status;
  final String? tableNumber;
  final SortOrder sortOrder;

  const OrderFilter({
    this.status = const [],
    this.tableNumber,
    this.sortOrder = SortOrder.newest,
  });

  OrderFilter copyWith({
    List<String>? status,
    String? tableNumber,
    SortOrder? sortOrder,
  }) {
    return OrderFilter(
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get isEmpty =>
      status.isEmpty && tableNumber == null && sortOrder == SortOrder.newest;

  @override
  List<Object?> get props => [status, tableNumber, sortOrder];
}
