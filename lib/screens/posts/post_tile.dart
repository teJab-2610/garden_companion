import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/posts/singlepost_screen.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';

class BlogTile extends StatelessWidget {
  final Post blogItem;

  const BlogTile({super.key, required this.blogItem});

  void printer() {
    if (blogItem.images.isNotEmpty) print(blogItem.images[0]);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).userProfile;
    const iconColor = Color(0xFF5B8E55); // ARGB(255, 91, 142, 85)
    printer();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogContentPage(blogItem: blogItem),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.network(
              //take first image
              blogItem.images.isNotEmpty
                  ? blogItem.images[0]
                  : "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdummy-post-horisontal-thegem-blog-default.jpg?alt=media&token=34f778d3-d19f-4cb9-9fb4-ec7398c4983a",
              height: 150, // Adjust the height as needed
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        blogItem.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          fontFamily: 'Sf',
                        ),
                        maxLines: 2, // Limit to two lines of text
                        overflow: TextOverflow
                            .ellipsis, // Show ellipsis if text overflows
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            PostProvider()
                                .likePost(blogItem.postId, currentUser);
                          },
                          icon: const Icon(
                            Icons.thumb_up,
                            color: iconColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            PostProvider()
                                .removeLike(blogItem.postId, currentUser);
                          },
                          icon: const Icon(
                            Icons.thumb_down,
                            color: iconColor,
                          ),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     // Handle comment button press
                        //   },
                        //   icon: Icon(
                        //     Icons.comment,
                        //     color: iconColor,
                        //   ),
                        // ),
                        IconButton(
                          onPressed: () {
                            PostProvider()
                                .savePost(blogItem.postId, currentUser);
                          },
                          icon: const Icon(
                            Icons.bookmark,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  "By ${blogItem.username}",
                  style: const TextStyle(color: Colors.grey, fontFamily: 'Sf'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
