import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels explicitly
    await _createNotificationChannels();

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Create server status channel for background service
      const serverStatusChannel = AndroidNotificationChannel(
        'server_status',
        'Server Status',
        description: 'Notifications for server running status',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );

      await androidImplementation.createNotificationChannel(
        serverStatusChannel,
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Request permissions for iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request permissions for Android 13+
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();

      // Check if exact alarms are allowed (Android 12+)
      // Note: This might open system settings if not allowed
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screen here
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Check if the date is in the future
      if (scheduledDate.isBefore(DateTime.now())) {
        return;
      }

      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.UTC);

      const androidDetails = AndroidNotificationDetails(
        'todo_reminders',
        'Todo Reminders',
        channelDescription: 'Notifications for todo reminders',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        // These settings help ensure notification shows even when app is closed
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        ongoing: false,
        autoCancel: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Error scheduling notification
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'order_notifications',
        'Order Notifications',
        channelDescription: 'Notifications for new orders',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details);
    } catch (e) {
      // Error showing notification
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> showPermanentNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'server_status',
        'Server Status',
        channelDescription: 'Persistent notification for server status',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );

      const details = NotificationDetails(android: androidDetails);

      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.startForegroundService(
          id,
          title,
          body,
          notificationDetails: androidDetails,
          payload: 'server_status',
          foregroundServiceTypes: {
            AndroidServiceForegroundType.foregroundServiceTypeDataSync,
          },
        );
      } else {
        // Fallback for iOS or if android implementation is null
        await _notifications.show(id, title, body, details);
      }
    } catch (e) {
      debugPrint('Error showing permanent notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);

      // If this was the server notification, stop the foreground service
      if (id == 999) {
        final androidImplementation = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidImplementation?.stopForegroundService();
      }
    } catch (e) {
      // Error cancelling notification
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      // Error cancelling all notifications
    }
  }

  Future<void> printPendingNotifications() async {
    try {
      await _notifications.pendingNotificationRequests();
      // Method kept for backward compatibility
    } catch (e) {
      // Error getting pending notifications
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Method to reschedule all notifications (call after boot)
  Future<void> rescheduleAllNotifications(
    List<Map<String, dynamic>> todos,
  ) async {
    for (var i = 0; i < todos.length; i++) {
      final todo = todos[i];
      final reminderDateTime = todo['reminderDateTime'] as DateTime?;

      if (reminderDateTime != null &&
          reminderDateTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: i,
          title: 'Reminder: ${todo['taskName']}',
          body: 'Don\'t forget to complete this task!',
          scheduledDate: reminderDateTime,
        );
      }
    }
  }
}
