import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/characters.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/common/theme_builder.dart';
import '../../widgets/shadowed_image.dart';

class SettingsCharacterScreen extends StatelessWidget {
  const SettingsCharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, primaryColor) {
        final prefsProvider = Provider.of<PreferencesProvider>(context);
        final currentCharacter = prefsProvider.preferences.assistantCharacter;
        return Scaffold(
          appBar: AppBar(
            title: const Text('キャラクター設定'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
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
                      final isSelected = currentCharacter == character.id;
                      return GestureDetector(
                        onTap: () async {
                          await prefsProvider
                              .updateAssistantCharacter(character.id);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? primaryColor : AppColors.gray200,
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: ShadowedImage(
                                          assetPath: character.imagePath),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
