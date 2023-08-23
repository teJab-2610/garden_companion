import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_companion_2/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  final User _currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MyUser _userProfile = MyUser(
    uid: '',
    username: '',
    email: '',
    followersCount: 0,
    name: '',
    followingCount: 0,
    postsCount: 0,
    password: '',
    phoneNumber: '',
    bookmarks: [],
    groups: [],
    bio: '',
  );
  MyUser get userProfile => _userProfile;
  User? get currentUser => _currentUser;
  UserProvider() {
    print("inside user provider");
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    final email = _prefs.getString('email');
    print('inside _initPreferences $email');
    if (email == null) {
      await fetchUserProfile();
    } else {
      _loadUserProfile(); // Load cached data from shared preferences
    }
  }

  Future<void> _loadUserProfile() async {
    print("inside _loadUserProfile");
    _userProfile = MyUser(
      uid: _currentUser.uid,
      username: _prefs.getString('userId') ?? '',
      name: _prefs.getString('name') ?? '',
      email: _prefs.getString('email') ?? '',
      followersCount: _prefs.getInt('followersCount') ?? 0,
      followingCount: _prefs.getInt('followingCount') ?? 0,
      postsCount: _prefs.getInt('postsCount') ?? 0,
      password: '',
      phoneNumber: _prefs.getString('phoneNumber') ?? '',
      bookmarks: _prefs.getStringList('bookmarks') ?? [],
      groups: _prefs.getStringList('groups') ?? [],
      bio: _prefs.getString('bio') ?? '',
    );
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    try {
      final User currentUser = FirebaseAuth.instance.currentUser!;
      final uid = currentUser.uid;
      print(uid);
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData != null) {
        print("1");
        _userProfile = MyUser.fromJson(userData, uid);
        print("2");
        //await _saveUserDataToPreferences();
        notifyListeners();
      } else {
        throw Exception('User data not found in Firestore');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  Future<void> registerUser(
    String userId,
    String email,
    String username,
  ) async {
    _userProfile = MyUser(
      uid: _currentUser.uid,
      name: '',
      username: userId,
      email: email,
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      password: '',
      phoneNumber: '',
      bookmarks: [],
      groups: [],
      bio: '',
    );

    await _saveUserDataToPreferences();
    notifyListeners();
  }

  Future<void> _saveUserDataToPreferences() async {
    await _prefs.setString('userId', _userProfile.username);
    await _prefs.setString('email', _userProfile.email);
    await _prefs.setString('name', _userProfile.name);
    await _prefs.setInt('followersCount', _userProfile.followersCount);
    await _prefs.setInt('followingCount', _userProfile.followingCount);
    await _prefs.setInt('postsCount', _userProfile.postsCount);
    await _prefs.setStringList('bookmarks', _userProfile.bookmarks);
    await _prefs.setStringList('groups', _userProfile.groups);
    await _prefs.setString('bio', _userProfile.bio);
    await _prefs.setString('phoneNumber', _userProfile.phoneNumber);
  }

  Future<bool> isFollowingUser(String userId) async {
    print('inside isFollowingUser $userId');
    try {
      DocumentSnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('following')
          .doc(userId)
          .get();
      print(_currentUser.uid);
      return followingSnapshot.exists;
    } catch (e) {
      print('Error checking if user is following: $e');
      return false;
    }
  }

  Future<List<String>> getCommonFollowers(String userUid) async {
    List<String> commonFollowers = [];

    try {
      // Get the user's followers
      QuerySnapshot followersSnapshot = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('followers')
          .get();
      List<String> followers =
          followersSnapshot.docs.map((doc) => doc.id).toList();

      QuerySnapshot followingSnapshot = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('following')
          .get();
      List<String> following =
          followingSnapshot.docs.map((doc) => doc.id).toList();

      // Find the common followers
      for (String followerUid in followers) {
        if (following.contains(followerUid)) {
          commonFollowers.add(followerUid);
        }
      }
      notifyListeners();
    } catch (error) {
      print("Error in getting common followers: $error");
    }

    return commonFollowers;
  }

  Future<void> updateFollowerCount(String userId, bool increment) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.update({
        'followersCount': FieldValue.increment(increment ? 1 : -1),
      });
      //update preferences
      await _prefs.setInt('followersCount', _userProfile.followersCount);

      print('Follower count updated successfully');

      // Notify listeners that the follower count has changed
      notifyListeners();
    } catch (e) {
      print('Error updating follower count: $e');
    }
  }

  //method to add a post to bookmarks list
  Future<void> addPostToBookmarks(String postID) async {
    try {
      final userRef = _firestore.collection('users').doc(_currentUser.uid);
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        final bookmarks = List<String>.from(userSnapshot['bookmarks']);
        if (!bookmarks.contains(postID)) {
          bookmarks.add(postID);
          await userRef.update({'bookmarks': bookmarks});

          // Update locally and in shared preferences
          _userProfile.bookmarks = bookmarks;
          //save preferences
          await _prefs.setStringList('bookmarks', bookmarks);
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error adding post to bookmarks: $error');
    }
  }

  Future<void> updateFollowingCount(String userId, bool increment) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.update({
        'followingCount': FieldValue.increment(increment ? 1 : -1),
      });
      //update followeing preferences
      await _prefs.setInt('followingCount', _userProfile.followingCount);
      print('Follower count updated successfully');
      notifyListeners();
    } catch (e) {
      print('Error updating follower count: $e');
    }
  }

  Future<void> followUser(String otherID) async {
    print('inside followUser $otherID');
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
    print('inside unFollowing $otherID');
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
