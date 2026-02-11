import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'table.g.dart';

@JsonSerializable()
@HiveType(typeId: 10)
class TableModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int tableNumber;

  @HiveField(2)
  final bool isOccupied;

  TableModel({
    required this.id,
    required this.tableNumber,
    this.isOccupied = false,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  TableModel copyWith({String? id, int? tableNumber, bool? isOccupied}) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }
}
