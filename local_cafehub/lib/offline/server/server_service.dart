import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'package:bhansa_ghar/offline/ui/feature/categories/domain/repositories/category_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/domain/menu_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/domain/repositories/table_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/domain/repositories/order_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';
import 'package:bhansa_ghar/offline/core/services/notification_service.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'api_router.dart';
import 'websocket_handler.dart';

class ServerService {
  HttpServer? _server;
  final int _port = 8080;
  final MenuRepository _menuRepository;
  final CategoryRepository _categoryRepository;
  final TableRepository _tableRepository;
  final OrderRepository _orderRepository;
  final NotificationService? _notificationService;
  final LocalizationBloc? _localizationBloc;
  final PreferencesService? _preferencesService;
  final Function(Order)? onOrderReceived;
  final Function(Order)? onOrderUpdated;
  String _host = 'Unknown';

  ServerService({
    required MenuRepository menuRepository,
    required CategoryRepository categoryRepository,
    required TableRepository tableRepository,
    required OrderRepository orderRepository,
    required NotificationService? notificationService,
    required LocalizationBloc? localizationBloc,
    required PreferencesService? preferencesService,
    this.onOrderReceived,
    this.onOrderUpdated,
  }) : _menuRepository = menuRepository,
       _categoryRepository = categoryRepository,
       _tableRepository = tableRepository,
       _orderRepository = orderRepository,
       _notificationService = notificationService,
       _localizationBloc = localizationBloc,
       _preferencesService = preferencesService;

  bool get isRunning => _server != null;
  String get host => _host;
  int get port => _server?.port ?? 0;

  Future<void> start() async {
    if (_server != null) return;

    // Get actual IP address
    final info = NetworkInfo();
    _host = await info.getWifiIP() ?? 'localhost';

    final router = Router();

    // WebSocket Endpoint
    final wsHandler = WebSocketHandler();
    router.get('/ws', wsHandler.handler);

    // API Endpoints
    final apiRouter = ApiRouter(
      menuRepository: _menuRepository,
      categoryRepository: _categoryRepository,
      tableRepository: _tableRepository,
      orderRepository: _orderRepository,
      notificationService: _notificationService,
      localizationBloc: _localizationBloc,
      preferencesService: _preferencesService,
      onOrderReceived: onOrderReceived,
      onOrderUpdated: (order) {
        // Broadcast update via WebSocket
        wsHandler.broadcast(
          jsonEncode({
            'type': 'status_update',
            'orderId': order.id,
            'status': order.status,
            'items': order.items.map((e) => e.toJson()).toList(),
            'total': order.totalPrice,
          }),
        );

        // Call original callback
        onOrderUpdated?.call(order);
      },
    );
    router.mount('/api', apiRouter.router.call);

    // Serve static files
    final staticPath = await _prepareStaticFiles();
    if (staticPath != null) {
      router.mount(
        '/',
        createStaticHandler(
          staticPath,
          defaultDocument: 'index.html',
          useHeaderBytesForContentType: true,
        ),
      );
    }

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware()) // Add CORS middleware globally
        .addHandler(router.call);

    // Bind to any IPv4 address to be accessible on the network
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, _port);

    // Show persistent notification (only if notification service is available)
    await _notificationService?.showPermanentNotification(
      id: 999, // Fixed ID for server status
      title: 'Bhansa Ghar Server Running',
      body: 'Server is active on $_host:$_port',
    );
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _host = 'Unknown';

    // Cancel persistent notification (only if notification service is available)
    await _notificationService?.cancelNotification(999);

    // Clear all orders when server stops
    await _orderRepository.clearAllOrders();
  }

  // Copy assets to a temporary directory to serve them
  Future<String?> _prepareStaticFiles() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final webDir = Directory('${docDir.path}/web');

      if (!webDir.existsSync()) {
        webDir.createSync(recursive: true);
      }

      // List of files to copy (must match what's in assets/web)
      final files = ['index.html', 'app.js', 'style.css'];

      for (final file in files) {
        final data = await rootBundle.load('assets/web/$file');
        final bytes = data.buffer.asUint8List();
        await File('${webDir.path}/$file').writeAsBytes(bytes, flush: true);
      }

      return webDir.path;
    } catch (e) {
      debugPrint('Error preparing static files: $e');
      return null;
    }
  }

  Middleware _corsMiddleware() {
    return (innerHandler) {
      return (request) async {
        final response = await innerHandler(request);
        return response.change(
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type',
          },
        );
      };
    };
  }
}
