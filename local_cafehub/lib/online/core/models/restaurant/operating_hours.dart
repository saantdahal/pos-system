import 'package:json_annotation/json_annotation.dart';

part 'operating_hours.g.dart';

/// Represents a restaurant's operating hours including regular schedule and closures
@JsonSerializable(explicitToJson: true)
class OperatingHours {
  /// Regular weekly schedule (Monday-Sunday)
  final Map<String, DaySchedule?>? regularHours;

  /// Special closures with date ranges and notes
  final List<SpecialClosure>? specialClosures;

  OperatingHours({this.regularHours, this.specialClosures});

  factory OperatingHours.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursFromJson(json);

  Map<String, dynamic> toJson() => _$OperatingHoursToJson(this);

  /// Create empty operating hours
  factory OperatingHours.empty() {
    return OperatingHours(
      regularHours: {
        'monday': null,
        'tuesday': null,
        'wednesday': null,
        'thursday': null,
        'friday': null,
        'saturday': null,
        'sunday': null,
      },
      specialClosures: [],
    );
  }
}

/// Represents opening hours for a single day
@JsonSerializable()
class DaySchedule {
  /// Whether the restaurant is closed on this day
  final bool isClosed;

  /// Opening time (24-hour format, e.g., "09:00")
  final String? openTime;

  /// Closing time (24-hour format, e.g., "22:00")
  final String? closeTime;

  DaySchedule({required this.isClosed, this.openTime, this.closeTime});

  factory DaySchedule.fromJson(Map<String, dynamic> json) =>
      _$DayScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$DayScheduleToJson(this);

  /// Create a closed day
  factory DaySchedule.closed() {
    return DaySchedule(isClosed: true);
  }

  /// Create an open day with times
  factory DaySchedule.open(String openTime, String closeTime) {
    return DaySchedule(
      isClosed: false,
      openTime: openTime,
      closeTime: closeTime,
    );
  }
}

/// Represents a special closure period (holidays, renovations, etc.)
@JsonSerializable()
class SpecialClosure {
  /// Start date of closure (ISO 8601 format)
  final String startDate;

  /// End date of closure (ISO 8601 format)
  final String endDate;

  /// Reason for closure
  final String note;

  SpecialClosure({
    required this.startDate,
    required this.endDate,
    required this.note,
  });

  factory SpecialClosure.fromJson(Map<String, dynamic> json) =>
      _$SpecialClosureFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialClosureToJson(this);
}
