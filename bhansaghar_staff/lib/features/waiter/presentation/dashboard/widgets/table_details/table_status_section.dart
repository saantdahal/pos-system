import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TableStatusSection extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const TableStatusSection({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'label': 'Available', 'value': 'available', 'color': Colors.grey[700]},
      {'label': 'Occupied', 'value': 'occupied', 'color': const Color(0xFF7F1D1D)},
      {'label': 'Reserved', 'value': 'reserved', 'color': const Color(0xFF1B5E20)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TABLE STATUS',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((status) {
                final isActive = currentStatus == status['value'];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () => onStatusChanged(status['value'] as String),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? status['color'] as Color
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: isActive
                              ? (status['label'] == 'Available'
                                  ? Colors.grey[600]!
                                  : (status['label'] == 'Occupied'
                                      ? const Color(0xFFFCA5A5)
                                      : const Color(0xFF22C55E)))
                              : Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: status['label'] == 'Available'
                                  ? Colors.grey[600]
                                  : (status['label'] == 'Occupied'
                                      ? const Color(0xFFFCA5A5)
                                      : const Color(0xFF22C55E)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            status['label'] as String,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey[500],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
