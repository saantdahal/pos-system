import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:bhansa_ghar/offline/ui/feature/orders/data/models/order_item.dart';

class OrderRepository {
  static const String _boxName = 'orders';

  final _orderController = StreamController<Order>.broadcast();
  Stream<Order> get onOrderAdded => _orderController.stream;

  bool _isGettingOrders = false;

  Future<List<Order>> getOrders() async {
    // Simple mutex to prevent race conditions when multiple calls try to close/reopen the box
    if (_isGettingOrders) {
      while (_isGettingOrders) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    _isGettingOrders = true;

    try {
      // Close the box if it's open to force reload from disk
      // This is necessary because Hive boxes in different isolates don't share in-memory data
      if (Hive.isBoxOpen(_boxName)) {
        await Hive.box<Order>(_boxName).close();
      }

      // Reopen the box to get fresh data from disk
      final box = await Hive.openBox<Order>(_boxName);
      final orders = box.values.toList();
      // Sort by newest first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      debugPrint('[OrderRepository] Error loading orders: $e');
      return [];
    } finally {
      _isGettingOrders = false;
    }
  }

  Future<Order?> getOrder(String id) async {
    try {
      final box = await Hive.openBox<Order>(_boxName);
      return box.get(id);
    } catch (e) {
      debugPrint('[OrderRepository] Error getting order $id: $e');
      return null;
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      final box = await Hive.openBox<Order>(_boxName);
      await box.put(order.id, order);
      _orderController.add(order);
    } catch (e) {
      debugPrint('[OrderRepository] Error adding order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      debugPrint('[OrderRepository] Updating order $orderId status to $status');
      final box = await Hive.openBox<Order>(_boxName);
      final order = box.get(orderId);

      if (order != null) {
        final updatedOrder = Order(
          id: order.id,
          items: order.items,
          status: status,
          createdAt: order.createdAt,
          tableNumber: order.tableNumber,
          customerName: order.customerName,
          totalPrice: order.totalPrice,
          notes: order.notes,
        );

        await box.put(orderId, updatedOrder);
        _orderController.add(updatedOrder);
      } else {
        debugPrint('[OrderRepository] Order $orderId not found');
      }
    } catch (e) {
      debugPrint('[OrderRepository] Error updating order status: $e');
      rethrow;
    }
  }

  Future<void> clearAllOrders() async {
    try {
      final box = await Hive.openBox<Order>(_boxName);
      await box.clear();
    } catch (e) {
      debugPrint('[OrderRepository] Error clearing orders: $e');
      rethrow;
    }
  }

  Future<void> negotiateOrder(
    String orderId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final box = await Hive.openBox<Order>(_boxName);
      final order = box.get(orderId);

      if (order != null) {
        // Create a map of updates for easier lookup
        final updates = {
          for (var item in items)
            item['id'] as String: item['proposedQuantity'] as int?,
        };

        // Create updated items list
        final updatedItems = order.items.map((item) {
          if (updates.containsKey(item.id)) {
            final proposedQty = updates[item.id];
            // If proposed quantity matches original, clear the proposal
            // If it's different, set it
            return OrderItem(
              id: item.id,
              menuItemId: item.menuItemId,
              quantity: item.quantity,
              notes: item.notes,
              name: item.name,
              price: item.price,
              proposedQuantity: proposedQty,
            );
          }
          return item;
        }).toList();

        // Calculate new total based on proposed quantities where available, or original otherwise
        // meaningful for the admin to see the potential new total
        double newTotal = 0;
        for (var item in updatedItems) {
          final qty = item.proposedQuantity ?? item.quantity;
          newTotal += item.price * qty;
        }

        final updatedOrder = Order(
          id: order.id,
          items: updatedItems,
          status:
              'Needs Confirmation', // Set status to trigger negotiation UI on web
          createdAt: order.createdAt,
          tableNumber: order.tableNumber,
          customerName: order.customerName,
          totalPrice: newTotal, // Update total to reflect proposal
          notes: order.notes,
        );

        await box.put(orderId, updatedOrder);
        _orderController.add(updatedOrder);
      } else {
        debugPrint(
          '[OrderRepository] Order $orderId not found for negotiation',
        );
      }
    } catch (e) {
      debugPrint('[OrderRepository] Error negotiating order: $e');
      rethrow;
    }
  }

  void dispose() {
    _orderController.close();
  }
}
