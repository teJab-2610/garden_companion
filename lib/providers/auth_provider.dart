import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _currentUser;
  bool _rememberMe = false;

  User? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      notifyListeners();
    } catch (error) {
      throw Exception('Login failed: $error');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuth =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuth.accessToken,
          idToken: googleSignInAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        _currentUser = userCredential.user;
        notifyListeners();
      }
    } catch (error) {
      throw error.toString();
    }
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  bool get isAuthenticated => _auth.currentUser != null;

  Future<void> logout() async {
    _currentUser = null;
    _rememberMe = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('rememberMe');

    notifyListeners();
  }

  Future<void> loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  Future<void> saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', _rememberMe);
  }
}
