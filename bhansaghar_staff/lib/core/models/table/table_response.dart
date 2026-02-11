import 'package:equatable/equatable.dart';

class TableResponse extends Equatable {
  final String id;
  final String restaurant;
  final int tableNumber;
  final String? qrCode;
  final String? qrCodeUrl;
  final String qrCodeData;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TableResponse({
    required this.id,
    required this.restaurant,
    required this.tableNumber,
    this.qrCode,
    this.qrCodeUrl,
    required this.qrCodeData,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TableResponse.fromJson(Map<String, dynamic> json) {
    return TableResponse(
      id: json['id'] as String,
      restaurant: json['restaurant'] as String,
      tableNumber: json['table_number'] as int,
      qrCode: json['qr_code'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      qrCodeData: json['qr_code_data'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant': restaurant,
      'table_number': tableNumber,
      'qr_code': qrCode,
      'qr_code_url': qrCodeUrl,
      'qr_code_data': qrCodeData,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    restaurant,
    tableNumber,
    qrCode,
    qrCodeUrl,
    qrCodeData,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class BulkTableResponse extends Equatable {
  final bool success;
  final String message;
  final List<TableResponse> tables;

  const BulkTableResponse({
    required this.success,
    required this.message,
    required this.tables,
  });

  factory BulkTableResponse.fromJson(Map<String, dynamic> json) {
    return BulkTableResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      tables: (json['tables'] as List<dynamic>)
          .map((item) => TableResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [success, message, tables];
}

class RegenerateQRResponse extends Equatable {
  final bool success;
  final String message;
  final TableResponse table;

  const RegenerateQRResponse({
    required this.success,
    required this.message,
    required this.table,
  });

  factory RegenerateQRResponse.fromJson(Map<String, dynamic> json) {
    return RegenerateQRResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      table: TableResponse.fromJson(json['table'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [success, message, table];
}
