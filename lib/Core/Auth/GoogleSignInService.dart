// lib/Core/Auth/GoogleSignInService.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase + google_sign_in to produce a Firebase ID token that the
/// backend verifies (POST /auth/google, payload { idToken }).
class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Runs the full Google → Firebase sign-in flow and returns the Firebase
  /// ID token to send to the backend. Returns null if the user cancels the
  /// picker or anything fails along the way.
  static Future<String?> signInAndGetIdToken() async {
    try {
      // Ensure a clean state — avoids silently reusing a stale cached
      // account if the user wants to switch Google accounts.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker.
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // This is the Firebase ID token — what the backend expects.
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } catch (e) {
      debugPrint('⚠️ GoogleSignInService error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('⚠️ GoogleSignInService signOut error: $e');
    }
  }
}