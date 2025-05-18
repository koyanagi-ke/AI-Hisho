import 'package:app/providers/chat_provider.dart';
import 'package:app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'providers/preferences_provider.dart';
import 'screens/tutorial/tutorial_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // 匿名ログインを実行
  await AuthService.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
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
