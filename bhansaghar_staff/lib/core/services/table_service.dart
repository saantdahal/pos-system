import 'package:bhansaghar_staff/core/api/api_client.dart';
import 'package:bhansaghar_staff/core/models/table/table_status_response.dart';
import 'package:flutter/foundation.dart';

/// Service for waiter table operations
/// Handles API calls to backend waiter endpoints
class TableService {
  final ApiClient apiClient;

  TableService({required this.apiClient});

  /// Fetch all tables for current restaurant
  /// GET /api/waiter/tables/
  Future<List<TableStatusResponse>> getTables() async {
    try {
      debugPrint('📊 TableService: Fetching tables from /api/waiter/tables/');
      final response = await apiClient.get('/waiter/tables/');

      debugPrint('📊 TableService: Response received: $response');

      if (response is List) {
        final tables = (response)
            .map(
              (item) =>
                  TableStatusResponse.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        debugPrint(
          '📊 TableService: Successfully parsed ${tables.length} tables',
        );
        return tables;
      } else if (response is Map<String, dynamic>) {
        // Handle single table response
        return [TableStatusResponse.fromJson(response)];
      } else {
        throw Exception('Unexpected response format: $response');
      }
    } catch (e) {
      debugPrint('❌ TableService: Error fetching tables - $e');
      rethrow;
    }
  }

  /// Update table status
  /// PATCH /api/waiter/tables/<table_number>/
  Future<TableStatusResponse> updateTableStatus({
    required int tableNumber,
    required TableStatusEnum newStatus,
    String? notes,
  }) async {
    try {
      debugPrint(
        '📝 TableService: Updating table $tableNumber to ${newStatus.name}',
      );

      final data = {
        'status': newStatus.name,
        if (notes != null) 'notes': notes,
      };

      final response = await apiClient.patch(
        '/waiter/tables/$tableNumber/',
        data: data,
      );

      if (response is Map<String, dynamic>) {
        debugPrint('✅ TableService: Table $tableNumber updated successfully');
        return TableStatusResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format: $response');
      }
    } catch (e) {
      debugPrint('❌ TableService: Error updating table - $e');
      rethrow;
    }
  }
}
