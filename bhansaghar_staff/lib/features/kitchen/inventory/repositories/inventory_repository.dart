import 'package:bhansaghar_staff/core/api/api_client.dart';
import 'package:flutter/foundation.dart';

class InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepository(this._apiClient);

  Future<List<dynamic>> getMenu() async {
    try {
      // Reusing endpoint that returns categories with items.
      // But currently, the endpoint for that is not straightforward without restaurant context or specialized view.
      // `CategoryViewSet` returns categories for the user's restaurant.
      // And we serializes `items` in `CategorySerializer` (need to check serializer).
      // If not, we might need to fetch categories then items.
      // Let's assume `CategorySerializer` or a new endpoint gives us nested structure.
      // Wait, `CategoryViewSet` uses `CategorySerializer`. Let's check `CategorySerializer`.
      // Assuming it does NOT nest items by default based on common REST patterns unless specified.
      // But looking at `scan_qr` logic in backend, it constructs manually.
      // For staff, let's try fetching `/categories/` and see.
      // If `CategorySerializer` includes items, great. If not, we might need `MenuItemViewSet`.
      // Let's fetch `menu-items` and group manually for now if needed.

      final response = await _apiClient.get('/restaurants/categories/');
      debugPrint('📦 INVENTORY_REPO: Categories raw: $response');

      debugPrint('📦 INVENTORY_REPO: Fetching items...');
      final itemsResponse = await _apiClient.get('/restaurants/menu-items/');
      debugPrint('📦 INVENTORY_REPO: Items raw: $itemsResponse');

      final List categories = response is List
          ? response
          : (response is Map<String, dynamic> && response.containsKey('results')
                ? response['results'] as List
                : []);

      final List items = itemsResponse is List
          ? itemsResponse
          : (itemsResponse is Map<String, dynamic> &&
                    itemsResponse.containsKey('results')
                ? itemsResponse['results'] as List
                : []);

      debugPrint('📦 INVENTORY_REPO: Parsed categories: ${categories.length}');
      debugPrint('📦 INVENTORY_REPO: Parsed items: ${items.length}');

      return [categories, items];
    } catch (e) {
      debugPrint('❌ INVENTORY_REPO: Error: $e');
      throw Exception('Failed to fetch menu: $e');
    }
  }

  Future<void> updateStock(int itemId, int? quantity) async {
    try {
      debugPrint(
        '📦 INVENTORY_REPO: Updating stock for item $itemId to $quantity',
      );
      await _apiClient.patch(
        '/restaurants/menu-items/$itemId/update-stock/',
        data: {'stock_quantity': quantity},
      );
      debugPrint('📦 INVENTORY_REPO: Stock update successful');
    } catch (e) {
      debugPrint('❌ INVENTORY_REPO_UPDATE_ERROR: $e');
      throw Exception('Failed to update stock: $e');
    }
  }
}
