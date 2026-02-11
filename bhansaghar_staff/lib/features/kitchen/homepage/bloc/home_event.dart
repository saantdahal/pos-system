part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboard extends HomeEvent {}

class RefreshDashboard extends HomeEvent {}

class UpdateOrderStatus extends HomeEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatus({required this.orderId, required this.newStatus});

  @override
  List<Object> get props => [orderId, newStatus];
}
