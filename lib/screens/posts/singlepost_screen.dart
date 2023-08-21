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
                height: 200, // Adjust the height as needed
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.blogItem.images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Image.network(
                      widget.blogItem.images[index],
                      fit: BoxFit.cover,
                    );
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
                          widget.blogItem.images.length - 1) {
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
                "By ${widget.blogItem.postId}",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                widget.blogItem.text,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      PostProvider()
                          .likePost(widget.blogItem.postId, currentUser);
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      PostProvider()
                          .removeLike(widget.blogItem.postId, currentUser);
                    },
                    icon: Icon(
                      Icons.thumb_down,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // PostProvider.addComment(
                      //     widget.blogItem.postId, );
                    },
                    icon: Icon(
                      Icons.comment,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      PostProvider()
                          .savePost(widget.blogItem.postId, currentUser);
                    },
                    icon: Icon(
                      Icons.bookmark,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
