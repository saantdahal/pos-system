import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 5)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final NotificationType type;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  final String? orderId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.orderId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? orderId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      orderId: orderId ?? this.orderId,
    );
  }
}

@HiveType(typeId: 6)
enum NotificationType {
  @HiveField(0)
  order,
  @HiveField(1)
  system,
  @HiveField(2)
  info,
  @HiveField(3)
  warning,
}
