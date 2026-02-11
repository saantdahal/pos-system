import 'package:flutter/material.dart';
import 'package:bhansa_ghar/online/core/models/staff/staff_model.dart';

class StaffCard extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onRemove;

  const StaffCard({
    super.key,
    required this.staff,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: staff.role == 'kitchen'
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(staff.roleIcon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: staff.role == 'kitchen'
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        staff.roleDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: staff.role == 'kitchen'
                              ? Colors.orange[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        staff.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: staff.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      staff.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: staff.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Menu
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: onEdit,
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: onToggleStatus,
                child: Row(
                  children: [
                    Icon(
                      staff.isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(staff.isActive ? 'Deactivate' : 'Activate'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: onRemove,
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
