import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OrderCard extends StatelessWidget {
  final String image;
  final bool isPrepared;
  final String preparedTime;
  final String status;
  final Color statusColor;
  final String orderId;
  final String tableNumber;
  final String items;
  final bool isUrgent;

  const OrderCard({
    super.key,
    required this.image,
    required this.isPrepared,
    required this.preparedTime,
    required this.status,
    required this.statusColor,
    required this.orderId,
    required this.tableNumber,
    required this.items,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Extract order ID from orderId string (e.g., "#123" -> "123")
        final orderIdNum = orderId.replaceAll('#', '');
        context.push('/waiter/order/$orderIdNum');
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: const Color(0xFF22C55E), width: 4.w),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Urgent Badge
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                    child: _buildImage(),
                  ),
                ),
                if (isUrgent)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Order Details
            Container(
              color: const Color(0xFF2A2A2A),
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prepared $preparedTime',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Order ID and Table
                  Text(
                    '$orderId $tableNumber',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Items
                  Row(
                    children: [
                      Icon(Icons.close, color: Colors.grey[400], size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          items,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Pickup Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Extract order ID from orderId string (e.g., "#123" -> "123")
                        final orderIdNum = orderId.replaceAll('#', '');
                        context.push('/waiter/order/$orderIdNum');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'PICKUP',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[600],
              size: 30.sp,
            ),
          ),
        );
      },
    );
  }
}
