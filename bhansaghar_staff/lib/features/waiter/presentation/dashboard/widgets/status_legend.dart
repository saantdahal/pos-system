import 'package:flutter/material.dart';

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildLegendItem(
              'Available',
              const Color(0xFF4CAF50),
              Icons.check_circle,
            ),
            const SizedBox(width: 24),
            _buildLegendItem('Occupied', const Color(0xFFFFA500), Icons.people),
            const SizedBox(width: 24),
            _buildLegendItem(
              'Ready',
              const Color(0xFF2196F3),
              Icons.room_service,
            ),
            const SizedBox(width: 24),
            _buildLegendItem(
              'Dirty',
              const Color(0xFFFF5252),
              Icons.cleaning_services,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
