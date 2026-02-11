import 'package:equatable/equatable.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/table_model.dart';

abstract class WaiterDashboardState extends Equatable {
  const WaiterDashboardState();

  @override
  List<Object> get props => [];
}

class WaiterDashboardInitial extends WaiterDashboardState {
  const WaiterDashboardInitial();
}

class WaiterDashboardLoading extends WaiterDashboardState {
  const WaiterDashboardLoading();
}

class WaiterDashboardLoaded extends WaiterDashboardState {
  final List<WaiterTable> tables;
  final String restaurantName;

  const WaiterDashboardLoaded({
    required this.tables,
    required this.restaurantName,
  });

  WaiterDashboardLoaded copyWith({
    List<WaiterTable>? tables,
    String? restaurantName,
  }) {
    return WaiterDashboardLoaded(
      tables: tables ?? this.tables,
      restaurantName: restaurantName ?? this.restaurantName,
    );
  }

  @override
  List<Object> get props => [tables, restaurantName];
}

class WaiterDashboardError extends WaiterDashboardState {
  final String message;

  const WaiterDashboardError(this.message);

  @override
  List<Object> get props => [message];
}
