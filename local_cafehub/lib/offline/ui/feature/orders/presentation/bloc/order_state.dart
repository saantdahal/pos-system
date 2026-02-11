import 'package:equatable/equatable.dart';
import '../../data/models/order_item.dart';
import 'order_filter.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState extends Equatable {
  final OrderStatus status;
  final List<Order> orders;
  final List<Order> filteredOrders;
  final List<Order> allFilteredOrders;
  final OrderFilter filter;
  final int pageLimit;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.filteredOrders = const [],
    this.allFilteredOrders = const [],
    this.filter = const OrderFilter(),
    this.pageLimit = 5,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatus? status,
    List<Order>? orders,
    List<Order>? filteredOrders,
    List<Order>? allFilteredOrders,
    OrderFilter? filter,
    int? pageLimit,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      allFilteredOrders: allFilteredOrders ?? this.allFilteredOrders,
      filter: filter ?? this.filter,
      pageLimit: pageLimit ?? this.pageLimit,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    filteredOrders,
    allFilteredOrders,
    filter,
    pageLimit,
    errorMessage,
  ];
}
