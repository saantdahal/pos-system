import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class MenuItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameEn;

  @HiveField(2)
  final String nameNe;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final bool isAvailable;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final int? availableQuantity;

  @HiveField(8)
  final int? lowStockThreshold;

  MenuItem({
    required this.id,
    required this.nameEn,
    required this.nameNe,
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.imageUrl = '',
    this.availableQuantity,
    this.lowStockThreshold,
  });

  /// Get localized name based on language code
  String getLocalizedName(String languageCode) {
    return languageCode == 'ne' ? nameNe : nameEn;
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
