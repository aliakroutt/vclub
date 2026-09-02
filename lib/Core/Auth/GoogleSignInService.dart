import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // serverClientId: "192104838036-l9lqv6qsdplnaecu6qemejdc5qcsnimj.apps.googleusercontent.com"
  );

  static Future<String?> signInAndGetIdToken() async {
    try {
      debugPrint('🔵 [Google] starting signOut...');
      await _googleSignIn.signOut().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ [Google] signOut timed out, continuing anyway');
          return null;
        },
      );
      debugPrint('🔵 [Google] signOut done');

      debugPrint('🔵 [Google] opening picker...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('❌ [Google] signIn() timed out after 30s — picker never resolved');
          return null;
        },
      );

      if (googleUser == null) {
        debugPrint('🔵 [Google] user cancelled or timed out');
        return null;
      }

      debugPrint('🔵 [Google] got account: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('❌ [Google] authentication step timed out');
          throw TimeoutException('Google auth token retrieval timed out');
        },
      );

      debugPrint('🔵 [Google] got idToken: ${googleAuth.idToken != null}');

      return googleAuth.idToken;
    } catch (e) {
      debugPrint('⚠️ GoogleSignInService error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('⚠️ GoogleSignInService signOut error: $e');
    }
  }
}