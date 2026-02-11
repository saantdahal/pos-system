import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryStatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color infoColor;
  final Color backgroundColor;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.infoColor,
    this.backgroundColor = const Color(0xFF2A2A2A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: infoColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: infoColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                count.padLeft(2, '0'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'Orders',
                style: TextStyle(color: Colors.grey, fontSize: 10.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            height: 4.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: infoColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
