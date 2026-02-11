import 'package:equatable/equatable.dart';

class TableModel extends Equatable {
  final String id;
  final String restaurant;
  final int tableNumber;
  final String? qrCode;
  final String? qrCodeUrl;
  final String qrCodeData;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TableModel({
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

  factory TableModel.fromResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return TableModel(
        id: response['id'] as String,
        restaurant: response['restaurant'] as String? ?? '',
        tableNumber: response['number'] as int? ?? 0,
        qrCode: response['qr_code'] as String?,
        qrCodeUrl: response['qr_code_url'] as String?,
        qrCodeData: response['qr_code_data'] as String? ?? '',
        isActive: response['is_active'] as bool? ?? true,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : DateTime.now(),
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'] as String)
            : DateTime.now(),
      );
    }
    throw ArgumentError('Invalid response type');
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

  TableModel copyWith({
    String? id,
    String? restaurant,
    int? tableNumber,
    String? qrCode,
    String? qrCodeUrl,
    String? qrCodeData,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      restaurant: restaurant ?? this.restaurant,
      tableNumber: tableNumber ?? this.tableNumber,
      qrCode: qrCode ?? this.qrCode,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
