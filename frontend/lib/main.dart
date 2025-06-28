import 'dart:async';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:app/firebase_options.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/screens/add_schedule_screen.dart';
import 'package:app/screens/calendar_screen.dart';
import 'package:app/screens/reminder_list_screen.dart';
import 'package:app/screens/settings/settings_character_screen.dart';
import 'package:app/screens/settings/settings_color_screen.dart';
import 'package:app/screens/welcome_screen.dart';
import 'package:app/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'providers/preferences_provider.dart';
import 'screens/tutorial/tutorial_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
StreamSubscription<List<SharedMediaFile>>? _mediaSub;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 匿名ログインを実行
  await AuthService.signInAnonymously();
  await FCMService().init();
  runApp(const MyApp());
  startSharingListener();
}

void startSharingListener() {
  // 起動中の共有受信
  _mediaSub = ReceiveSharingIntent.instance.getMediaStream().listen(
    (List<SharedMediaFile> files) {
      _handleSharedMedia(files);
    },
    onError: (err) => print('getMediaStream error: $err'),
  );

  // 起動時の共有受信
  ReceiveSharingIntent.instance
      .getInitialMedia()
      .then((List<SharedMediaFile> files) {
    _handleSharedMedia(files);
  });
}

void _handleSharedMedia(List<SharedMediaFile> files) {
  for (final file in files) {
    if (file.message != null && file.message!.isNotEmpty) {
      final sharedText = file.message!;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AddScheduleScreen(sharedText: sharedText),
        ),
      );
      break;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('app.channel.shared.data');
  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      if (call.method == 'onShared') {
        final String sharedText = call.arguments;
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AddScheduleScreen(sharedText: sharedText),
          ),
        );
      }
    });

    platform.invokeMethod<String>('getSharedText').then((sharedText) {
      if (sharedText != null && sharedText.isNotEmpty) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AddScheduleScreen(sharedText: sharedText),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefsProvider, child) {
          final themeColor = prefsProvider.preferences.themeColor;
          final tutorialCompleted = prefsProvider.preferences.tutorialCompleted;

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Miralife',
            theme: AppTheme.getTheme(themeColor),
            home:
                tutorialCompleted ? const HomeScreen() : const WelcomeScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/checklist': (context) => const ReminderListScreen(),
              '/add_schedule': (context) => const AddScheduleScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/tutorial': (context) => const TutorialScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/settings_color': (context) => const SettingsColorScreen(),
              '/settings_character': (context) =>
                  const SettingsCharacterScreen(),
            },
          );
        },
      ),
    );
  }
}
