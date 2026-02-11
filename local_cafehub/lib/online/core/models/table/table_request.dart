import 'package:equatable/equatable.dart';

class TableRequest extends Equatable {
  final int tableNumber;
  final bool? isActive;

  const TableRequest({required this.tableNumber, this.isActive});

  Map<String, dynamic> toJson() {
    return {
      'table_number': tableNumber,
      if (isActive != null) 'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [tableNumber, isActive];
}
