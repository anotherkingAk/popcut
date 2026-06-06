import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _initialized;
  String? get userId => _user?.uid;
  String? get displayName => _user?.displayName;
  String? get email => _user?.email;
  String? get phoneNumber => _user?.phoneNumber;
  String? get photoUrl => _user?.photoURL;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createAccount(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw AuthException('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<String> sendOtp(String phoneNumber, {required void Function(String verId, int? resendToken) onCodeSent}) async {
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          await _auth.signInWithCredential(credential);
        } catch (e) {
          // Auto-verification failed silently
        }
      },
      verificationFailed: (e) {
        completer.completeError(AuthException(e.message ?? 'Verification failed'));
      },
      codeSent: (verId, resendToken) {
        completer.complete(verId);
        onCodeSent(verId, resendToken);
      },
      codeAutoRetrievalTimeout: (verId) {
        if (!completer.isCompleted) completer.complete(verId);
      },
    );
    return completer.future;
  }

  Future<UserCredential> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
