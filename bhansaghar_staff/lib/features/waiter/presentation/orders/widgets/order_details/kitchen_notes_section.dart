import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KitchenNotesSection extends StatelessWidget {
  final String? notes;

  const KitchenNotesSection({
    super.key,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KITCHEN NOTES',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF22C55E),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    Icons.info,
                    color: const Color(0xFF22C55E),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    notes!,
                    style: TextStyle(
                      color: const Color(0xFF22C55E),
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
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
