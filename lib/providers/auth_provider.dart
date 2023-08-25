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

  Future<void> register(String email, String password, String username,
      String name, String phonenumber) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;

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
            'userId': username,
            'name': name,
            'phoneNumber': phonenumber,
            'bookmarks': [],
            'bio': '',
          });
        } else {
          // Document doesn't exist, create a new one
          await userDocRef.set({
            'email': email,
            'followersCount': 0,
            'followingCount': 0,
            'password': password,
            'postsCount': 0,
            'userId': username,
            'name': name,
            'phoneNumber': phonenumber,
            'bookmarks': [],
            'groups': [],
            'bio': '',
            'uid': userDocRef.id,
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('followers')
              .doc('dummy')
              .set({});
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('following')
              .doc('dummy')
              .set({});
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('posts')
              .doc('dummy')
              .set({});
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('items')
              .doc('dummy')
              .set({
            'author': 'dummy',
            'imageUrl': 'dummy',
            'itemId': 'dummy',
            'originalUid': 'dummy',
            'timestamp': 'dummy',
            'title': 'dummy',
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc('dummy')
              .set({
            'notifId': 'dummy',
            'recieverItemId': 'dummy',
            'recieverItemTitle': 'dummy',
            'recieverUid': 'dummy',
            'sender': 'dummy',
            'senderItemId': 'dummy',
            'senderItemTitle': 'dummy',
            'timestamp': 'dummy',
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

  Future<void> createGoogleProfile(String userId, String email) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
      });
      final name = email.substring(0, email.indexOf('@'));
      final userrId = email.substring(0, email.indexOf('@'));

      final userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.set({
        'email': email,
        'followersCount': 0,
        'followingCount': 0,
        'password': "NA",
        'postsCount': 0,
        'userId': userrId,
        'bio': "",
        'name': name,
        'phoneNumber': "",
        'bookmarks': [],
        'groups': [],
        'uid': userDocRef.id,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('followers')
          .doc('dummy')
          .set({});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc('dummy')
          .set({});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc('dummy')
          .set({});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc('dummy')
          .set({
        'notifId': 'dummy',
        'recieverItemId': 'dummy',
        'recieverItemTitle': 'dummy',
        'recieverUid': 'dummy',
        'sender': 'dummy',
        'senderItemId': 'dummy',
        'senderItemTitle': 'dummy',
        'timestamp': 'dummy',
      });

      print('User profile created');
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<bool> checkUserExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final myuser = userCredential.user;
        if (myuser != null) {
          final email = myuser.email;
          final userExists = await checkUserExists(email!);
          if (userExists) {
            final UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            _currentUser = userCredential.user;
            print('User already registered');
          } else {
            print('User uid ${myuser.uid}');
            await createGoogleProfile(myuser.uid, email);
          }
        }
      } else {
        print('Google Sign-In failed or cancelled.');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  bool get isLoggedIn => _currentUser != null;

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
