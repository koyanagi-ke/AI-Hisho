import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preferences_provider.dart';
import '../../constants/colors.dart';

class ThemeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Color primaryColor) builder;

  const ThemeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefsProvider, _) {
        final themeName = prefsProvider.preferences.themeColor;
        final color = AppColors.themeColors[themeName] ??
            AppColors.themeColors['orange']!;
        return builder(context, color);
      },
    );
  }
}
