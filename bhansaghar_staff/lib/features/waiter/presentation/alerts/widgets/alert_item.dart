import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/alert_model.dart';

class AlertItem extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;

  const AlertItem({super.key, required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            _buildAlertIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    alert.description,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(alert.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                ),
                SizedBox(height: 6.h),
                _buildUnreadIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertIcon() {
    IconData iconData;
    Color backgroundColor;

    switch (alert.type) {
      case AlertType.table:
        iconData = Icons.restaurant;
        backgroundColor = const Color(0xFF1B5E20);
        break;
      case AlertType.order:
        iconData = Icons.receipt;
        backgroundColor = const Color(0xFF6B4423);
        break;
      case AlertType.kitchen:
        iconData = Icons.kitchen;
        backgroundColor = Colors.grey[700]!;
        break;
      case AlertType.system:
        iconData = Icons.info;
        backgroundColor = Colors.grey[700]!;
        break;
    }

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(iconData, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildUnreadIndicator() {
    if (alert.isRead) {
      return SizedBox(width: 8.w, height: 8.h);
    }

    return Container(
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
