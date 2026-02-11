import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStats extends StatelessWidget {
  final int ordersServedToday;

  const ProfileStats({super.key, required this.ordersServedToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3D2A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDERS SERVED TODAY',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                Icons.restaurant,
                color: const Color(0xFF22C55E),
                size: 20.sp,
              ),
            ],
          ),
          // Order Count
          Text(
            ordersServedToday.toString(),
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: (ordersServedToday / 100).clamp(0, 1),
              minHeight: 3.h,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF22C55E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
