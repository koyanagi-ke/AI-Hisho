import 'package:app/constants/characters.dart';
import 'package:app/widgets/common/common_layout.dart';
import 'package:app/widgets/common/theme_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/preferences_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, primaryColor) {
      final lightColor = primaryColor.withOpacity(0.1);
      return CommonLayout(
        appBar: AppBar(
          title: const Text('ユーザー設定'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
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
      );
    });
  }

  Widget _buildProfileCard(
      BuildContext context, Color primaryColor, Color lightColor) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: lightColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: 48,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, Color primaryColor, Color lightColor) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final assistantCharacter =
        CharactersList.getById(prefsProvider.preferences.assistantCharacter);

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
            leftWidget: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            title: 'カラー設定',
            onTap: () => Navigator.of(context).pushNamed('/settings_color'),
          ),
          const Divider(height: 1),
          // キャラクター設定
          _buildSettingItem(
            context,
            leftWidget: Image.asset(
              assistantCharacter.imagePath,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
            title: 'キャラクター設定',
            onTap: () => Navigator.of(context).pushNamed('/settings_character'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required Widget leftWidget,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(child: leftWidget),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontWeight: FontWeight.w600,
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
                '2025/06/29',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
