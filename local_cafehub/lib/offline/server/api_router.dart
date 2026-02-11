import 'dart:ui';
import 'dart:convert';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';
import 'package:bhansa_ghar/offline/core/bloc/localization/localization_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/domain/repositories/order_repository.dart';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/domain/repositories/category_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/domain/menu_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/domain/repositories/table_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';
import 'package:bhansa_ghar/offline/core/services/notification_service.dart';

class ApiRouter {
  final MenuRepository _menuRepository;
  final CategoryRepository _categoryRepository;
  final TableRepository _tableRepository;
  final OrderRepository _orderRepository;
  final NotificationService? _notificationService;
  final LocalizationBloc? _localizationBloc;
  final PreferencesService? _preferencesService;
  final Function(Order)? onOrderReceived;
  final Function(Order)? onOrderUpdated;

  ApiRouter({
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

  Future<Response> _putOrderProposal(Request request, String id) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final proposedItems = (payload['items'] as List)
          .cast<Map<String, dynamic>>();

      final order = await _orderRepository.getOrder(id);
      if (order == null) {
        return Response.notFound('Order not found');
      }

      // 2. Update items with proposed quantities
      final updatedItems = order.items.map((item) {
        final proposal = proposedItems.firstWhere(
          (p) => p['id'] == item.id,
          orElse: () => {'proposedQuantity': null},
        );

        if (proposal['proposedQuantity'] != null) {
          return OrderItem(
            id: item.id,
            menuItemId: item.menuItemId,
            quantity: item.quantity,
            name: item.name,
            notes: item.notes,
            price: item.price,
            proposedQuantity: proposal['proposedQuantity'],
          );
        }
        return item;
      }).toList();

      // 3. Update Order Status
      final updatedOrder = Order(
        id: order.id,
        items: updatedItems,
        status: 'Needs Confirmation',
        createdAt: order.createdAt,
        tableNumber: order.tableNumber,
        customerName: order.customerName,
        totalPrice: order.totalPrice,
        notes: ['Admin proposed changes to this order.'],
      );

      await _orderRepository.addOrder(updatedOrder);

      // Notify clients
      onOrderUpdated?.call(updatedOrder);

      return Response.ok(
        jsonEncode({
          'status': 'Needs Confirmation',
          'order': updatedOrder.toJson(),
        }),
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error proposing order: $e');
    }
  }

  Router get router {
    final router = Router();

    router.get('/menu', _getMenu);
    router.get('/tables', _getTables);
    router.get('/images/<filename>', _getImage);
    router.post('/order', _postOrder);
    router.post('/order/<id>/confirm', _postOrderConfirm);
    router.put('/order/<id>/proposal', _putOrderProposal);
    router.get('/order/<id>/status', _getOrderStatus);

    return router;
  }

  Future<Response> _getMenu(Request request) async {
    try {
      final categories = await _categoryRepository.getCategories();
      final menuItems = await _menuRepository.getMenu();

      final categoriesData = categories.map((category) {
        final items = menuItems
            .where((item) {
              // Robust matching: check both ID and Name, case-insensitive
              final itemCat = item.category.trim().toLowerCase();
              final catId = category.id.trim().toLowerCase();
              final catNameEn = category.nameEn.trim().toLowerCase();

              final isMatch = itemCat == catId || itemCat == catNameEn;

              // Debug log for troubleshooting (optional, remove in production if spammy)
              if (!isMatch) {
                // print('No match: Item "${item.nameEn}" (cat: ${item.category}) vs Category "${category.nameEn}" (id: ${category.id})');
              }

              return isMatch;
            })
            .map((item) {
              // Convert local file path to HTTP URL
              String imageUrl = '';
              if (item.imageUrl.isNotEmpty) {
                // Extract filename from path like /data/.../cache/filename.jpg
                final filename = item.imageUrl.split('/').last;
                imageUrl = '/api/images/$filename';
              }

              return {
                'id': item.id,
                'name': item.nameEn,
                'price': item.price,
                'description':
                    '', // Add description field to MenuItem if needed
                'image': imageUrl,
              };
            })
            .toList();

        return {'id': category.id, 'name': category.nameEn, 'items': items};
      }).toList();

      return Response.ok(
        jsonEncode({'categories': categoriesData}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  Future<Response> _getTables(Request request) async {
    try {
      final tables = await _tableRepository.getTables();

      final tablesData = tables
          .map(
            (table) => {
              'id': table.id,
              'tableNumber': table.tableNumber,
              'isOccupied': table.isOccupied,
            },
          )
          .toList();

      return Response.ok(
        jsonEncode({'tables': tablesData}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  Future<Response> _postOrder(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // Fetch all menu items to look up prices and stock
      final menuItems = await _menuRepository.getMenu();
      final menuMap = {for (var item in menuItems) item.id: item};

      double totalOrderPrice = 0.0;
      List<String> notes = [];

      // Extract order data from web request
      final items = (data['items'] as List<dynamic>).map((item) {
        final menuItemId = item['id'] as String;
        final quantity = item['quantity'] as int;

        // Find price from menu items (Stock is now unlimited/ignored)
        final menuItem = menuMap[menuItemId];
        final price = menuItem?.price ?? 0.0;

        totalOrderPrice += price * quantity;

        return OrderItem(
          id: item['id'] as String,
          menuItemId: menuItemId,
          quantity: quantity,
          name: item['name'] as String,
          notes: '',
          price: price,
          proposedQuantity: null,
        );
      }).toList();

      // Always Received, no automatic stock check
      String status = 'Received';

      // No stock deduction needed as it's unlimited

      // Create order object
      final order = Order(
        id: data['id'] as String,
        items: items,
        status: status,
        createdAt: DateTime.now(),
        tableNumber: data['tableName'] as String?,
        customerName: 'Web Customer',
        totalPrice: totalOrderPrice,
      );

      // Save to order repository
      await _orderRepository.addOrder(order);

      // Trigger notification callback (for background service)
      onOrderReceived?.call(order);

      // Show notification for new order (only if notification service is available)
      final notificationService = _notificationService;
      if (notificationService != null) {
        // Get localization (default to English if bloc is not provided)
        Locale locale;
        if (_localizationBloc != null) {
          locale = _localizationBloc.state.locale;
        } else if (_preferencesService != null) {
          locale = Locale(_preferencesService.languageCode);
        } else {
          locale = const Locale('en');
        }

        final localizations = lookupAppLocalizations(locale);

        // Clean table number
        String tableNumber = order.tableNumber ?? localizations.unknownTable;
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

        await notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: localizations.newOrderReceived,
          body: localizations.newOrderAnnouncement(tableNumber, itemsList),
        );
      }

      return Response.ok(
        jsonEncode({
          'orderId': order.id,
          'status': order.status,
          'receivedAt': order.createdAt.toIso8601String(),
          'notes': notes,
        }),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  Future<Response> _postOrderConfirm(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final action = data['action'] as String; // 'confirm' or 'cancel'

      final order = await _orderRepository.getOrder(id);

      if (order == null) {
        return Response.notFound(
          jsonEncode({'error': 'Order not found'}),
          headers: {
            'content-type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      }

      if (action == 'cancel') {
        await _orderRepository.updateOrderStatus(id, 'Cancelled');

        // Add cancellation note
        final updatedNotes = List<String>.from(order.notes)
          ..add('Cancelled by user');
        // We need to save this note update. Since updateOrderStatus only updates status,
        // we might need to update the whole order or add a method for notes.
        // For now, let's just create the object with new notes for notification,
        // and ideally we should persist it.
        // Let's assume we want to persist it:
        final cancelledOrder = Order(
          id: order.id,
          items: order.items,
          status: 'Cancelled',
          createdAt: order.createdAt,
          tableNumber: order.tableNumber,
          customerName: order.customerName,
          totalPrice: order.totalPrice,
          notes: updatedNotes,
        );
        await _orderRepository.addOrder(
          cancelledOrder,
        ); // Overwrite with new notes

        onOrderUpdated?.call(cancelledOrder);

        return Response.ok(jsonEncode({'status': 'Cancelled'}));
      } else if (action == 'confirm') {
        // Update items with proposed quantities if any
        final updatedItems = order.items.map((item) {
          if (item.proposedQuantity != null) {
            return OrderItem(
              id: item.id,
              menuItemId: item.menuItemId,
              quantity: item.proposedQuantity!,
              name: item.name,
              notes: item.notes,
              price: item.price,
              proposedQuantity: null, // Clear proposal
            );
          }
          return item;
        }).toList();

        // Recalculate total price
        double newTotal = 0.0;
        for (var item in updatedItems) {
          newTotal += item.price * item.quantity;
        }

        // No stock deduction (Unlimited)

        final updatedOrder = Order(
          id: order.id,
          items: updatedItems,
          status: 'Received',
          createdAt: order.createdAt,
          tableNumber: order.tableNumber,
          customerName: order.customerName,
          totalPrice: newTotal,
          notes: order.notes,
        );

        await _orderRepository.addOrder(updatedOrder);

        // Notify update
        onOrderUpdated?.call(updatedOrder);

        return Response.ok(
          jsonEncode({
            'status': 'Received',
            'items': updatedItems.map((e) => e.toJson()).toList(),
            'total': newTotal,
          }),
          headers: {
            'content-type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } else {
        return Response.badRequest(body: 'Invalid action');
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  Future<Response> _getOrderStatus(Request request, String id) async {
    try {
      final orders = await _orderRepository.getOrders();
      final order = orders.cast<Order?>().firstWhere(
        (o) => o?.id == id,
        orElse: () => null,
      );

      if (order == null) {
        return Response.notFound(
          jsonEncode({'error': 'Order not found'}),
          headers: {
            'content-type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      }

      return Response.ok(
        jsonEncode({
          'orderId': order.id,
          'status': order.status,
          'createdAt': order.createdAt.toIso8601String(),
          'tableNumber': order.tableNumber,
          'items': order.items.map((e) => e.toJson()).toList(),
          'notes': order.notes,
          'total': order.totalPrice,
        }),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {
          'content-type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  Future<Response> _getImage(Request request, String filename) async {
    try {
      // Find the menu item with this image
      final menuItems = await _menuRepository.getMenu();
      final item = menuItems.firstWhere(
        (item) => item.imageUrl.endsWith(filename),
        orElse: () => throw Exception('Image not found'),
      );

      // Read the image file
      final file = File(item.imageUrl);
      if (!await file.exists()) {
        return Response.notFound('Image file not found');
      }

      final bytes = await file.readAsBytes();

      // Determine content type from extension
      String contentType = 'image/jpeg';
      if (filename.endsWith('.png')) {
        contentType = 'image/png';
      } else if (filename.endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (filename.endsWith('.webp')) {
        contentType = 'image/webp';
      }

      return Response.ok(
        bytes,
        headers: {
          'content-type': contentType,
          'Access-Control-Allow-Origin': '*',
          'Cache-Control': 'public, max-age=86400', // Cache for 24 hours
        },
      );
    } catch (e) {
      return Response.notFound('Image not found: ${e.toString()}');
    }
  }
}
