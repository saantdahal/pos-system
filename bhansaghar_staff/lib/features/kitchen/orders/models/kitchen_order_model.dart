import 'package:equatable/equatable.dart';

class KitchenOrder extends Equatable {
  final String id;
  final String restaurantId;
  final int tableNumber;
  final String status;
  final List<KitchenOrderItem> items;
  final String customerNotes;
  final DateTime createdAt;
  final List<OrderBargain> bargains;

  const KitchenOrder({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.status,
    required this.items,
    required this.customerNotes,
    required this.createdAt,
    this.bargains = const [],
  });

  factory KitchenOrder.fromJson(Map<String, dynamic> json) {
    return KitchenOrder(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant']?.toString() ?? '',
      tableNumber: int.tryParse(json['table_number'].toString()) ?? 0,
      status: json['status'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => KitchenOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      customerNotes: json['customer_notes'] ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      bargains:
          (json['bargains'] as List<dynamic>?)
              ?.map((e) => OrderBargain.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object> get props => [
    id,
    restaurantId,
    tableNumber,
    status,
    items,
    customerNotes,
    createdAt,
    bargains,
  ];
}

class KitchenOrderItem extends Equatable {
  final int itemId;
  final String name; // Added name for UI convenience
  final int qty;
  final double price;
  final String notes;

  const KitchenOrderItem({
    required this.itemId,
    required this.name,
    required this.qty,
    required this.price,
    this.notes = '',
  });

  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) {
    return KitchenOrderItem(
      itemId: int.tryParse(json['item_id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown Item',
      qty: int.tryParse(json['qty'].toString()) ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
    );
  }

  @override
  List<Object> get props => [itemId, name, qty, price, notes];
}

class OrderBargain extends Equatable {
  final String id;
  final int itemId;
  final int customerQty;
  final int kitchenQty;
  final String kitchenMessage;
  final String status;
  final String customerResponse;

  const OrderBargain({
    required this.id,
    required this.itemId,
    required this.customerQty,
    required this.kitchenQty,
    required this.kitchenMessage,
    required this.status,
    required this.customerResponse,
  });

  factory OrderBargain.fromJson(Map<String, dynamic> json) {
    return OrderBargain(
      id: json['id']?.toString() ?? '',
      itemId: int.tryParse(json['item_id'].toString()) ?? 0,
      customerQty: int.tryParse(json['customer_qty'].toString()) ?? 0,
      kitchenQty: int.tryParse(json['kitchen_qty'].toString()) ?? 0,
      kitchenMessage: json['kitchen_message'] ?? '',
      status: json['status'] ?? 'pending',
      customerResponse: json['customer_response'] ?? '',
    );
  }

  @override
  List<Object> get props => [
    id,
    itemId,
    customerQty,
    kitchenQty,
    kitchenMessage,
    status,
    customerResponse,
  ];
}
