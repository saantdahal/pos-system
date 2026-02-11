import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialInstructionsSection extends StatelessWidget {
  final String? instructions;

  const SpecialInstructionsSection({
    super.key,
    this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    if (instructions == null || instructions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPECIAL INSTRUCTIONS',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Text(
              instructions!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
