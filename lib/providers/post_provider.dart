import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final prefs = SharedPreferences.getInstance();
  final int batchSize = 10;
  final List<Post> _posts = [];
  List<Post> get posts => _posts;

  // Future<List<Post>> fetchUserPosts(String userId) async {
  //   try {
  //     final userPostQuerySnapshot = await _firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection('userPosts')
  //         .get();

  //     final postIds = userPostQuerySnapshot.docs
  //         .map((doc) => doc['postId'] as String)
  //         .toList();

  //     final postsQuerySnapshot = await _firestore
  //         .collection('posts')
  //         .where(FieldPath.documentId, whereIn: postIds)
  //         .get();

  //     final userPosts = postsQuerySnapshot.docs
  //         .map((doc) => Post.fromJson(doc.data()))
  //         .toList();
  //     return userPosts;
  //   } catch (error) {
  //     print('Error fetching user posts: $error');
  //     return [];
  //   }
  // }

  Future<List<Post>> fetchUserPosts(
      String userId, String lastFetchedPostId) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .limit(batchSize);

      if (lastFetchedPostId.isNotEmpty) {
        final lastFetchedPostDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('userPosts')
            .doc(lastFetchedPostId)
            .get();

        query = query.startAfterDocument(lastFetchedPostDoc);
      }

      final userPostQuerySnapshot = await query.get();

      final postIds = userPostQuerySnapshot.docs
          .map((doc) => doc['postId'] as String)
          .toList();

      final postsQuerySnapshot = await _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: postIds)
          .get();

      final userPosts = postsQuerySnapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
      return userPosts;
    } catch (error) {
      print('Error fetching user posts: $error');
      return [];
    }
  }

  Future<List<Post>> fetchFollowingPosts(List<String> followingUserIds) async {
    try {
      final postsQuerySnapshot = await _firestore
          .collection('posts')
          .where('uid', whereIn: followingUserIds)
          .orderBy('timestamp', descending: true)
          .limit(batchSize)
          .get();
      print('postsQuerySnapshot.docs.length ${postsQuerySnapshot.docs.length}');

      for (var element in postsQuerySnapshot.docs) {
        print('element.id ${element.id}');
        print('element.data() ${element.data()}');
      }
      final newPosts = postsQuerySnapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
      print('new posts line done');
      // Sort the new posts by their timestamps in ascending order
      newPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      print('new posts sort done');
      return newPosts;
    } catch (error) {
      print('Error fetching following posts: $error');
      return [];
    }
  }

  Future<void> saveToPreferences(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value.toString());
    } catch (error) {
      print('Error saving to preferences: $error');
    }
  }

  Future<void> addPost(Post newPost, MyUser currentUser) async {
    try {
      print('step one done');
      // Add the new post to Firestore
      final postDocRef =
          await _firestore.collection('posts').add(newPost.toJson());
      print('step two done');
      print('currentuser : ${currentUser.uid}');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('posts')
          .doc(postDocRef.id)
          .set({'postId': postDocRef.id});
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postDocRef.id)
          .update({'postId': postDocRef.id});

      print('step four done');
      //create a subcollection for comments with fields text timestamp userid and replies subcollection with emplty values for now
      final commentRef = _firestore
          .collection('posts')
          .doc(postDocRef.id)
          .collection('comments')
          .doc();
      await commentRef.set({
        'text': '',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': '',
        'replies': [],
      });
      print('step six done');
      // Update locally and in preferences
      newPost = newPost.copyWith(postId: postDocRef.id);
      _posts.add(newPost);
      //update local preferences without setString
      await saveToPreferences('postsCount', currentUser.postsCount + 1);

      notifyListeners();
    } catch (error) {
      print('Error adding post: $error');
    }
  }

  Future<void> likePost(String postId, MyUser currentUser) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final likes = List<String>.from(postSnapshot['likes']);

        if (!likes.contains(currentUser.username)) {
          likes.add(currentUser.username);
          await postRef.update({'likes': likes});
          await postRef.update({'likesCount': FieldValue.increment(1)});
        } else {
          alreadyliked();
        }
      }
      notifyListeners();
    } catch (error) {
      print('Error liking post: $error');
    }
  }

  Future<void> removeLike(String postId, MyUser currentUser) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();
      if (postSnapshot.exists) {
        final likes = List<String>.from(postSnapshot['likes']);
        if (likes.contains(currentUser.username)) {
          likes.remove(currentUser.username);
          await postRef.update({'likes': likes});
          await postRef.update({'likesCount': FieldValue.increment(-1)});
        }
      } else {
        alreadyRemoved();
      }
    } catch (error) {
      print('Error removing like: $error');
    }
  }

  void alreadyliked() {
    Fluttertoast.showToast(
      msg: "Already Liked By You",
      toastLength:
          Toast.LENGTH_SHORT, // Duration for which the toast will be displayed
      gravity: ToastGravity.BOTTOM, // Position of the toast
      backgroundColor: Colors.grey[600], // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
  }

  void alreadyRemoved() {
    Fluttertoast.showToast(
      msg: "Like Removed",
      toastLength:
          Toast.LENGTH_SHORT, // Duration for which the toast will be displayed
      gravity: ToastGravity.BOTTOM, // Position of the toast
      backgroundColor: Colors.grey[600], // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
  }

  Future<void> addComment(
      String postId, String commentText, MyUser currentUser) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();
      await commentRef.set({
        'username': currentUser.username,
        'text': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await postRef.update({
        'commentsCount': FieldValue.increment(1),
      });
      notifyListeners();
    } catch (error) {
      print('Error adding comment: $error');
    }
  }

  Future<void> editPost(
      String postId, String newText, MyUser currentUser) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final authorId = postSnapshot['authorId'];
        if (authorId == currentUser.username) {
          await postRef.update({'text': newText});
          notifyListeners();
        } else {
          print('You are not authorized to edit this post.');
        }
      } else {
        print('Post does not exist.');
      }
    } catch (error) {
      print('Error editing post: $error');
    }
  }

  //   Future<void> editPost(String postId, String newText, Map<String, String> newImages, MyUser currentUser) async {
  //   try {
  //     final postRef = _firestore.collection('posts').doc(postId);
  //     final postSnapshot = await postRef.get();

  //     if (postSnapshot.exists) {
  //       final authorId = postSnapshot['authorId']; // Assuming authorId is stored in the post document

  //       if (authorId == currentUser.userId) {
  //         // Update text and images
  //         final Map<String, dynamic> updateData = {
  //           'text': newText,
  //           'images': newImages,
  //         };

  //         await postRef.update(updateData);

  //         // Notify listeners of the change
  //         notifyListeners();
  //       } else {
  //         print('You are not authorized to edit this post.');
  //       }
  //     } else {
  //       print('Post does not exist.');
  //     }
  //   } catch (error) {
  //     print('Error editing post: $error');
  //   }
  // }
  Future<void> savePost(String postId, MyUser currentUser) async {
    try {
      final userRef = _firestore.collection('users').doc(currentUser.uid);
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        final bookmarks = List<String>.from(userSnapshot['bookmarks']);
        if (!bookmarks.contains(postId)) {
          bookmarks.add(postId);
          await userRef.update({'bookmarks': bookmarks});
          alreadyBookmarked();
        } else {
          bookmarks.remove(postId);
          await userRef.update({'bookmarks': bookmarks});
          removedBookmark();
        }
      }
      notifyListeners();
    } catch (error) {
      print('Error saving post: $error');
    }
  }

  void alreadyBookmarked() {
    Fluttertoast.showToast(
      msg: "Bookmarked This Post",
      toastLength:
          Toast.LENGTH_SHORT, // Duration for which the toast will be displayed
      gravity: ToastGravity.BOTTOM, // Position of the toast
      backgroundColor: Colors.grey[600], // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
  }

  void removedBookmark() {
    Fluttertoast.showToast(
      msg: "Removed Bookmark!",
      toastLength:
          Toast.LENGTH_SHORT, // Duration for which the toast will be displayed
      gravity: ToastGravity.BOTTOM, // Position of the toast
      backgroundColor: Colors.grey[600], // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
  }

  Future<void> deletePost(String postId, MyUser currentUser) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final authorId = postSnapshot[
            'postId']; // Assuming authorId is stored in the post document

        if (authorId == currentUser.username) {
          await postRef.delete();

          // Notify listeners of the change
          notifyListeners();
        } else {
          print('You are not authorized to delete this post.');
        }
      } else {
        print('Post does not exist.');
      }
    } catch (error) {
      print('Error deleting post: $error');
    }
  }
}
