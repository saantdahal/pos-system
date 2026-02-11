import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TableDetailsHeader extends StatelessWidget {
  final int tableNumber;
  final VoidCallback onBackPressed;
  final VoidCallback? onMenuPressed;

  const TableDetailsHeader({
    super.key,
    required this.tableNumber,
    required this.onBackPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          Text(
            'Table $tableNumber Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onMenuPressed,
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[400],
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
