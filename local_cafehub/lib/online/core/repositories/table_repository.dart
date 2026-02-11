import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/models/table/table_model.dart';
import 'package:bhansa_ghar/online/core/models/table/table_request.dart';
import 'package:flutter/material.dart';

class TableRepository {
  final ApiClient _apiClient;

  TableRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all tables for the restaurant
  Future<List<TableModel>> listTables() async {
    try {
      debugPrint('TableRepository: listTables called');
      final response = await _apiClient.listTables();
      final tables = response
          .map((json) => TableModel.fromResponse(json))
          .toList();
      debugPrint('TableRepository: Retrieved ${tables.length} tables');
      return tables;
    } catch (e) {
      debugPrint('TableRepository: Error listing tables: $e');
      rethrow;
    }
  }

  /// Create a single table
  Future<TableModel> createTable(TableRequest request) async {
    try {
      debugPrint(
        'TableRepository: createTable called with table_number: ${request.tableNumber}',
      );
      final response = await _apiClient.createTable(request.toJson());
      final table = TableModel.fromResponse(response);
      debugPrint('TableRepository: Table created successfully: ${table.id}');
      return table;
    } catch (e) {
      debugPrint('TableRepository: Error creating table: $e');
      rethrow;
    }
  }

  /// Create multiple tables at once
  Future<List<TableModel>> createBulkTables(int count) async {
    try {
      debugPrint('TableRepository: createBulkTables called with count: $count');
      final response = await _apiClient.createBulkTables(count);
      final tables = response
          .map((json) => TableModel.fromResponse(json))
          .toList();
      debugPrint(
        'TableRepository: Bulk tables created successfully: ${tables.length} tables',
      );
      return tables;
    } catch (e) {
      debugPrint('TableRepository: Error creating bulk tables: $e');
      rethrow;
    }
  }

  /// Get table details by ID
  Future<TableModel> getTableDetail(String id) async {
    try {
      debugPrint('TableRepository: getTableDetail called with id: $id');
      final response = await _apiClient.getTableDetail(id);
      final table = TableModel.fromResponse(response);
      debugPrint('TableRepository: Table detail retrieved successfully');
      return table;
    } catch (e) {
      debugPrint('TableRepository: Error getting table detail: $e');
      rethrow;
    }
  }

  /// Update table
  Future<TableModel> updateTable(String id, TableRequest request) async {
    try {
      debugPrint('TableRepository: updateTable called with id: $id');
      final response = await _apiClient.updateTable(id, request.toJson());
      final table = TableModel.fromResponse(response);
      debugPrint('TableRepository: Table updated successfully');
      return table;
    } catch (e) {
      debugPrint('TableRepository: Error updating table: $e');
      rethrow;
    }
  }

  /// Delete table
  Future<void> deleteTable(String id) async {
    try {
      debugPrint('TableRepository: deleteTable called with id: $id');
      await _apiClient.deleteTable(id);
      debugPrint('TableRepository: Table deleted successfully');
    } catch (e) {
      debugPrint('TableRepository: Error deleting table: $e');
      rethrow;
    }
  }

  /// Regenerate QR code for table
  Future<TableModel> regenerateTableQR(String id) async {
    try {
      debugPrint('TableRepository: regenerateTableQR called with id: $id');
      final response = await _apiClient.regenerateTableQR(id);
      final table = TableModel.fromResponse(response['table']);
      debugPrint('TableRepository: QR code regenerated successfully');
      return table;
    } catch (e) {
      debugPrint('TableRepository: Error regenerating QR code: $e');
      rethrow;
    }
  }
}
