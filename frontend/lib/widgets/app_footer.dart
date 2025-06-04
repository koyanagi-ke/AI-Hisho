import 'package:app/widgets/common/theme_builder.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    void onTap(int index) {
      // TODO
      switch (index) {
        case 0:
          Navigator.of(context).pushNamed('/home');
          break;
        case 1:
          Navigator.of(context).pushNamed('/add_schedule');
          break;
        case 2:
          Navigator.of(context).pushNamed('/calendar');
          break;
        case 3:
          Navigator.of(context).pushNamed('/profile');
      }
    }

    return ThemeBuilder(builder: (context, primaryColor) {
      return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'ホーム',
              isSelected: ModalRoute.of(context)?.settings.name == '/home',
              primaryColor: primaryColor,
              onTap: () => onTap(0),
            ),
            _buildNavItem(
              icon: Icons.add,
              label: '予定の追加',
              isSelected:
                  ModalRoute.of(context)?.settings.name == '/add_schedule',
              primaryColor: primaryColor,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 40), // FAB用のスペース
            _buildNavItem(
              icon: Icons.calendar_month,
              label: 'カレンダー',
              isSelected: ModalRoute.of(context)?.settings.name == '/calendar',
              primaryColor: primaryColor,
              onTap: () => onTap(2),
            ),
            _buildNavItem(
              icon: Icons.person,
              label: '設定',
              isSelected: ModalRoute.of(context)?.settings.name == '/profile',
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
