import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> signInAnonymously() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  static Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    return await user?.getIdToken();
  }

  static String? get uid => _auth.currentUser?.uid;
}
