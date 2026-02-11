import 'package:hive/hive.dart';

part 'order_item.g.dart';

@HiveType(typeId: 1)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String menuItemId;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final String notes;

  @HiveField(4)
  final String name;

  @HiveField(5)
  final double price;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.quantity,
    this.notes = '',
    required this.name,
    required this.price,
    this.proposedQuantity,
  });

  @HiveField(6)
  final int? proposedQuantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'menuItemId': menuItemId,
    'quantity': quantity,
    'notes': notes,
    'name': name,
    'price': price,
    'proposedQuantity': proposedQuantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Item',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      proposedQuantity: json['proposedQuantity'] as int?,
    );
  }
}

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<OrderItem> items;

  @HiveField(2)
  final String status; // Received, Preparing, Ready, Completed, Cancelled, Needs Confirmation

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String? tableNumber;

  @HiveField(6)
  final String customerName;

  @HiveField(7)
  final double totalPrice;

  @HiveField(8)
  final List<String> notes;

  Order({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    this.tableNumber,
    required this.customerName,
    required this.totalPrice,
    this.notes = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((e) => e.toJson()).toList(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'tableNumber': tableNumber,
    'customerName': customerName,
    'totalPrice': totalPrice,
    'notes': notes,
  };
}
