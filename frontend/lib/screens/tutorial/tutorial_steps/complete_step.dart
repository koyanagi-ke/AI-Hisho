import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class CompleteStep extends StatelessWidget {
  final VoidCallback onComplete;
  final String selectedCharacter;
  final String selectedColor;

  const CompleteStep({
    super.key,
    required this.onComplete,
    required this.selectedCharacter,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.themeColors[selectedColor] ??
        AppColors.themeColors['orange']!;
    final Color lightColor = primaryColor.withOpacity(0.1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: lightColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 48,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '設定完了！',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'あなた専用のミライフの設定が完了しました。いつでも設定から変更することができます。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 24),
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
              const Text(
                'あなたの設定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 12),
              _buildSettingRow(
                label: 'レイアウト',
                value: _getCharacterText(),
              ),
              const SizedBox(height: 12),
              _buildColorRow(
                label: 'テーマカラー',
                colorName: selectedColor,
                colorText: _getColorText(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: CustomButton(
            text: 'アプリを始める',
            onPressed: onComplete,
            themeColor: selectedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow({
    required String label,
    required String colorName,
    required String colorText,
  }) {
    final Color color =
        AppColors.themeColors[colorName] ?? AppColors.themeColors['orange']!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
          ),
        ),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              colorText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCharacterText() {
    switch (selectedCharacter) {
      case 'friendly':
        return 'フレンドリー';
      case 'professional':
        return 'プロフェッショナル';
      case 'supportive':
        return 'サポーティブ';
      case 'energetic':
        return 'エネルギッシュ';
      default:
        return 'フレンドリー';
    }
  }

  String _getColorText() {
    switch (selectedColor) {
      case 'orange':
        return 'オレンジ';
      case 'rose':
        return 'ローズ';
      case 'amber':
        return 'イエロー';
      case 'emerald':
        return 'グリーン';
      default:
        return 'オレンジ';
    }
  }
}
