import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/category_model.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/menu_item_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MenuRepository {
  final Dio _dio;

  MenuRepository({required Dio dio}) : _dio = dio;

  /// Fetch all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/restaurants/categories/');
      if (response.statusCode == 200) {
        late List<dynamic> data;

        // Handle different response structures
        if (response.data is Map<String, dynamic>) {
          // Paginated response with 'results' key
          data = response.data['results'] as List<dynamic>? ?? [];
        } else if (response.data is List<dynamic>) {
          // Direct list response
          data = response.data as List<dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }

        debugPrint('📂 Received ${data.length} categories from API');
        debugPrint(
          '📂 Raw data sample: ${data.isNotEmpty ? data.first : 'empty'}',
        );

        return data.map((item) {
          try {
            return CategoryModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            debugPrint('❌ Error parsing category: $e');
            debugPrint('❌ Category data: $item');
            rethrow;
          }
        }).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      rethrow;
    }
  }

  /// Fetch all menu items
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final response = await _dio.get('/restaurants/menu-items/');
      if (response.statusCode == 200) {
        late List<dynamic> data;

        // Handle different response structures
        if (response.data is Map<String, dynamic>) {
          // Paginated response with 'results' key
          data = response.data['results'] as List<dynamic>? ?? [];
        } else if (response.data is List<dynamic>) {
          // Direct list response
          data = response.data as List<dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }

        debugPrint('📋 Received ${data.length} menu items from API');
        debugPrint(
          '📋 Raw data sample: ${data.isNotEmpty ? data.first : 'empty'}',
        );

        return data.map((item) {
          try {
            return MenuItemModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            debugPrint('❌ Error parsing menu item: $e');
            debugPrint('❌ Item data: $item');
            rethrow;
          }
        }).toList();
      }
      throw Exception('Failed to load menu items');
    } catch (e) {
      debugPrint('❌ Error fetching menu items: $e');
      rethrow;
    }
  }

  /// Fetch a single menu item
  Future<MenuItemModel> getMenuItem(int id) async {
    try {
      final response = await _dio.get('/restaurants/menu-items/$id/');
      if (response.statusCode == 200) {
        return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to load menu item');
    } catch (e) {
      debugPrint('Error fetching menu item: $e');
      rethrow;
    }
  }

  /// Create a new menu item
  Future<MenuItemModel> createMenuItem(
    MenuItemModel menuItem,
    String? imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'category': menuItem.category,
        'name': menuItem.name,
        'description': menuItem.description,
        'base_price': menuItem.basePrice,
        'discount_percentage': menuItem.discountPercentage,
        'stock_quantity': menuItem.stockQuantity,
        // Position is auto-assigned by backend, don't send it
      });

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await _dio.post(
        '/restaurants/menu-items/',
        data: formData,
      );

      if (response.statusCode == 201) {
        return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create menu item');
    } on DioException catch (e) {
      debugPrint('Error creating menu item: $e');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      String errorMessage = 'Failed to create menu item';

      // Extract validation error from response
      if (e.response?.statusCode == 400 && e.response?.data is Map) {
        final responseData = e.response!.data as Map;
        debugPrint('📋 Response data keys: ${responseData.keys}');

        // Check all field-level errors first
        for (var key in responseData.keys) {
          final error = responseData[key];
          debugPrint(
            '📋 Field "$key" error: $error (type: ${error.runtimeType})',
          );

          if (error is List && error.isNotEmpty) {
            errorMessage = error[0].toString();
            debugPrint('✅ Extracted error: $errorMessage');
            break;
          } else if (error is String && error.isNotEmpty) {
            errorMessage = error;
            debugPrint('✅ Extracted error: $errorMessage');
            break;
          }
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error creating menu item: $e');
      rethrow;
    }
  }

  /// Update a menu item
  Future<MenuItemModel> updateMenuItem(
    int id,
    MenuItemModel menuItem,
    String? imagePath,
  ) async {
    try {
      debugPrint('🔄 [updateMenuItem] Starting update for item ID=$id');
      debugPrint('🔄 Image path provided: $imagePath');

      final formData = FormData.fromMap({
        'category': menuItem.category,
        'name': menuItem.name,
        'description': menuItem.description,
        'base_price': menuItem.basePrice,
        'discount_percentage': menuItem.discountPercentage,
        'stock_quantity': menuItem.stockQuantity,
        // Position is auto-assigned by backend, don't send it
      });

      debugPrint(
        '🔄 FormData created with fields: category, name, description, base_price, discount_percentage, stock_quantity',
      );

      if (imagePath != null && imagePath.isNotEmpty) {
        debugPrint('✅ Image path is valid, adding to FormData');
        final multipartFile = await MultipartFile.fromFile(imagePath);
        debugPrint('✅ MultipartFile created: ${multipartFile.filename}');
        formData.files.add(MapEntry('image', multipartFile));
        debugPrint(
          '✅ Image added to FormData. Total files: ${formData.files.length}',
        );
      } else {
        debugPrint('⚠️ No image path provided for update');
      }

      debugPrint('📤 Sending PATCH request to /restaurants/menu-items/$id/');
      debugPrint(
        '📤 FormData: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}',
      );

      final response = await _dio.patch(
        '/restaurants/menu-items/$id/',
        data: formData,
      );

      debugPrint('✅ Response status: ${response.statusCode}');
      debugPrint('✅ Response data: ${response.data}');

      if (response.statusCode == 200) {
        return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update menu item');
    } on DioException catch (e) {
      debugPrint('Error updating menu item: $e');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      String errorMessage = 'Failed to update menu item';

      // Extract validation error from response
      if (e.response?.statusCode == 400 && e.response?.data is Map) {
        final responseData = e.response!.data as Map;
        debugPrint('📋 Response data keys: ${responseData.keys}');

        // Check all field-level errors first
        for (var key in responseData.keys) {
          final error = responseData[key];
          debugPrint(
            '📋 Field "$key" error: $error (type: ${error.runtimeType})',
          );

          if (error is List && error.isNotEmpty) {
            errorMessage = error[0].toString();
            debugPrint('✅ Extracted error: $errorMessage');
            break;
          } else if (error is String && error.isNotEmpty) {
            errorMessage = error;
            debugPrint('✅ Extracted error: $errorMessage');
            break;
          }
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      rethrow;
    }
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(int id) async {
    try {
      final response = await _dio.delete('/restaurants/menu-items/$id/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete menu item');
      }
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      rethrow;
    }
  }

  /// Update menu item stock
  Future<MenuItemModel> updateMenuItemStock(int id, int stockQuantity) async {
    try {
      final response = await _dio.patch(
        '/restaurants/menu-items/$id/',
        data: {'stock_quantity': stockQuantity},
      );

      if (response.statusCode == 200) {
        return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update menu item stock');
    } catch (e) {
      debugPrint('Error updating menu item stock: $e');
      rethrow;
    }
  }
}
