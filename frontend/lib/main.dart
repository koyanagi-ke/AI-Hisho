import 'package:app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'providers/preferences_provider.dart';
import 'screens/tutorial/tutorial_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PreferencesProvider(),
      child: Consumer<PreferencesProvider>(
        builder: (context, prefsProvider, child) {
          if (prefsProvider.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          final themeColor = prefsProvider.preferences.themeColor;
          final tutorialCompleted = prefsProvider.preferences.tutorialCompleted;

          return MaterialApp(
            title: 'Miralife',
            theme: AppTheme.getTheme(themeColor),
            home:
                tutorialCompleted ? const HomeScreen() : const WelcomeScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/tutorial': (context) => const TutorialScreen(),
            },
          );
        },
      ),
    );
  }
}
