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
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            color: lightColor,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/characters/$selectedCharacter.png',
            fit: BoxFit.contain,
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
}
