import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'table_model.g.dart';

enum TableStatus {
  available, // Green
  occupied, // Orange
  ready, // Blue
  serving, // Orange (serving)
  dirty, // Red
}

@JsonSerializable()
class WaiterTable extends Equatable {
  final int id;
  final String name;
  final TableStatus status;
  final int capacity;
  @JsonKey(name: 'restaurant_name')
  final String restaurantName;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;

  const WaiterTable({
    required this.id,
    required this.name,
    required this.status,
    required this.capacity,
    required this.restaurantName,
    this.lastUpdated,
  });

  factory WaiterTable.fromJson(Map<String, dynamic> json) =>
      _$WaiterTableFromJson(json);

  Map<String, dynamic> toJson() => _$WaiterTableToJson(this);

  WaiterTable copyWith({
    int? id,
    String? name,
    TableStatus? status,
    int? capacity,
    String? restaurantName,
    DateTime? lastUpdated,
  }) {
    return WaiterTable(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      restaurantName: restaurantName ?? this.restaurantName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    capacity,
    restaurantName,
    lastUpdated,
  ];
}
