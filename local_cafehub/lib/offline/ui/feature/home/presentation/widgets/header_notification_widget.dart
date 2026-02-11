import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class HeaderWithNotification extends StatelessWidget {
  final String greeting;
  final String userName;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const HeaderWithNotification({
    super.key,
    required this.greeting,
    required this.userName,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              userName,
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.notifications,
                  color: AppColors.getTextColor(context),
                  size: 22.sp,
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 12.w,
                  top: 12.h,
                  child: Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
