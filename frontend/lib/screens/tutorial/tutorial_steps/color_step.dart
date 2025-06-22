import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class ColorStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String selectedColor;
  final Function(String) setColor;

  const ColorStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.selectedColor,
    required this.setColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'テーマカラー',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'お好みのテーマカラーを選択してください',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildColorOption(
              context,
              colorName: 'orange',
              displayName: 'オレンジ',
              isSelected: selectedColor == 'orange',
            ),
            _buildColorOption(
              context,
              colorName: 'rose',
              displayName: 'ローズ',
              isSelected: selectedColor == 'rose',
            ),
            _buildColorOption(
              context,
              colorName: 'amber',
              displayName: 'イエロー',
              isSelected: selectedColor == 'amber',
            ),
            _buildColorOption(
              context,
              colorName: 'emerald',
              displayName: 'グリーン',
              isSelected: selectedColor == 'emerald',
            ),
            _buildColorOption(
              context,
              colorName: 'blue',
              displayName: 'ブルー',
              isSelected: selectedColor == 'blue',
            ),
            _buildColorOption(
              context,
              colorName: 'indigo',
              displayName: 'パープル',
              isSelected: selectedColor == 'indigo',
            ),
          ],
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
              themeColor: selectedColor,
            ),
            CustomButton(
              text: '次へ',
              onPressed: onNext,
              isFullWidth: false,
              themeColor: selectedColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(
    BuildContext context, {
    required String colorName,
    required String displayName,
    required bool isSelected,
  }) {
    final Color color =
        AppColors.themeColors[colorName] ?? AppColors.themeColors['orange']!;

    return GestureDetector(
      onTap: () => setColor(colorName),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.gray200,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
