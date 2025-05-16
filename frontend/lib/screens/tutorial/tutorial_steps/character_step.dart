import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class CharacterStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String selectedCharacter;
  final Function(String) setStyle;
  final String themeColor;

  const CharacterStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.selectedCharacter,
    required this.setStyle,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;
    final Color lightColor = primaryColor.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AIアシスタントのキャラクター選択',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'お好きなAIアシスタントのキャラクターを選んでください',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildCharacterOption(
          context,
          id: 'friendly',
          name: 'フレンドリー',
          description: '親しみやすく、会話を楽しむアシスタント。日常的な会話も得意です。',
          icon: Icons.sentiment_satisfied_alt,
          isSelected: selectedCharacter == 'friendly',
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 16),
        _buildCharacterOption(
          context,
          id: 'professional',
          name: 'プロフェッショナル',
          description: '効率的で簡潔な対応が特徴。ビジネスシーンに最適です。',
          icon: Icons.business_center,
          isSelected: selectedCharacter == 'professional',
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 16),
        _buildCharacterOption(
          context,
          id: 'supportive',
          name: 'サポーティブ',
          description: '細やかな気配りと丁寧なサポートが得意。初心者にもやさしく対応します。',
          icon: Icons.support_agent,
          isSelected: selectedCharacter == 'supportive',
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 16),
        _buildCharacterOption(
          context,
          id: 'energetic',
          name: 'エネルギッシュ',
          description: '明るく元気なキャラクター。モチベーションを高めたいときにおすすめです。',
          icon: Icons.bolt,
          isSelected: selectedCharacter == 'energetic',
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

  Widget _buildCharacterOption(
    BuildContext context, {
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required Color lightColor,
  }) {
    return GestureDetector(
      onTap: () => setStyle(id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : AppColors.gray200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? lightColor : AppColors.gray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? primaryColor : AppColors.gray500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: primaryColor,
                            size: 20,
                          ),
                      ],
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
        ),
      ),
    );
  }
}
