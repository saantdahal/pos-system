import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/models/category/category.dart';
import 'package:bhansa_ghar/online/core/models/category/category_request.dart';
import 'package:flutter/material.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all categories
  Future<List<Category>> listCategories() async {
    try {
      debugPrint('CategoryRepository: listCategories called');
      final categories = await _apiClient.listCategories();
      debugPrint(
        'CategoryRepository: Retrieved ${categories.length} categories',
      );
      return categories;
    } catch (e) {
      debugPrint('CategoryRepository: Error listing categories: $e');
      rethrow;
    }
  }

  /// Create a new category
  Future<Category> createCategory(CategoryRequest request) async {
    try {
      debugPrint(
        'CategoryRepository: createCategory called with name: ${request.name}',
      );
      final category = await _apiClient.createCategory(request);
      debugPrint(
        'CategoryRepository: Category created successfully: $category',
      );
      return category;
    } catch (e) {
      debugPrint('CategoryRepository: Error creating category: $e');
      rethrow;
    }
  }

  /// Get category details
  Future<Category> getCategoryDetail(int id) async {
    try {
      debugPrint('CategoryRepository: getCategoryDetail called with id: $id');
      final category = await _apiClient.getCategoryDetail(id);
      debugPrint('CategoryRepository: Category retrieved: $category');
      return category;
    } catch (e) {
      debugPrint('CategoryRepository: Error getting category: $e');
      rethrow;
    }
  }

  /// Update a category
  Future<Category> updateCategory(int id, CategoryRequest request) async {
    try {
      debugPrint(
        'CategoryRepository: updateCategory called with id: $id, name: ${request.name}',
      );
      final category = await _apiClient.updateCategory(id, request);
      debugPrint(
        'CategoryRepository: Category updated successfully: $category',
      );
      return category;
    } catch (e) {
      debugPrint('CategoryRepository: Error updating category: $e');
      rethrow;
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    try {
      debugPrint('CategoryRepository: deleteCategory called with id: $id');
      await _apiClient.deleteCategory(id);
      debugPrint('CategoryRepository: Category deleted successfully');
    } catch (e) {
      debugPrint('CategoryRepository: Error deleting category: $e');
      rethrow;
    }
  }
}
