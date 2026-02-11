import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String location;
  final String? profileImageUrl;
  final bool isVerified;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.role,
    required this.location,
    this.profileImageUrl,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Image with Badge
        Stack(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF22C55E), width: 3.w),
              ),
              child: ClipOval(child: _buildProfileImage()),
            ),
            if (isVerified)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2.w,
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.check, color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        // Name
        Text(
          name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        // Role Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF22C55E), width: 1.w),
          ),
          child: Text(
            role,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22C55E),
              letterSpacing: 1.w,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.grey[500], size: 18.sp),
            SizedBox(width: 4.w),
            Text(
              location,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Icon(Icons.person, color: Colors.grey[600], size: 60.sp),
        ),
      );
    }

    return Image.network(
      profileImageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: Icon(Icons.person, color: Colors.grey[600], size: 60.sp),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFF22C55E),
            ),
          ),
        );
      },
    );
  }
}
