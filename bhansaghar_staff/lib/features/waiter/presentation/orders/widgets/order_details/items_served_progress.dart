import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemsServedProgress extends StatelessWidget {
  final int servedItems;
  final int totalItems;

  const ItemsServedProgress({
    super.key,
    required this.servedItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalItems > 0 ? servedItems / totalItems : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ITEMS SERVED',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$servedItems/$totalItems',
                style: TextStyle(
                  color: const Color(0xFF22C55E),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
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
