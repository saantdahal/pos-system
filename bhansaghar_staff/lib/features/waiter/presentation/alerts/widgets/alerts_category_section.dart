import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/alert_model.dart';
import 'alert_item.dart';

class AlertsCategorySection extends StatelessWidget {
  final String title;
  final List<AlertModel> alerts;
  final Function(int) onAlertTap;

  const AlertsCategorySection({
    super.key,
    required this.title,
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            return AlertItem(
              alert: alerts[index],
              onTap: () => onAlertTap(alerts[index].id),
            );
          },
        ),
      ],
    );
  }
}
