import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> signInAnonymously() async {
    final currentUser = _auth.currentUser;
    // TODO しばらくデバッグように以下のコード残しておく
    if (currentUser == null) {
      final UserCredential credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        debugPrint('✅ Anonymous sign-in successful: UID = ${user.uid}');
      } else {
        debugPrint('⚠️ Anonymous sign-in returned null user');
      }
    } else {
      debugPrint('ℹ️ Already signed in: UID = ${currentUser.uid}');
    }
    // if (currentUser == null) {
    //   await _auth.signInAnonymously();
    // }
  }

  static Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    return await user?.getIdToken();
  }

  static String? get uid => _auth.currentUser?.uid;
}
