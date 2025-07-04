import 'dart:async';
import 'dart:convert';
import 'package:app/constants/colors.dart';
import 'package:app/services/api/event_api.dart';
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
import 'models/schedule.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
StreamSubscription<List<SharedMediaFile>>? _mediaSub;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.signInAnonymously();
  await FCMService().init();
  runApp(const MyApp());
  startSharingListener();
}

void startSharingListener() {
  _mediaSub = ReceiveSharingIntent.instance.getMediaStream().listen(
    (List<SharedMediaFile> files) {
      _handleSharedMedia(files);
    },
    onError: (err) => print('getMediaStream error: $err'),
  );

  ReceiveSharingIntent.instance
      .getInitialMedia()
      .then((List<SharedMediaFile> files) {
    _handleSharedMedia(files);
  });
}

void _handleSharedMedia(List<SharedMediaFile> files) async {
  final texts = files
      .map((file) => file.message)
      .whereType<String>()
      .map((msg) => msg.trim())
      .where((msg) => msg.isNotEmpty)
      .toList();

  if (texts.isNotEmpty) {
    await _openAddScheduleScreenFromSharedTexts(texts);
  }
}

Future<void> _openAddScheduleScreenFromSharedTexts(
    List<String> sharedTexts) async {
  if (sharedTexts.isEmpty) return;

  navigatorKey.currentState?.push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) {
        final prefsProvider =
            Provider.of<PreferencesProvider>(context, listen: false);
        final themeColor = prefsProvider.preferences.themeColor;
        final primaryColor = AppColors.themeColors[themeColor];
        return Scaffold(
          backgroundColor: Colors.black45,
          body: Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        );
      },
    ),
  );

  try {
    final response = await EventApi.extractEvent(
      sharedTexts.map((t) => {"role": "user", "text": t}).toList(),
    );

    navigatorKey.currentState?.pop();

    if (response != null) {
      final event = Schedule.fromJson(response);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AddScheduleScreen(
            initialEvent: event,
            showManualForm: true,
          ),
        ),
      );
    }
  } catch (e) {
    navigatorKey.currentState?.pop();
  }

  const platform = MethodChannel('app.channel.shared.data');
  await platform.invokeMethod('clearSharedText');
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

    platform.invokeMethod<String>('getSharedText').then((jsonString) async {
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List<dynamic> parsed = json.decode(jsonString);
          final List<String> sharedTexts = parsed
              .whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
          if (sharedTexts.isNotEmpty) {
            await _openAddScheduleScreenFromSharedTexts(sharedTexts);
          }
        } catch (e) {
          print('Failed to parse sharedText: $e');
        }
      }
    });

    platform.setMethodCallHandler((call) async {
      if (call.method == 'onShared') {
        final String sharedText = call.arguments;
        if (sharedText.trim().isNotEmpty) {
          await _openAddScheduleScreenFromSharedTexts([sharedText.trim()]);
        }
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
          if (prefsProvider.isLoading) {
            return MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Image.asset(
                    'assets/splash.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            );
          }

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
