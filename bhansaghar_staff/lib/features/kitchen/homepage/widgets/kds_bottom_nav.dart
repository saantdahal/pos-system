import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class KDSBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const KDSBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.dashboard,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onTap(0),
            selectedColor: Colors.deepOrange,
          ),
          _NavItem(
            icon: Icons.receipt_long,
            label: 'Orders',
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
            selectedColor: Colors.deepOrange,
          ),
          _NavItem(
            icon: Icons.store,
            label: 'Inventory',
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
            selectedColor: Colors.deepOrange,
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: selectedIndex == 3,
            onTap: () => onTap(3),
            selectedColor: Colors.deepOrange,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : Colors.grey,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
