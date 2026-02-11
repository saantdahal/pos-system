import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsActionButtons extends StatelessWidget {
  final VoidCallback onPickupAll;
  final VoidCallback onMarkServed;
  final VoidCallback onAddNote;
  final VoidCallback onCallKitchen;
  final bool isLoading;

  const OrderDetailsActionButtons({
    super.key,
    required this.onPickupAll,
    required this.onMarkServed,
    required this.onAddNote,
    required this.onCallKitchen,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  onPressed: isLoading ? null : onPickupAll,
                  icon: Icons.shopping_basket,
                  label: 'PICKUP ALL',
                  backgroundColor: Colors.grey[800] ?? Colors.grey,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildButton(
                  onPressed: isLoading ? null : onMarkServed,
                  icon: Icons.check_circle,
                  label: 'MARK SERVED',
                  backgroundColor: const Color(0xFF22C55E),
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  onPressed: isLoading ? null : onAddNote,
                  icon: Icons.note_add,
                  label: 'ADD NOTE',
                  backgroundColor: Colors.grey[700] ?? Colors.grey,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildButton(
                  onPressed: isLoading ? null : onCallKitchen,
                  icon: Icons.notifications_active,
                  label: 'CALL KITCHEN',
                  backgroundColor: const Color(0xFF7F1D1D),
                  textColor: const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
