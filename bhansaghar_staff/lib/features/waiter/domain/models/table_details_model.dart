class TableOrderModel {
  final int id;
  final String itemName;
  final int quantity;
  final String time;
  final String additionalInfo;
  final String status; // 'served', 'pending', 'preparing'
  final String? icon;

  TableOrderModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.time,
    required this.additionalInfo,
    required this.status,
    this.icon,
  });

  factory TableOrderModel.fromJson(Map<String, dynamic> json) {
    return TableOrderModel(
      id: json['id'] as int,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as int,
      time: json['time'] as String,
      additionalInfo: json['additional_info'] as String,
      status: json['status'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'quantity': quantity,
      'time': time,
      'additional_info': additionalInfo,
      'status': status,
      'icon': icon,
    };
  }
}

class TableDetailsModel {
  final int id;
  final int tableNumber;
  final int capacity;
  final String status; // 'available', 'occupied', 'reserved'
  final String? specialInstructions;
  final List<TableOrderModel> recentOrders;
  final bool hasLiveOrders;
  final DateTime createdAt;

  TableDetailsModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.specialInstructions,
    required this.recentOrders,
    required this.hasLiveOrders,
    required this.createdAt,
  });

  factory TableDetailsModel.fromJson(Map<String, dynamic> json) {
    final ordersList =
        (json['recent_orders'] as List?)
            ?.map(
              (order) =>
                  TableOrderModel.fromJson(order as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return TableDetailsModel(
      id: json['id'] as int,
      tableNumber: json['table_number'] as int,
      capacity: json['capacity'] as int,
      status: json['status'] as String,
      specialInstructions: json['special_instructions'] as String?,
      recentOrders: ordersList,
      hasLiveOrders: json['has_live_orders'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
      'special_instructions': specialInstructions,
      'recent_orders': recentOrders.map((order) => order.toJson()).toList(),
      'has_live_orders': hasLiveOrders,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TableDetailsModel copyWith({
    int? id,
    int? tableNumber,
    int? capacity,
    String? status,
    String? specialInstructions,
    List<TableOrderModel>? recentOrders,
    bool? hasLiveOrders,
    DateTime? createdAt,
  }) {
    return TableDetailsModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      recentOrders: recentOrders ?? this.recentOrders,
      hasLiveOrders: hasLiveOrders ?? this.hasLiveOrders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
