import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final String themeColor;

  const WelcomeStep({
    Key? key,
    required this.onNext,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;
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
            Icons.auto_awesome,
            size: 48,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'AI秘書へようこそ',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'あなた専用のAI秘書を設定して、スケジュール管理をもっとスマートに。\n数ステップの簡単な設定で、あなたに最適なAI秘書をカスタマイズしましょう。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: CustomButton(
            text: '始める',
            onPressed: onNext,
            themeColor: themeColor,
          ),
        ),
      ],
    );
  }
}
