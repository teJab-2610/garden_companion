import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garden_companion_2/screens/profile_screens/users_posts.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/user_provider.dart';
import 'Theme.dart';
import 'drawer.dart';

class OtherAccountPage extends StatefulWidget {
  final String userId;
  const OtherAccountPage({super.key, required this.userId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<OtherAccountPage> {
  User? _user;
  late Stream<DocumentSnapshot> _userStream;
  List<Post> _userPosts = [];
  bool _postsFetched = false;
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();
  }

  Future<void> followUser(String otherID, UserProvider userProvider) async {
    print(otherID);
    bool isFollowing = await userProvider.isFollowingUser(otherID);
    if (isFollowing) {
      _showToast(context, "Already Following User");
    } else {
      await userProvider.followUser(otherID);
    }
    setState(() {});
  }

  Future<void> unfollowUser(String otherID, UserProvider userProvider) async {
    print(otherID);
    bool isFollowing = await userProvider.isFollowingUser(otherID);
    print(isFollowing);
    if (!isFollowing) {
      _showToast(context, "Not Following User");
    } else {
      await userProvider.unFollowing(otherID);
    }
    setState(() {});
  }

  //show toast
  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text("Photographer",
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
                                                          fontFamily: 'Sf')),
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
                                                              FontWeight.bold,
                                                          fontFamily: 'Sf')),
                                                  Text(
                                                    "Posts",
                                                    style: TextStyle(
                                                        color: NowUIColors.white
                                                            .withOpacity(0.8),
                                                        fontSize: 12.0,
                                                        fontFamily: 'Sf'),
                                                  )
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
                          padding: EdgeInsets.only(
                              left: 32.0, right: 32.0, top: 42.0),
                          child: Column(children: [
                            Text("About me",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 91, 142, 85),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.0,
                                    fontFamily: 'Sf')),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 24.0, right: 24, top: 30, bottom: 24),
                              child: Text("${userData['bio']}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: NowUIColors.time)),
                            ),
                            // PostsAlbum(posts: _userPosts),
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
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              //color
                              style: ElevatedButton.styleFrom(
                                primary: NowUIColors.defaultColor,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              onPressed: () {
                                followUser(widget.userId, userProvider);
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 10,
                                      bottom: 10),
                                  child: Text(
                                    "Follow",
                                    style: TextStyle(
                                        fontSize: 13.0, fontFamily: 'Sf'),
                                  )),
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
                                unfollowUser(widget.userId, userProvider);
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 10,
                                      bottom: 10),
                                  child: Text("Unfollow",
                                      style: TextStyle(
                                          fontSize: 13.0, fontFamily: 'Sf'))),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
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
                                    builder: (context) =>
                                        UsersPosts(userId: widget.userId),
                                  ),
                                );
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 10,
                                      bottom: 10),
                                  child: Text("Posts",
                                      style: TextStyle(
                                          fontSize: 13.0, fontFamily: 'Sf'))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }));
  }
}
