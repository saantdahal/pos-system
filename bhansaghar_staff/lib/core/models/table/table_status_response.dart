import 'package:equatable/equatable.dart';

/// Table status enum matching backend choices
enum TableStatusEnum { available, occupied, ready, serving, dirty }

extension TableStatusEnumExtension on TableStatusEnum {
  /// Convert string from API to enum
  static TableStatusEnum fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return TableStatusEnum.available;
      case 'occupied':
        return TableStatusEnum.occupied;
      case 'ready':
        return TableStatusEnum.ready;
      case 'serving':
        return TableStatusEnum.serving;
      case 'dirty':
        return TableStatusEnum.dirty;
      default:
        return TableStatusEnum.available;
    }
  }

  String toDisplayString() {
    switch (this) {
      case TableStatusEnum.available:
        return '🟢 Available';
      case TableStatusEnum.occupied:
        return '🟡 Occupied';
      case TableStatusEnum.ready:
        return '🔵 Ready';
      case TableStatusEnum.serving:
        return '🟠 Serving';
      case TableStatusEnum.dirty:
        return '🔴 Dirty';
    }
  }

  String get colorHex {
    switch (this) {
      case TableStatusEnum.available:
        return '#4CAF50'; // Green
      case TableStatusEnum.occupied:
        return '#FFC107'; // Amber
      case TableStatusEnum.ready:
        return '#2196F3'; // Blue
      case TableStatusEnum.serving:
        return '#FF9800'; // Orange
      case TableStatusEnum.dirty:
        return '#F44336'; // Red
    }
  }
}

/// Response model from waiter API endpoint: GET /api/waiter/tables/
class TableStatusResponse extends Equatable {
  final int number;
  final TableStatusEnum status;
  final int capacity;
  final String? notes;
  final int readyOrdersCount;

  const TableStatusResponse({
    required this.number,
    required this.status,
    required this.capacity,
    this.notes,
    this.readyOrdersCount = 0,
  });

  /// Parse from backend API response
  factory TableStatusResponse.fromJson(Map<String, dynamic> json) {
    return TableStatusResponse(
      number: json['number'] as int,
      status: TableStatusEnumExtension.fromString(
        json['status'] as String? ?? 'available',
      ),
      capacity: json['capacity'] as int,
      notes: json['notes'] as String?,
      readyOrdersCount: json['ready_orders_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'status': status.name,
      'capacity': capacity,
      'notes': notes,
      'ready_orders_count': readyOrdersCount,
    };
  }

  @override
  List<Object?> get props => [
    number,
    status,
    capacity,
    notes,
    readyOrdersCount,
  ];
}
