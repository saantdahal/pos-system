import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'kitchen_settings_colors.dart';

class ChefProfileCard extends StatelessWidget {
  final String? name;
  final String? role;
  final String? id;
  final String? resturentname;
  final String? imageUrl;
  final bool isLoading;

  const ChefProfileCard({
    super.key,
    this.name,
    this.role,
    this.id,
    this.resturentname,
    this.imageUrl,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: KitchenSettingsColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 45.r,
              backgroundColor: KitchenSettingsColors.orangeAccent.withValues(
                alpha: 0.2,
              ),
              child: CircularProgressIndicator(
                color: KitchenSettingsColors.orangeAccent,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22.sp,
                    width: 150.w,
                    color: KitchenSettingsColors.textSecondary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 14.sp,
                    width: 100.w,
                    color: KitchenSettingsColors.textSecondary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 14.sp,
                    width: 120.w,
                    color: KitchenSettingsColors.textSecondary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KitchenSettingsColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45.r,
            backgroundColor: KitchenSettingsColors.orangeAccent.withValues(
              alpha: 0.2,
            ),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 50.r,
                    color: KitchenSettingsColors.orangeAccent,
                  )
                : null,
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: KitchenSettingsColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  (role ?? 'Staff').toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: KitchenSettingsColors.orangeAccent,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  resturentname ?? 'Restaurant',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: KitchenSettingsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
