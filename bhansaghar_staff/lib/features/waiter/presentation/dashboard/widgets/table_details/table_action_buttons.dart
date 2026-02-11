import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TableActionButtons extends StatelessWidget {
  final VoidCallback onCleanTable;
  final VoidCallback onMarkReady;
  final VoidCallback onCallKitchen;
  final bool isLoading;

  const TableActionButtons({
    super.key,
    required this.onCleanTable,
    required this.onMarkReady,
    required this.onCallKitchen,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a1a1a),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              onPressed: isLoading ? null : onCleanTable,
              icon: Icons.cleaning_services,
              label: 'CLEAN TABLE',
              backgroundColor: const Color(0xFFFFC107),
              textColor: Colors.black,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              onPressed: isLoading ? null : onMarkReady,
              icon: Icons.check_circle,
              label: 'MARK READY',
              backgroundColor: const Color(0xFF22C55E),
              textColor: Colors.black,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              onPressed: isLoading ? null : onCallKitchen,
              icon: Icons.notification_important,
              label: 'CALL KITCHEN',
              backgroundColor: const Color(0xFF1976D2),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
