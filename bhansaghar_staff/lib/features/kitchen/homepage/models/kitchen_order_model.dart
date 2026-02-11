import 'package:equatable/equatable.dart';

enum OrderType { dineIn, takeaway, delivery }

enum OrderStatus { pending, prep, ready, completed }

class OrderItem extends Equatable {
  final String name;
  final int quantity;
  final String? specialInstructions;

  const OrderItem({
    required this.name,
    required this.quantity,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [name, quantity, specialInstructions];
}

class KitchenOrder extends Equatable {
  final String orderId;
  final OrderType orderType;
  final OrderStatus status;
  final String location;
  final DateTime createdAt;
  final List<OrderItem> items;
  final int timeElapsedSeconds;
  final String chefName;

  const KitchenOrder({
    required this.orderId,
    required this.orderType,
    required this.status,
    required this.location,
    required this.createdAt,
    required this.items,
    required this.timeElapsedSeconds,
    required this.chefName,
  });

  String get orderTypeLabel {
    switch (orderType) {
      case OrderType.dineIn:
        return 'DINE-IN';
      case OrderType.takeaway:
        return 'TAKEAWAY';
      case OrderType.delivery:
        return 'DELIVERY';
    }
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.prep:
        return 'PREP';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.completed:
        return 'COMPLETED';
    }
  }

  @override
  List<Object> get props => [
    orderId,
    orderType,
    status,
    location,
    createdAt,
    items,
    timeElapsedSeconds,
    chefName,
  ];
}
