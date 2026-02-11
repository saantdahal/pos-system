// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuItemAdapter extends TypeAdapter<MenuItem> {
  @override
  final int typeId = 0;

  @override
  MenuItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItem(
      id: fields[0] as String,
      nameEn: fields[1] as String,
      nameNe: fields[2] as String,
      price: fields[3] as double,
      category: fields[4] as String,
      isAvailable: fields[5] as bool,
      imageUrl: fields[6] as String,
      availableQuantity: fields[7] as int?,
      lowStockThreshold: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameEn)
      ..writeByte(2)
      ..write(obj.nameNe)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.isAvailable)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.availableQuantity)
      ..writeByte(8)
      ..write(obj.lowStockThreshold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameNe: json['nameNe'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '',
      availableQuantity: (json['availableQuantity'] as num?)?.toInt(),
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameNe': instance.nameNe,
      'price': instance.price,
      'category': instance.category,
      'isAvailable': instance.isAvailable,
      'imageUrl': instance.imageUrl,
      'availableQuantity': instance.availableQuantity,
      'lowStockThreshold': instance.lowStockThreshold,
    };
