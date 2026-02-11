import 'dart:async';
import 'package:hive/hive.dart';
import 'package:bhansa_ghar/offline/ui/feature/notification/data/notification_model.dart';

class NotificationRepository {
  static const String _boxName = 'notifications';

  final _notificationController =
      StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get onNotificationsChanged =>
      _notificationController.stream;

  Future<Box<NotificationModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<NotificationModel>(_boxName);
    }
    return Hive.box<NotificationModel>(_boxName);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final box = await _getBox();
    final notifications = box.values.toList();
    // Sort by timestamp descending
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  Future<int> getUnreadCount() async {
    final box = await _getBox();
    return box.values.where((n) => !n.isRead).length;
  }

  Future<void> addNotification(NotificationModel notification) async {
    final box = await _getBox();
    await box.put(notification.id, notification);
    _notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final box = await _getBox();
    final notification = box.get(id);
    if (notification != null) {
      notification.isRead = true;
      await notification.save();
      _notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final box = await _getBox();
    for (var notification in box.values) {
      if (!notification.isRead) {
        notification.isRead = true;
        await notification.save();
      }
    }
    _notifyListeners();
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
    _notifyListeners();
  }

  Future<void> _notifyListeners() async {
    final notifications = await getNotifications();
    _notificationController.add(notifications);
  }

  void dispose() {
    _notificationController.close();
  }
}
