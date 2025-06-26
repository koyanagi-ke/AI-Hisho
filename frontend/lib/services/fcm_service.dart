import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/api/fcn_token_register.dart';
import 'package:app/main.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (e) {
      // Simulatorではトークン取得できない
      debugPrint('トークン取得エラー: $e');
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (token != null && uid != null) {
      await FCNTokenRegister.registerToken(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FCNTokenRegister.registerToken(newToken);
      }
    });

    // アプリがバックグラウンドで通知から復帰したとき
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigatorKey.currentState?.pushNamed('/checklist');
    });

    // アプリが完全終了 → 通知で起動したとき
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamed('/checklist');
      });
    }

    // フォアグラウンド時
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // });
  }
}
