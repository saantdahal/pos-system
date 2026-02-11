import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertsTabBar extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChanged;

  const AlertsTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Orders', 'value': 'orders'},
      {'label': 'Tables', 'value': 'tables'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isActive = activeTab == tab['value'];

          return GestureDetector(
            onTap: () => onTabChanged(tab['value'] as String),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? const Color(0xFF22C55E)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab['label'] as String,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[400],
                  fontSize: 14.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
