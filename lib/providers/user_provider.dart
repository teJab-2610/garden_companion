import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_companion_2/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  final User _currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  late FirebaseFirestore _firestore;

  MyUser _userProfile = MyUser(
    username: '',
    email: '',
    followersCount: 0,
    followingCount: 0,
    postsCount: 0,
    password: '',
    phoneNumber: '',
  );
  MyUser get userProfile => _userProfile; // Add this getter

  UserProvider() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = _prefs.getString('userId') ?? '';
    final email = _prefs.getString('email') ?? '';
    final followersCount = _prefs.getInt('followersCount') ?? 0;
    final followingCount = _prefs.getInt('followingCount') ?? 0;
    final postsCount = _prefs.getInt('postsCount') ?? 0;

    _userProfile = MyUser(
      username: userId,
      email: email,
      followersCount: followersCount,
      followingCount: followingCount,
      postsCount: postsCount,
      password: '',
      phoneNumber: '',
    );

    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        final int followersCount = userDoc['followersCount'];
        final int followingCount = userDoc['followingCount'];
        final int postsCount = userDoc['postsCount'];

        _userProfile = MyUser(
          username: currentUser.uid,
          email: currentUser.email!,
          followersCount: followersCount,
          followingCount: followingCount,
          postsCount: postsCount,
          password: '',
          phoneNumber: '',
        );

        // Update shared preferences
        await _prefs.setString('userId', currentUser.uid);
        await _prefs.setString('email', currentUser.email!);
        await _prefs.setInt('followersCount', followersCount);
        await _prefs.setInt('followingCount', followingCount);
        await _prefs.setInt('postsCount', postsCount);

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> registerUser(
    String userId,
    String email,
    String username, // Add this parameter
  ) async {
    _userProfile = MyUser(
      username: userId,
      email: email,
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      password: '',
      phoneNumber: '',
    );

    await _saveUserDataToPreferences();
    notifyListeners();
  }

  Future<void> _saveUserDataToPreferences() async {
    await _prefs.setString('userId', _userProfile.username);
    await _prefs.setString('email', _userProfile.email);
    await _prefs.setInt('followersCount', _userProfile.followersCount);
    await _prefs.setInt('followingCount', _userProfile.followingCount);
    await _prefs.setInt('postsCount', _userProfile.postsCount);
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
