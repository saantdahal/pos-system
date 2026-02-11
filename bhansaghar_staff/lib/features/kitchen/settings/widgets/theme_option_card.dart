import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/settings_bloc.dart';
import 'kitchen_settings_colors.dart';

class ThemeOptionCard extends StatelessWidget {
  final AppThemeType themeType;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOptionCard({
    super.key,
    required this.themeType,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.transparent
                  : KitchenSettingsColors.themeCardInactive,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? KitchenSettingsColors.orangeAccent
                    : Colors.white10,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A2421)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? KitchenSettingsColors.orangeAccent
                      : Colors.grey,
                  size: 28.r,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? KitchenSettingsColors.orangeAccent
                  : KitchenSettingsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
