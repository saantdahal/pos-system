import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/kitchen_order_model.dart';

class OrderCard extends StatelessWidget {
  final KitchenOrder order;
  final VoidCallback onPrep;
  final VoidCallback onReady;

  const OrderCard({
    super.key,
    required this.order,
    required this.onPrep,
    required this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _getStatusColor(order.status).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderId}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${order.orderTypeLabel} • ${order.location}',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
              _buildStatusChip(order.status),
            ],
          ),
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 24.h),
          ...order.items.map((item) => _buildItemRow(item)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Elapsed: ${_formatTime(order.timeElapsedSeconds)}',
                style: TextStyle(
                  color: order.timeElapsedSeconds > 600
                      ? Colors.red
                      : Colors.green,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (order.status == OrderStatus.pending)
                    _ActionButton(
                      label: 'START PREP',
                      color: Colors.amber,
                      onPressed: onPrep,
                    ),
                  if (order.status == OrderStatus.prep)
                    _ActionButton(
                      label: 'MARK READY',
                      color: Colors.green,
                      onPressed: onReady,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.quantity}x',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.specialInstructions != null &&
                    item.specialInstructions!.isNotEmpty)
                  Text(
                    item.specialInstructions!,
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.deepOrange;
      case OrderStatus.prep:
        return Colors.amber;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.blue;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
