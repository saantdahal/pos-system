import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TableInfoCard extends StatelessWidget {
  final int tableNumber;
  final int capacity;

  const TableInfoCard({
    super.key,
    required this.tableNumber,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF22C55E),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.fastfood_rounded,
                    color: const Color(0xFF22C55E),
                    size: 60.sp,
                  ),
                ),
              ),
              Container(
                width: 50.w,
                height: 50.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$tableNumber',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'TABLE $tableNumber',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people,
                color: const Color(0xFF22C55E),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Capacity: $capacity seats',
                style: TextStyle(
                  color: const Color(0xFF22C55E),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
