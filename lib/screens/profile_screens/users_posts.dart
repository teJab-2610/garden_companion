import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/profile_screens/post_album.dart';

import '../../models/post.dart';
import '../../providers/post_provider.dart';

class UsersPosts extends StatefulWidget {
  final String userId;
  UsersPosts({required this.userId});
  @override
  _UsersPostsState createState() => _UsersPostsState();
}

class _UsersPostsState extends State<UsersPosts> {
  late Future<List<Post>> _fetchPostsFuture;
  bool isFollowing = true;

  @override
  void initState() {
    super.initState();
    _fetchPostsFuture = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    print("here ${widget.userId}");
    try {
      List<Post> posts = [];
      print("here ${widget.userId}");
      final postsQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('posts')
          .get();
      print(postsQuerySnapshot.docs[0].data());
      List<String> uids = postsQuerySnapshot.docs.map((doc) => doc.id).toList();
      for (String uid in uids) {
        if (uid == 'dummy') {
          continue;
        }
        final postSnapshot =
            await FirebaseFirestore.instance.collection('posts').doc(uid).get();
        final post = Post.fromJson(postSnapshot.data()!);
        posts.add(post);
      }
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return posts;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: FutureBuilder<List<Post>>(
          future: _fetchPostsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching posts'));
            } else {
              return _buildBody(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody(List<Post> posts) {
    if (!isFollowing) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 40.0, left: 16.0), // Added top padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _fetchPostsFuture = _fetchPosts();
                          });
                        },
                        icon: Icon(Icons.refresh),
                      ),
                      SizedBox(width: 8.0),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'My Posts',
                              style: TextStyle(
                                color: Color.fromRGBO(76, 175, 80, 1),
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (posts.isEmpty) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 40.0, left: 16.0), // Added top padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _fetchPostsFuture = _fetchPosts();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 8.0),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Posts',
                              style: TextStyle(
                                color: Color.fromRGBO(76, 175, 80, 1),
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'No posts to show',
                  style: TextStyle(
                      color: Color.fromARGB(255, 212, 66, 66),
                      fontSize: 16.0,
                      fontFamily: 'Sf'),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Posts',
                          style: TextStyle(
                              color: Color.fromRGBO(76, 175, 80, 1),
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _fetchPostsFuture = _fetchPosts();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PostTile(post: posts[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
