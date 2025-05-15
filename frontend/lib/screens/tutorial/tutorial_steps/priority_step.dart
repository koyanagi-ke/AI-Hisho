import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class PriorityStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final List<String> selectedPriority;
  final Function(String) togglePriority;
  final String themeColor;

  const PriorityStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.selectedPriority,
    required this.togglePriority,
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
          'あなたの優先事項',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'どの情報を優先的に表示しますか？（複数選択可）',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildPriorityOption(
          context,
          id: 'work',
          icon: Icons.work,
          label: '仕事関連',
          isSelected: selectedPriority.contains('work'),
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 12),
        _buildPriorityOption(
          context,
          id: 'weather',
          icon: Icons.cloud,
          label: '天気情報',
          isSelected: selectedPriority.contains('weather'),
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 12),
        _buildPriorityOption(
          context,
          id: 'items',
          icon: Icons.list,
          label: '持ち物リスト',
          isSelected: selectedPriority.contains('items'),
          primaryColor: primaryColor,
          lightColor: lightColor,
        ),
        const SizedBox(height: 12),
        _buildPriorityOption(
          context,
          id: 'travel',
          icon: Icons.home,
          label: '移動時間',
          isSelected: selectedPriority.contains('travel'),
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

  Widget _buildPriorityOption(
    BuildContext context, {
    required String id,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    required Color lightColor,
  }) {
    return GestureDetector(
      onTap: () => togglePriority(id),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? lightColor : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : AppColors.gray500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
