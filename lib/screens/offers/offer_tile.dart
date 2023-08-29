import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:garden_companion_2/models/offers.dart';

class BlogTile extends StatelessWidget {
  final Offer blogItem;

  const BlogTile({super.key, required this.blogItem});

  Future<void> deleteOffer(Offer item) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final uid = currentUser.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items')
        .doc(item.itemId)
        .delete();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.network(
              blogItem.imageUrl.isNotEmpty
                  ? blogItem.imageUrl
                  : "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdummy-post-horisontal-thegem-blog-default.jpg?alt=media&token=34f778d3-d19f-4cb9-9fb4-ec7398c4983a",
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        blogItem.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "By ${blogItem.author}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                 FirebaseAuth.instance.currentUser!.uid != blogItem.originaluid
                      ? const SizedBox.shrink()
                      : Positioned(
                          top: -13,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await deleteOffer(blogItem);

                              Fluttertoast.showToast(
                                  msg: "Offer deleted",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green[300],
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
