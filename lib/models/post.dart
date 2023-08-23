import 'package:cloud_firestore/cloud_firestore.dart';
import 'comments.dart';

class Post {
  final String uid;
  final String postId;
  final String userId;
  final String username;
  int likesCount;
  int commentsCount;
  final String title;
  final String text;
  List<String> images;
  List<String> likes;
  final Timestamp timestamp;

  Post({
    required this.uid,
    required this.postId,
    required this.userId,
    required this.likesCount,
    required this.username,
    required this.commentsCount,
    required this.title,
    required this.text,
    required this.images,
    required this.likes,
    required this.timestamp,
  });

  Post copyWith({
    String? uid,
    String? postId,
    String? userId,
    int? likesCount,
    String? username,
    int? commentsCount,
    String? title,
    String? text,
    List<String>? images,
    List<String>? likes,
  }) {
    return Post(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      title: title ?? this.title,
      text: text ?? this.text,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      timestamp: timestamp,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    // final commentsData = json['comments'] as List<dynamic>;
    // final commentsList = commentsData
    //     .map((commentData) => Comment.fromJson(commentData))
    //     .toList();

    print('uid: ${json['uid']}');
    print('postId: ${json['postId']}');
    print('userId: ${json['userId']}');
    print('likesCount: ${json['likesCount']}');
    print('username: ${json['username']}');
    print('commentsCount: ${json['commentsCount']}');
    print('title: ${json['title']}');
    print('text: ${json['text']}');

    return Post(
      uid: json['uid'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      likesCount: json['likesCount'] as int,
      username: json['username'] as String,
      commentsCount: json['commentsCount'] as int,
      title: json['title'] as String,
      text: json['text'] as String,
      images: List<String>.from(json['images'] as List<dynamic>),
      likes: List<String>.from(json['likes'] as List<dynamic>),
      timestamp: json['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'postId': postId,
      'userId': userId,
      'likesCount': likesCount,
      'username': username,
      'commentsCount': commentsCount,
      'title': title,
      'text': text,
      'images': images,
      'likes': likes,
      'timestamp': timestamp,
    };
  }
}
