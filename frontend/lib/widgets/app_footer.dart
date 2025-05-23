import 'package:app/widgets/common/theme_builder.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, primaryColor) {
      return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.calendar_today,
              label: 'スケジュール',
              isSelected: currentIndex == 0,
              primaryColor: primaryColor,
              onTap: () => onTap(0),
            ),
            _buildNavItem(
              icon: Icons.calendar_month,
              label: 'カレンダー',
              isSelected: currentIndex == 1,
              primaryColor: primaryColor,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 40), // FAB用のスペース
            _buildNavItem(
              icon: Icons.cloud,
              label: '天気',
              isSelected: currentIndex == 2,
              primaryColor: primaryColor,
              onTap: () => onTap(2),
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'プロフィール',
              isSelected: currentIndex == 3,
              primaryColor: primaryColor,
              onTap: () => onTap(3),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : AppColors.gray400,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? primaryColor : AppColors.gray500,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
