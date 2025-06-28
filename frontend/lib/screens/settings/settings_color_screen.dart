import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/common/theme_builder.dart';

class SettingsColorScreen extends StatelessWidget {
  const SettingsColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, primaryColor) {
        final prefsProvider = Provider.of<PreferencesProvider>(context);
        final currentColor = prefsProvider.preferences.themeColor;
        return Scaffold(
          appBar: AppBar(
            title: const Text('カラー設定'),
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
                  'テーマカラーを選択',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'お好みのテーマカラーを選択してください',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: AppColors.themeColors.entries.map((entry) {
                      final colorName = entry.key;
                      final color = entry.value;
                      final isSelected = colorName == currentColor;
                      return GestureDetector(
                        onTap: () async {
                          await prefsProvider.updateThemeColor(colorName);
                        },
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
                                _colorDisplayName(colorName),
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

  String _colorDisplayName(String colorName) {
    switch (colorName) {
      case 'orange':
        return 'オレンジ';
      case 'rose':
        return 'ローズ';
      case 'amber':
        return 'イエロー';
      case 'emerald':
        return 'グリーン';
      case 'blue':
        return 'ブルー';
      case 'indigo':
        return 'パープル';
      default:
        return colorName;
    }
  }
}
