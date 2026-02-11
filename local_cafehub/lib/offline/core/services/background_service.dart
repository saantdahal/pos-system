import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bhansa_ghar/offline/core/services/notification_service.dart';
import 'package:bhansa_ghar/offline/server/server_service.dart';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'dart:ui'; // For Locale
import 'package:bhansa_ghar/offline/ui/feature/categories/data/models/category.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/domain/repositories/category_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/data/menu_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/domain/menu_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/domain/repositories/order_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/data/models/table.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/domain/repositories/table_repository.dart';

@pragma('vm:entry-point')
class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Initialize notification service first to create the channel
    final notificationService = NotificationService();
    await notificationService.initialize();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // This will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: false,
        isForegroundMode: true,

        notificationChannelId: 'server_status',
        // Remove initial notification to prevent showing when service is just configured
        // initialNotificationTitle: 'Bhansa Ghar Server Service',
        // initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: 999,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter_background_service: ^4.5.0
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Initialize Local Notifications for the background isolate
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidConfig = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidConfig);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Create the notification channel in the background isolate as well
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'server_status', // id
      'Server Status', // title
      description: 'Notifications for server running status', // description
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_notifications', // id
      'Order Notifications', // title
      description: 'Notifications for new orders', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
      await androidImplementation.createNotificationChannel(orderChannel);
    }

    // Initialize Hive in this isolate
    await Hive.initFlutter();
    Hive.registerAdapter(MenuItemAdapter());
    Hive.registerAdapter(OrderItemAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TableModelAdapter());
    await Hive.openBox<bool>('menus');
    // We don't need auth box here for server operations usually, but good to know

    // Initialize Repositories
    final menuRepository = MenuRepository();
    final categoryRepository = CategoryRepository();
    final tableRepository = TableRepository();
    final orderRepository = OrderRepository();

    // Initialize Preferences Service
    final preferencesService = PreferencesService();
    await preferencesService.initialize();

    // Initialize Server Service (without NotificationService - it can't run in background isolate)
    final serverService = ServerService(
      menuRepository: menuRepository,
      categoryRepository: categoryRepository,
      tableRepository: tableRepository,
      orderRepository: orderRepository,
      notificationService:
          null, // Pass null - we'll handle notifications via events
      localizationBloc: null,
      preferencesService: preferencesService,
      onOrderReceived: (order) async {
        final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // Clean table number
        String tableNumber = order.tableNumber ?? "Unknown";
        if (tableNumber.trim().toLowerCase().startsWith('table')) {
          tableNumber = tableNumber.replaceAll(
            RegExp(r'^Table\s*', caseSensitive: false),
            '',
          );
        }

        // Format items
        final itemsList = order.items
            .map((item) => '${item.quantity}x ${item.name}')
            .join(', ');

        // Localize using PreferencesService
        final locale = Locale(preferencesService.languageCode);
        final localizations = lookupAppLocalizations(locale);

        final title = localizations.newOrderReceived;
        final body = localizations.newOrderAnnouncement(tableNumber, itemsList);

        // Send notification event to UI when order is received
        // Include the order ID so the UI can reload properly
        service.invoke('order_notification', {
          'id': notificationId,
          'title': title,
          'body': body,
          'orderId': order.id,
        });

        // Show notification directly from background isolate
        try {
          await flutterLocalNotificationsPlugin.show(
            notificationId,
            title,
            body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'order_notifications',
                'Order Notifications',
                channelDescription: 'Notifications for new orders',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: true,
                playSound: true,
                fullScreenIntent: true,
                visibility: NotificationVisibility.public,
              ),
            ),
          );
        } catch (e) {
          debugPrint(
            '[BackgroundService] Error showing direct notification: $e',
          );
        }
      },
      onOrderUpdated: (order) async {
        String title = 'Order Updated';
        String body = 'Order ${order.id} updated';

        if (order.status == 'Cancelled') {
          title = 'Order Cancelled';
          body = 'Order ${order.id} was rejected/cancelled by user';
        } else if (order.status == 'Received') {
          // If it was previously needs confirmation (we can't easily know here without state,
          // but 'Received' update usually implies confirmation if it comes from the confirm endpoint)
          title = 'Order Confirmed';
          body = 'Order ${order.id} was accepted by user';
        }

        service.invoke('order_notification', {
          'id': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'title': title,
          'body': body,
          'orderId': order.id,
        });
      },
    );

    service.on('start_server').listen((event) async {
      debugPrint('[BackgroundService] Received start_server event');
      try {
        await serverService.start();

        // Update the foreground service notification using LocalNotifications to ensure it's sticky
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            await flutterLocalNotificationsPlugin.show(
              999,
              'Bhansa Ghar Server is running',
              'Tap to open admin panel or stop the server.',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'server_status',
                  'Server Status',
                  channelDescription: 'Notifications for server running status',
                  importance: Importance.low,
                  priority: Priority.low,
                  ongoing: true,
                  autoCancel: false,
                  showWhen: false,
                ),
              ),
            );
          }
        }

        // Send server info back to UI
        service.invoke('server_started', {
          'host': serverService.host,
          'port': serverService.port,
        });
      } catch (e) {
        debugPrint('[BackgroundService] Error starting server: $e');
      }
    });

    service.on('get_server_status').listen((event) {
      if (serverService.isRunning) {
        service.invoke('server_started', {
          'host': serverService.host,
          'port': serverService.port,
        });
      } else {
        service.invoke('server_stopped');
      }
    });

    service.on('stop_server').listen((event) async {
      await serverService.stop();

      // Send event to UI to cancel notification
      service.invoke('cancel_notification', {'id': 999});

      service.invoke('server_stopped');
      service.stopSelf();
    });

    // Bring to foreground
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    // Signal that the service is ready
    service.invoke('service_ready');
  }
}
