import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameEn;

  @HiveField(2)
  final String nameNe;

  Category({required this.id, required this.nameEn, required this.nameNe});

  /// Get localized name based on language code
  String getLocalizedName(String languageCode) {
    return languageCode == 'ne' ? nameNe : nameEn;
  }

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
