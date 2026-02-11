import 'package:flutter/material.dart' hide Table;
import 'package:bhansaghar_staff/features/waiter/domain/models/table_model.dart';

class TableCard extends StatelessWidget {
  final WaiterTable table;
  final VoidCallback onTap;

  const TableCard({super.key, required this.table, required this.onTap});

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return const Color(0xFF4CAF50); // Green
      case TableStatus.occupied:
        return const Color(0xFFFFA500); // Orange
      case TableStatus.ready:
        return const Color(0xFF2196F3); // Blue
      case TableStatus.serving:
        return const Color(0xFFFF9800); // Orange (serving)
      case TableStatus.dirty:
        return const Color(0xFFFF5252); // Red
    }
  }

  String _getStatusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.ready:
        return 'Ready';
      case TableStatus.serving:
        return 'Serving';
      case TableStatus.dirty:
        return 'Dirty';
    }
  }

  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Icons.check_circle;
      case TableStatus.occupied:
        return Icons.people;
      case TableStatus.ready:
        return Icons.room_service;
      case TableStatus.serving:
        return Icons.local_dining;
      case TableStatus.dirty:
        return Icons.cleaning_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getStatusColor(table.status),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Table number
                    Text(
                      table.name.replaceAll('Table ', ''),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status label
                    Text(
                      _getStatusLabel(table.status),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Capacity
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${table.capacity}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Status icon in top-right
            Positioned(
              top: 6,
              right: 6,
              child: Icon(
                _getStatusIcon(table.status),
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
