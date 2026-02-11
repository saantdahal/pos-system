import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/order_details_model.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemModel item;
  final VoidCallback onTap;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _getBorderColor(),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _buildStatusIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '₹${item.quantity * 10}', // Mock price
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (item.icon != null)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.fastfood,
                  color: Colors.grey[600],
                  size: 24.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (item.status == 'served') {
      return Container(
        width: 40.w,
        height: 40.h,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.check,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
      );
    } else if (item.status == 'ready_for_pickup') {
      return Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF22C55E),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.circle,
            color: const Color(0xFF22C55E),
            size: 16.sp,
          ),
        ),
      );
    } else {
      return Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.schedule,
            color: Colors.grey[500],
            size: 20.sp,
          ),
        ),
      );
    }
  }

  Color _getStatusColor() {
    switch (item.status) {
      case 'served':
        return const Color(0xFF22C55E);
      case 'ready_for_pickup':
        return const Color(0xFFFFC107);
      default:
        return Colors.grey[500]!;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case 'served':
        return 'Served';
      case 'ready_for_pickup':
        return 'READY FOR PICKUP';
      default:
        return 'Preparing';
    }
  }

  Color _getBorderColor() {
    switch (item.status) {
      case 'served':
        return Colors.grey[700]!;
      case 'ready_for_pickup':
        return const Color(0xFF22C55E);
      default:
        return Colors.grey[700]!;
    }
  }
}
