import 'package:bhansaghar_staff/core/api/api_client.dart';
import 'package:bhansaghar_staff/features/kitchen/orders/models/kitchen_order_model.dart';
import 'package:flutter/foundation.dart';

class KitchenRepository {
  final ApiClient _apiClient;

  KitchenRepository(this._apiClient);

  Future<List<KitchenOrder>> getLiveOrders() async {
    try {
      debugPrint('👨‍🍳 KITCHEN_REPO: Fetching live orders...');
      final response = await _apiClient.get('/orders/kitchen/orders/');
      debugPrint('👨‍🍳 KITCHEN_REPO: Received orders data');

      final List<dynamic> data = response is List
          ? response
          : (response is Map<String, dynamic> && response.containsKey('results')
                ? response['results'] as List
                : []);

      return data.map((e) => KitchenOrder.fromJson(e)).toList();
    } catch (e) {
      debugPrint('❌ KITCHEN_REPO: Fetch error: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> startPrep(String orderId) async {
    try {
      debugPrint('👨‍🍳 KITCHEN_REPO: Starting prep for order $orderId');
      await _apiClient.patch('/orders/kitchen/orders/$orderId/prep/');
      debugPrint('👨‍🍳 KITCHEN_REPO: Prep started successfully');
    } catch (e) {
      debugPrint('❌ KITCHEN_REPO: StartPrep error: $e');
      throw Exception('Failed to start prep: $e');
    }
  }

  Future<void> markReady(String orderId) async {
    try {
      debugPrint('👨‍🍳 KITCHEN_REPO: Marking order $orderId as ready');
      await _apiClient.patch('/orders/kitchen/orders/$orderId/ready/');
      debugPrint('👨‍🍳 KITCHEN_REPO: Order marked ready');
    } catch (e) {
      debugPrint('❌ KITCHEN_REPO: MarkReady error: $e');
      throw Exception('Failed to mark ready: $e');
    }
  }

  Future<void> createBargain(
    String orderId,
    int itemId,
    int originalQty,
    int availableQty,
    String message,
  ) async {
    try {
      debugPrint(
        '👨‍🍳 KITCHEN_REPO: Creating bargain for order $orderId, item $itemId',
      );
      await _apiClient.post(
        '/orders/kitchen/orders/$orderId/bargain/',
        data: {
          'item_id': itemId,
          'customer_qty': originalQty,
          'kitchen_qty': availableQty,
          'message': message,
        },
      );
      debugPrint('👨‍🍳 KITCHEN_REPO: Bargain created successfully');
    } catch (e) {
      debugPrint('❌ KITCHEN_REPO: CreateBargain error: $e');
      throw Exception('Failed to create bargain: $e');
    }
  }
}
