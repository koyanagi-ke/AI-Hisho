import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/api/fcn_token_register.dart';
import 'package:flutter/material.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init(BuildContext context) async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
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
    // TODO 以下仮実装
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title ?? '通知'),
            content: Text(notification.body ?? '新しい通知があります'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
}
