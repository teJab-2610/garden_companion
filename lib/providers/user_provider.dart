import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  final User _currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  late FirebaseFirestore _firestore;

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

  Future<bool> isFollowingUser(String userId) async {
    print('inside isFollowingUser ${userId}');
    try {
      DocumentSnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .collection('following')
          .doc(userId)
          .get();

      return followingSnapshot.exists;
    } catch (e) {
      print('Error checking if user is following: $e');
      return false;
    }
  }

  Future<void> updateFollowerCount(String userId, bool increment) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.update({
        'followerCount': FieldValue.increment(increment ? 1 : -1),
      });

      print('Follower count updated successfully');

      // Notify listeners that the follower count has changed
      notifyListeners();
    } catch (e) {
      print('Error updating follower count: $e');
    }
  }

  Future<void> updateFollowingCount(String userId, bool increment) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.update({
        'followingCount': FieldValue.increment(increment ? 1 : -1),
      });
      print('Follower count updated successfully');
      notifyListeners();
    } catch (e) {
      print('Error updating follower count: $e');
    }
  }

  Future<void> followUser(String otherID) async {
    print('inside followUser ${otherID}');
    try {
      User? currentUser = _auth.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('following')
          .doc(otherID)
          .set({'userId': otherID});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherID)
          .collection('followers')
          .doc(currentUser.uid)
          .set({'userId': currentUser.uid});

      await updateFollowingCount(currentUser.uid, true);
      await updateFollowerCount(otherID, true);
    } catch (e) {
      print('Error following user: $e');
    }
  }

  Future<void> unFollowing(String otherID) async {
    print('inside unFollowing ${otherID}');
    try {
      User? currentUser = _auth.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('following')
          .doc(otherID)
          .delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherID)
          .collection('followers')
          .doc(currentUser.uid)
          .delete();

      print('Followed user successfully');
      await updateFollowingCount(currentUser.uid, false);
      await updateFollowerCount(otherID, false);
    } catch (e) {
      print('Error following user: $e');
    }
  }

  Future<void> loadUserDataFromSharedPreferences() async {
    _initPreferences();
  }
}
