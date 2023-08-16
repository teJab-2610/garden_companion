import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _currentUser;
  bool _rememberMe = false;

  User? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;

  // Future<void> checkLoggedInStatus() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     bool rememberMe = prefs.getBool('rememberMe') ?? false;

  //     if (rememberMe) {
  //       final User? user = _auth.currentUser;

  //       if (user != null) {
  //         _currentUser = user;
  //         notifyListeners();
  //       }
  //     }
  //   } catch (error) {
  //     print('Error checking logged in status: $error');
  //   }
  // }

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
      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
//add new userID to users collection in firestore

        // // Create a document for the user in a Firestore collection
        // await _firestore.collection('users').doc(userId).set({
        //   'email': email, 'followersCount': 0, 'followingCount': 0,
        //   'password': password, 'postsCount': 0, 'userId': ""
        //   // Add more user data fields as needed
        // });

        final userDocRef = _firestore.collection('users').doc(userId);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          // Document exists, update the data
          await userDocRef.update({
            'email': email,
            'followersCount': 0,
            'followingCount': 0,
            'password': password,
            'postsCount': 0,
            'userId': ""
          });
        } else {
          // Document doesn't exist, create a new one
          await userDocRef.set({
            'email': email,
            'followersCount': 0,
            'followingCount': 0,
            'password': password,
            'postsCount': 0,
            'userId': ""
          });
        }

        // Notify listeners about successful registration
        notifyListeners();
      }
      _currentUser = userCredential.user;
      notifyListeners();
    } catch (error) {
      print("Failed Registration in AuthProvider: $error");
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
    notifyListeners();
  }
}
