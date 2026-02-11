import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'order_details_model.g.dart';

@JsonSerializable()
class OrderItemModel extends Equatable {
  final int id;
  final String name;
  final int quantity;
  final String status; // 'served', 'ready_for_pickup', 'preparing'
  final String? icon;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.status,
    this.icon,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  @override
  List<Object?> get props => [id, name, quantity, status, icon];

  OrderItemModel copyWith({
    int? id,
    String? name,
    int? quantity,
    String? status,
    String? icon,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      icon: icon ?? this.icon,
    );
  }
}

@JsonSerializable()
class OrderDetailsModel extends Equatable {
  final int id;
  @JsonKey(name: 'table_number')
  final int tableNumber;
  @JsonKey(name: 'table_name')
  final String tableName;
  final String status; // 'serving', 'completed', 'pending'
  final List<OrderItemModel> items;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'served_items')
  final int servedItems;
  @JsonKey(name: 'kitchen_notes')
  final String? kitchenNotes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const OrderDetailsModel({
    required this.id,
    required this.tableNumber,
    required this.tableName,
    required this.status,
    required this.items,
    required this.totalItems,
    required this.servedItems,
    this.kitchenNotes,
    required this.createdAt,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    tableNumber,
    tableName,
    status,
    items,
    totalItems,
    servedItems,
    kitchenNotes,
    createdAt,
  ];

  OrderDetailsModel copyWith({
    int? id,
    int? tableNumber,
    String? tableName,
    String? status,
    List<OrderItemModel>? items,
    int? totalItems,
    int? servedItems,
    String? kitchenNotes,
    DateTime? createdAt,
  }) {
    return OrderDetailsModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      tableName: tableName ?? this.tableName,
      status: status ?? this.status,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      servedItems: servedItems ?? this.servedItems,
      kitchenNotes: kitchenNotes ?? this.kitchenNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
