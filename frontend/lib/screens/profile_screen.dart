import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/preferences_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final themeColor = prefsProvider.preferences.themeColor;
    final primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;
    final lightColor = primaryColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileCard(context, primaryColor, lightColor),
              const SizedBox(height: 24),
              _buildSettingsCard(context, primaryColor, lightColor),
              const SizedBox(height: 24),
              _buildAppInfoCard(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'スケジュール',
                isSelected: false,
                primaryColor: primaryColor,
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
              ),
              _buildNavItem(
                icon: Icons.calendar_month,
                label: 'カレンダー',
                isSelected: false,
                primaryColor: primaryColor,
              ),
              const SizedBox(width: 40), // FAB用のスペース
              _buildNavItem(
                icon: Icons.cloud,
                label: '天気',
                isSelected: false,
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'プロフィール',
                isSelected: true,
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildProfileCard(
      BuildContext context, Color primaryColor, Color lightColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: lightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 32,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'example@email.com',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, Color primaryColor, Color lightColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.settings,
            title: 'ミライフの設定',
            primaryColor: primaryColor,
            lightColor: lightColor,
            onTap: () => Navigator.of(context).pushNamed('/tutorial'),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.shield,
            title: 'プライバシー設定',
            primaryColor: primaryColor,
            lightColor: lightColor,
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.help,
            title: 'ヘルプとサポート',
            primaryColor: primaryColor,
            lightColor: lightColor,
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: 'ログアウト',
            primaryColor: primaryColor,
            lightColor: lightColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color primaryColor,
    required Color lightColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray900,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'アプリバージョン',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最終更新日',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '2025/05/01',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    VoidCallback? onTap,
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
          const SizedBox(height: 4),
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
