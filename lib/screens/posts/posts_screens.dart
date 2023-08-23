import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/posts/create_post_screen.dart';
import 'package:garden_companion_2/screens/posts/post_tile.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late int _currentPage;
  late int _pageSize; // Number of days per page
  DateTime currentDate = DateTime.now();
  late Future<List<Post>> _fetchPostsFuture;
  bool isFollowing = true;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageSize = 1; // You can adjust this to your desired page size
    _fetchPostsFuture = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final following = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    if (following.docs.length - 1 == 0) {
      isFollowing = false;
      return [];
    }
    isFollowing = true;
    print('Following uids list : ${following.docs.map((doc) => doc.id)}');
    // DateTime targetDate = DateTime.now().subtract(Duration(days: _currentPage));
    // print('Date : $targetDate');
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
    List<Post> posts = await postProvider.fetchFollowingPosts(
      following.docs.map((doc) => doc.id).toList(),
      // targetDate,
    );
    print('List of posts : ${posts.map((post) => post.title)}}');
    return posts;
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
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 8.0),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Articles on ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'poppins'),
                            ),
                            TextSpan(
                              text: 'plants',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewPostScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Follow people to see posts here.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 212, 66, 66),
                    fontSize: 16.0,
                  ),
                ),
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
                              text: 'Articles on ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'plants',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewPostScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
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
                  ),
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
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Articles on ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'plants',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewPostScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
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
                    return BlogTile(blogItem: posts[index]);
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
