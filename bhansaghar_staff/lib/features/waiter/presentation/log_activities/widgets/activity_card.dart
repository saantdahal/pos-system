import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity.activityType),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(activity.activityType),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityTypeDisplay,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(activity.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                if (activity.metadata != null && activity.metadata!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getMetadataPreview(activity.metadata!),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'login':
      case 'logout':
        return Colors.purple;
      case 'order_created':
        return Colors.blue;
      case 'order_updated':
      case 'order_prepared':
        return Colors.orange;
      case 'order_served':
      case 'order_cancelled':
        return Colors.red;
      case 'bargain_created':
        return Colors.amber;
      case 'bargain_accepted':
        return Colors.green;
      case 'bargain_rejected':
        return Colors.red;
      case 'profile_updated':
        return Colors.teal;
      case 'mode_changed':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'order_created':
        return Icons.add_shopping_cart;
      case 'order_updated':
      case 'order_prepared':
        return Icons.update;
      case 'order_served':
        return Icons.check_circle;
      case 'order_cancelled':
        return Icons.cancel;
      case 'bargain_created':
        return Icons.local_offer;
      case 'bargain_accepted':
        return Icons.thumb_up;
      case 'bargain_rejected':
        return Icons.thumb_down;
      case 'profile_updated':
        return Icons.person;
      case 'mode_changed':
        return Icons.mode;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('hh:mm a').format(dateTime);
    }
  }

  String _getMetadataPreview(Map<String, dynamic> metadata) {
    // Show first key-value pair as preview
    if (metadata.isEmpty) return '';

    final firstEntry = metadata.entries.first;
    return '${firstEntry.key}: ${firstEntry.value}';
  }
}
