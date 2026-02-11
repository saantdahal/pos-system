import 'package:equatable/equatable.dart';
import '../../data/models/order_item.dart';
import 'order_filter.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderEvent {}

class LoadMoreOrders extends OrderEvent {}

class AddOrder extends OrderEvent {
  final Order order;

  const AddOrder(this.order);

  @override
  List<Object> get props => [order];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatus(this.orderId, this.status);

  @override
  List<Object> get props => [orderId, status];
}

class UpdateFilter extends OrderEvent {
  final OrderFilter filter;

  const UpdateFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class NegotiateOrder extends OrderEvent {
  final String orderId;
  final List<Map<String, dynamic>> items;

  const NegotiateOrder(this.orderId, this.items);

  @override
  List<Object> get props => [orderId, items];
}
