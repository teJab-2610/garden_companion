import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  String? _userId;
  String? _email;
  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;

  String? get userId => _userId;
  String? get email => _email;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  int get postsCount => _postsCount;

  UserProvider() {
    _initPreferences();
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString('userId');
    _email = _prefs.getString('email');
    _followersCount = _prefs.getInt('followersCount') ?? 0;
    _followingCount = _prefs.getInt('followingCount') ?? 0;
    _postsCount = _prefs.getInt('postsCount') ?? 0;
    notifyListeners();
  }

  Future<void> registerUser(String userId, String email) async {
    _userId = userId;
    _email = email;

    await _prefs.setString('userId', userId);
    await _prefs.setString('email', email);
    await _prefs.setInt('followersCount', _followersCount);
    await _prefs.setInt('followingCount', _followingCount);
    await _prefs.setInt('postsCount', _postsCount);

    notifyListeners();
  }

  Future<void> updateUserCounts(
      {int? followers, int? following, int? posts}) async {
    if (followers != null) {
      _followersCount = followers;
      await _prefs.setInt('followersCount', _followersCount);
    }
    if (following != null) {
      _followingCount = following;
      await _prefs.setInt('followingCount', _followingCount);
    }
    if (posts != null) {
      _postsCount = posts;
      await _prefs.setInt('postsCount', _postsCount);
    }

    notifyListeners();
  }

  Future<void> addFollower(String followerUserId) async {
    try {
      final currentUser = _auth.currentUser!;
      final userDocRef = _firestore.collection('users').doc(currentUser.uid);
      final followerUserDocRef =
          _firestore.collection('users').doc(followerUserId);

      // Add follower's data to the user's followers subcollection
      await userDocRef.collection('followers').doc(followerUserId);

      // Update the user's followers count
      _followersCount++;
      await _prefs.setInt('followersCount', _followersCount);

      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> unfollowUser(String followerUserId) async {
    try {
      final currentUser = _auth.currentUser!;
      final userDocRef = _firestore.collection('users').doc(currentUser.uid);

      // Remove follower's data from the user's followers subcollection
      await userDocRef.collection('followers').doc(followerUserId).delete();

      // Update the user's followers count
      _followersCount--;
      await _prefs.setInt('followersCount', _followersCount);

      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> loadUserDataFromSharedPreferences() async {
    _initPreferences();
  }
}
