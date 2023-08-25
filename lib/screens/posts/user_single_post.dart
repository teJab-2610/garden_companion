import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
//import post provider
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';

class BlogContentPage extends StatefulWidget {
  final Post blogItem;

  BlogContentPage({required this.blogItem});

  @override
  _BlogContentPageState createState() => _BlogContentPageState();
}

class _BlogContentPageState extends State<BlogContentPage> {
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
