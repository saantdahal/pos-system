import 'package:equatable/equatable.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/models/kitchen_order_model.dart';

enum KitchenStatus { initial, loading, success, failure }

class KitchenOrdersState extends Equatable {
  final KitchenStatus status;
  final List<KitchenOrder> orders;
  final String? errorMessage;

  const KitchenOrdersState({
    this.status = KitchenStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  KitchenOrdersState copyWith({
    KitchenStatus? status,
    List<KitchenOrder>? orders,
    String? errorMessage,
  }) {
    return KitchenOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
