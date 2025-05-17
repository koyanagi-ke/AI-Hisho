import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/characters.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/shadowed_image.dart';

class CharacterStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String selectedCharacter;
  final Function(String) setCharacter;
  final String themeColor;

  const CharacterStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.selectedCharacter,
    required this.setCharacter,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AIアシスタントのキャラクター',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'お好みのキャラクターを選択してください',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: CharactersList.all.map((character) {
              return _buildCharacterTile(
                context,
                character: character,
                isSelected: selectedCharacter == character.id,
                primaryColor: primaryColor,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
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

  Widget _buildCharacterTile(
    BuildContext context, {
    required Character character,
    required bool isSelected,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: () => setCharacter(character.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : AppColors.gray200,
            width: isSelected ? 2 : 1,
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
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: ShadowedImage(assetPath: character.imagePath),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
