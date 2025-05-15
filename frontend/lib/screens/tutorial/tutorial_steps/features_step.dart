import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class FeaturesStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String themeColor;

  const FeaturesStep({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;
    final Color lightColor = primaryColor.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI秘書の主な機能',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          context,
          icon: Icons.schedule,
          title: '自然言語での予定登録',
          description: '「明日の9時に上野動物園に行く」など、普段の言葉で予定を登録できます。',
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context,
          icon: Icons.cloud,
          title: '天気予報と自動で連動',
          description: '天気予報に基づいて、おすすめ情報や傘・上着などの持ち物を自動で提案します。',
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context,
          icon: Icons.location_on,
          title: '適切なタイミングでのリマインダー',
          description: '移動時間を考慮した通知や、準備に必要な時間も計算します。',
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomButton(
              text: '戻る',
              onPressed: onBack,
              isPrimary: false,
              isFullWidth: false,
              themeColor: themeColor,
            ),
            CustomButton(
              text: '次へ',
              onPressed: onNext,
              isFullWidth: false,
              themeColor: themeColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
    required Color lightColor,
  }) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
