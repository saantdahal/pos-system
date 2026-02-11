import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginFooterSection extends StatelessWidget {
  final VoidCallback? onHelpPressed;
  final VoidCallback? onContactAdminPressed;

  const LoginFooterSection({
    super.key,
    this.onHelpPressed,
    this.onContactAdminPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'OR',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        // Help Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onHelpPressed,
              child: Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
            TextButton(
              onPressed: onContactAdminPressed,
              child: Text(
                'Contact Admin',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}
