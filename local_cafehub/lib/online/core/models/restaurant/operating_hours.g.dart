// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operating_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperatingHours _$OperatingHoursFromJson(Map<String, dynamic> json) =>
    OperatingHours(
      regularHours: (json['regularHours'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k,
            e == null ? null : DaySchedule.fromJson(e as Map<String, dynamic>)),
      ),
      specialClosures: (json['specialClosures'] as List<dynamic>?)
          ?.map((e) => SpecialClosure.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OperatingHoursToJson(OperatingHours instance) =>
    <String, dynamic>{
      'regularHours':
          instance.regularHours?.map((k, e) => MapEntry(k, e?.toJson())),
      'specialClosures':
          instance.specialClosures?.map((e) => e.toJson()).toList(),
    };

DaySchedule _$DayScheduleFromJson(Map<String, dynamic> json) => DaySchedule(
      isClosed: json['isClosed'] as bool,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
    );

Map<String, dynamic> _$DayScheduleToJson(DaySchedule instance) =>
    <String, dynamic>{
      'isClosed': instance.isClosed,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
    };

SpecialClosure _$SpecialClosureFromJson(Map<String, dynamic> json) =>
    SpecialClosure(
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$SpecialClosureToJson(SpecialClosure instance) =>
    <String, dynamic>{
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'note': instance.note,
    };
