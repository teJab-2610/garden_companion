// import 'package:flutter/material.dart';
// import '../../models/post.dart';
// import 'Theme.dart';

// class UserDetails {
//   final String username;
//   final int followersCount;
//   final int followingCount;
//   final String bio;
//   final List<String> posts;

//   UserDetails({
//     required this.username,
//     required this.followersCount,
//     required this.followingCount,
//     required this.bio,
//     required this.posts,
//   });
// }

// class PostsAlbum extends StatelessWidget {
//   final List<Post> posts;

//   PostsAlbum({required this.posts});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "My Posts",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color.fromARGB(255, 91, 142, 85),
//             fontSize: 25.0,
//           ),
//         ),
//         SizedBox(height: 10),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: posts.length,
//           itemBuilder: (context, index) {
//             return PostTile(post: posts[index]);
//           },
//         ),
//       ],
//     );
//   }
// }

// class PostTile extends StatelessWidget {
//   final Post post;

//   PostTile({required this.post});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: NowUIColors.bgColorScreen,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.network(
//             post.images.isEmpty
//                 ? "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdefault_images.png?alt=media&token=fb48e8c4-e06c-4350-ab43-9c7b5fe4435b"
//                 : post.images[0],
//             height: 120,
//             width: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           SizedBox(height: 10),
//           Text(
//             post.title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             "By ${post.username}",
//             style: TextStyle(
//               color: NowUIColors.text.withOpacity(0.8),
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import 'Theme.dart';

class UserDetails {
  final String username;
  final int followersCount;
  final int followingCount;
  final String bio;
  final List<String> posts;

  UserDetails({
    required this.username,
    required this.followersCount,
    required this.followingCount,
    required this.bio,
    required this.posts,
  });
}

class PostsAlbum extends StatelessWidget {
  final List<Post> posts;

  PostsAlbum({required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Posts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 91, 142, 85),
            fontSize: 25.0,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            if (posts.isEmpty) {
              return const Center(child: Text("No Posts Yet"));
            } else {
              return PostTile(post: posts[index]);
            }
          },
        ),
      ],
    );
  }
}

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePostScreen(blogItem: post),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NowUIColors.bgColorScreen,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              child: Image.network(
                //take first image
                post.images.isNotEmpty
                    ? post.images[0]
                    : "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdummy-post-horisontal-thegem-blog-default.jpg?alt=media&token=34f778d3-d19f-4cb9-9fb4-ec7398c4983a",
                height: 150, // Adjust the height as needed
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              post.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Sf'),
            ),
            SizedBox(height: 5),
            Text(
              "By ${post.username}",
              style: TextStyle(
                  color: NowUIColors.text.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Sf'),
            ),
          ],
        ),
      ),
    );
  }
}

// class SinglePostScreen extends StatelessWidget {
//   final Post post;

//   SinglePostScreen({required this.post});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Post Details'),
//       ),
//       body: Column(
//         children: [
//           Image.network(
//             post.images.isNotEmpty
//                 ? post.images[0]
//                 : "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdefault_images.png?alt=media&token=fb48e8c4-e06c-4350-ab43-9c7b5fe4435b",
//             height: 300,
//             width: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           SizedBox(height: 10),
//           Text(
//             post.title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "By ${post.username}",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: 20),
//           Text(
//             post.text,
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }

class SinglePostScreen extends StatefulWidget {
  final Post blogItem;

  SinglePostScreen({required this.blogItem});

  @override
  _BlogContentPageState createState() => _BlogContentPageState();
}

class _BlogContentPageState extends State<SinglePostScreen> {
  late PageController _pageController;
  List<String> defaultImages = [
    "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdummy-post-horisontal-thegem-blog-default.jpg?alt=media&token=34f778d3-d19f-4cb9-9fb4-ec7398c4983a",
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Color(0xFF5B8E55); // ARGB(255, 91, 142, 85)
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).userProfile;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 40.0), // Adjust the top margin as needed
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slideshow of images
              SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.blogItem.images.isNotEmpty
                      ? widget.blogItem.images.length
                      : 1, // Set itemCount to 1 for default image
                  itemBuilder: (BuildContext context, int index) {
                    if (widget.blogItem.images.isNotEmpty) {
                      return Image.network(
                        widget.blogItem.images[index],
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.network(
                        defaultImages[0], // Use the default image URL
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 16.0),
// Right and Left Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_pageController.page != 0) {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_pageController.page !=
                          (widget.blogItem.images.isNotEmpty
                                  ? widget.blogItem.images.length
                                  : 1) -
                              1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              Text(
                widget.blogItem.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                "By ${widget.blogItem.username}",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await PostProvider()
                          .likePost(widget.blogItem.postId, currentUser);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      color: iconColor,
                    ),
                  ),
                  FutureBuilder<int>(
                    future:
                        PostProvider().getLikesCount(widget.blogItem.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error loading likes');
                      } else {
                        final likesCount = snapshot.data ?? 0;
                        return Text('$likesCount likes');
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      await PostProvider()
                          .removeLike(widget.blogItem.postId, currentUser);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.thumb_down,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      PostProvider().savePost(widget.blogItem.postId);
                    },
                    icon: Icon(
                      Icons.bookmark,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        //show circular progress indicator until deleted and show toast message deleted sucessfully
                        PostProvider()
                            .deletePost(widget.blogItem.postId, currentUser);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post deleted successfully'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: iconColor,
                      ))
                ],
              ),
              Text(
                widget.blogItem.text,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
