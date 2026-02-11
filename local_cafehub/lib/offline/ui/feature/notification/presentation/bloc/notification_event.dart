import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {}

class ClearNotification extends NotificationEvent {
  final String notificationId;

  const ClearNotification(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class ClearAllNotifications extends NotificationEvent {}

class NewOrderNotification extends NotificationEvent {
  final Order order;

  const NewOrderNotification(this.order);

  @override
  List<Object> get props => [order];
}

class ServerNotificationReceived extends NotificationEvent {
  final String title;
  final String body;
  final String? orderId;

  const ServerNotificationReceived({
    required this.title,
    required this.body,
    this.orderId,
  });

  @override
  List<Object?> get props => [title, body, orderId];
}
