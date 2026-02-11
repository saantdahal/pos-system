import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertsHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllAsRead;

  const AlertsHeader({
    super.key,
    required this.unreadCount,
    required this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: onMarkAllAsRead,
              child: Text(
                'Mark all as read',
                style: TextStyle(
                  color: const Color(0xFF22C55E),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
