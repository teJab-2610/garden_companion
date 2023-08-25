import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:garden_companion_2/screens/home/search_screen.dart';
import 'package:garden_companion_2/screens/home/splash_screen.dart';
import 'package:garden_companion_2/screens/offers/offers_list.dart';
import 'package:garden_companion_2/screens/posts/create_post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garden_companion_2/screens/plant_health/imagesearchscreens.dart';
import 'package:garden_companion_2/screens/plant_searcher/plant_search.dart';
import '../groups/groups_page.dart';
import '../posts/posts_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garden_companion_2/screens/profile_screens/Theme.dart';
import 'package:garden_companion_2/screens/profile_screens/drawer.dart';
import '../../models/post.dart';
import 'bioedit.dart';
import 'bookmarks.dart';
import 'users_posts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  late Stream<DocumentSnapshot> _userStream;
  bool _isExpanded = false;
  TextEditingController _bioController = TextEditingController();
  List<Post> _userPosts = [];
  bool _postsFetched = false;
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .snapshots();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      final postsCollection = userDataSnapshot.reference.collection('posts');
      final postsQuerySnapshot = await postsCollection.get();
      final List<String> postUids =
          postsQuerySnapshot.docs.map((post) => post.id).toList();
      _userPosts.clear();
      for (String postUid in postUids) {
        if (postUid == 'dummy') {
          continue;
        }
        final postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postUid)
            .get();

        if (postSnapshot.exists) {
          final postData = postSnapshot.data() as Map<String, dynamic>;
          _userPosts.add(Post.fromJson(postData));
        }
      }
      postUids.clear();
    } catch (error) {
      print('Error fetching posts: $error');
    }
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SplashScreen()));

    // Clear route history
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false);
  }

  void _navigateToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _navigateToGroupsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsPage()),
    );
  }

  void _navigateToPostsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostsScreen()),
    );
  }

  void _navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPostScreen()),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _toggleExpansion,
      child: _isExpanded ? Icon(Icons.close) : Icon(Icons.menu),
      backgroundColor:
          _isExpanded ? Colors.red : Color.fromARGB(255, 91, 142, 85),
    );
  }

  Widget _buildExpandedIcons() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? 100 : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: _isExpanded,
            child: IconButton(
              icon: Image.asset(
                'assets/images/user_search.png',
                width: 25,
                height: 25,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
          ),
          Visibility(
            visible: _isExpanded,
            child: IconButton(
              icon: Image.asset(
                'assets/images/gc.png',
                width: 30,
                height: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupsPage()),
                );
              },
            ),
          ),
          Visibility(
            visible: _isExpanded,
            child: IconButton(
              icon: Image.asset(
                'assets/images/logout.png',
                width: 25,
                height: 25,
              ),
              onPressed: () {
                _logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildExpandedIcons(),
            SizedBox(height: 16),
            _buildFloatingActionButton(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          selectedItemColor: const Color.fromARGB(255, 43, 114, 7),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/profile.png',
                width: 30,
                height: 30,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/plant_search.png',
                width: 25,
                height: 25,
              ),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/camera.png',
                width: 25,
                height: 25,
              ),
              label: 'blog',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/blog.png',
                width: 25,
                height: 25,
              ),
              label: 'blog',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/vegetable.png',
                width: 25,
                height: 25,
              ),
              label: 'vegetable',
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlantSearchScreen()),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageSearchScreen()),
              );
            }
            if (index == 3) {
              _navigateToPostsPage(context);
            }
            if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OffersList()),
              );
            }
          },
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: NowUIColors.bgColorScreen,
        drawer: NowDrawer(currentPage: "Profile"),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text('User data not found.'),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              print(userData['bio']);
              return Stack(
                children: <Widget>[
                  Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/images/bg.jpg"),
                                    fit: BoxFit.cover)),
                            child: Stack(
                              children: <Widget>[
                                SafeArea(
                                  bottom: false,
                                  right: false,
                                  left: false,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0),
                                    child: Column(
                                      children: [
                                        const CircleAvatar(
                                          radius: 70,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'assets/images/b2.png'),
                                            radius: 65,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 24.0),
                                          child: Text("${userData['name']}",
                                              style: const TextStyle(
                                                  color: NowUIColors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 22,
                                                  fontFamily: 'Sf')),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text("${userData['userId']}",
                                              style: TextStyle(
                                                  color: NowUIColors.white
                                                      .withOpacity(0.85),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Sf')),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 24.0, left: 42, right: 32),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "${userData['followingCount']}",
                                                      style: const TextStyle(
                                                          color:
                                                              NowUIColors.white,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'Sf')),
                                                  Text("Following",
                                                      style: TextStyle(
                                                          color: NowUIColors
                                                              .white
                                                              .withOpacity(0.8),
                                                          fontSize: 12.0,
                                                          fontFamily: 'Sf'))
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${userData['followersCount']}",
                                                    style: const TextStyle(
                                                        color:
                                                            NowUIColors.white,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Sf'),
                                                  ),
                                                  Text("Followers",
                                                      style: TextStyle(
                                                          color: NowUIColors
                                                              .white
                                                              .withOpacity(0.8),
                                                          fontSize: 12.0,
                                                          fontFamily: 'Sf'))
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "${userData['postsCount']}",
                                                      style: const TextStyle(
                                                          color:
                                                              NowUIColors.white,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text("Posts",
                                                      style: TextStyle(
                                                          color: NowUIColors
                                                              .white
                                                              .withOpacity(0.8),
                                                          fontSize: 12.0))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                            child: SingleChildScrollView(
                                child: Padding(
                          padding: const EdgeInsets.only(
                              left: 32.0, right: 32.0, top: 42.0),
                          child: Column(children: [
                            const Text("About me",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 91, 142, 85),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.0,
                                    fontFamily: 'Sf')),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24, top: 30, bottom: 24),
                              child: Text("${userData['bio']}",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 91, 142, 85),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Sf')),
                            ),
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BioEdit(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit,
                                    color: Colors.black, size: 20.0)),
                          ]),
                        ))),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 10, bottom: 10),
                            child: ElevatedButton(
                              //color
                              style: ElevatedButton.styleFrom(
                                primary: NowUIColors.white,
                                onPrimary: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              onPressed: () {
                                // Respond to button press
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookmarksScreen(),
                                  ),
                                );
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 10,
                                      bottom: 10),
                                  child: Text("Bookmarks",
                                      style: TextStyle(
                                          fontSize: 13.0, fontFamily: 'Sf'))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 10, bottom: 10),
                            child: ElevatedButton(
                              //color
                              style: ElevatedButton.styleFrom(
                                primary: NowUIColors.white,
                                onPrimary: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UsersPosts(userId: userData['uid']),
                                  ),
                                );
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 10,
                                      bottom: 10),
                                  child: Text(
                                    "Posts",
                                    style: TextStyle(
                                        fontSize: 13.0, fontFamily: 'Sf'),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}
