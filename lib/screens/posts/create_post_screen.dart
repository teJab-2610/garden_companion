import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:garden_companion_2/models/post.dart';
import 'package:garden_companion_2/models/user.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import 'dart:io';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _textController = TextEditingController();
  List<File> selectedImages = [];
  List<String> imageURLs = [];
  bool _isUploading = false;
  bool _uploadError = false;

  void _navigateBack() {
    Navigator.pop(context);
  }

  void _createNewPost() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
        ),
      );
      return;
    }
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text'),
        ),
      );
      return;
    }
    print('step one done');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    print('currentUser uid: ${uid}');
    final current =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final currentUser =
        MyUser.fromJson(current.data() as Map<String, dynamic>, uid);
    final newPost = _buildNewPost(currentUser);
    print('step three done');
    // Add the post to Firebase and user's posts subcollection
    await addPostToFirebase(newPost);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'postsCount': FieldValue.increment(1)});
    print('step four done');
    _navigateBack();
  }

  Post _buildNewPost(MyUser currentUser) {
    return Post(
      uid: currentUser.uid,
      title: _titleController.text,
      text: _textController.text,
      username: currentUser.name,
      images: imageURLs,
      userId: currentUser.username,
      // Initialize comments as an empty list
      commentsCount: 0, // Initialize commentsCount
      likes: [],
      likesCount: 0,
      postId: '',
      timestamp: Timestamp.now(), // Initialize timestamp
    );
  }

  Future<void> addPostToFirebase(Post newPost) async {
    await Provider.of<PostProvider>(context, listen: false).addPost(newPost);
  }

  Widget _buildImageGridView() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == selectedImages.length) {
            return IconButton(
              icon: const Icon(Icons.add),
              onPressed: _pickImages,
            );
          }
          return Image.file(File(selectedImages[index].path));
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    try {
      final storage = FirebaseStorage.instance;
      final currentUser =
          Provider.of<UserProvider>(context, listen: false).userProfile;
      for (int i = 0; i < selectedImages.length; i++) {
        final imageFile = selectedImages[i];
        final uniqueFileName =
            '${currentUser.uid}-image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storageReference = storage.ref().child('images/$uniqueFileName');
        final uploadTask = storageReference.putFile(imageFile);

        await uploadTask.whenComplete(() async {
          final downloadURL = await storageReference.getDownloadURL();
          imageURLs.add(downloadURL);
        });
      }

      // Do something with the imageURLs array (e.g., save it to a database)
      print("Image URLs: $imageURLs");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Color(0xFF5B8E55),
                      size: 36,
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 24),
                      children: [
                        TextSpan(
                          text: 'Add new ',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'poppins'),
                        ),
                        TextSpan(
                          text: 'POST',
                          style: TextStyle(
                              color: Color(0xFF5B8E55),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        _isUploading = true; // Set this flag before uploading
                      });
                      await _uploadImages();
                      //show loading indicator while uploading images
                      try {
                        await _uploadImages();
                        // After uploading images, hide loading indicator and proceed with creating the post

                        _createNewPost();

                        // Show a success toast
                        Fluttertoast.showToast(
                          msg: 'Upload Successful',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          timeInSecForIosWeb: 3,
                        );
                      } catch (error) {
                        print('Error uploading images: $error');
                        setState(() {
                          _uploadError = true; // Set the error flag
                        });
                        Fluttertoast.showToast(
                          msg: 'Upload Failed. Please Try Again',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          timeInSecForIosWeb: 3,
                        );
                      } finally {
                        setState(() {
                          _isUploading =
                              false; // Reset the flag after uploading, whether successful or not
                        });
                      }
                    },
                    icon: _isUploading
                        ? const CircularProgressIndicator() // Show loading indicator
                        : const Icon(
                            Icons.send,
                            color: Color(0xFF5B8E55),
                            size: 36,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 118, 154, 76).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sf'),
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Enter post title...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily:
                              'Sf', // Replace 'YourCustomFont' with the actual font family name
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 118, 154, 76).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sf'),
                    ),
                    TextField(
                      controller: _textController,
                      maxLines: 11, // Increased the number of lines
                      decoration: const InputDecoration(
                        hintText: 'Enter post description...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily:
                              'Sf', // Replace 'YourCustomFont' with the actual font family name
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 60,
                width: 180, // Increase the width to fit the icon and text
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 146, 172, 152)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () {
                    _pickImages();
                  },
                  child: Row(
                    // Use a Row to place the icon and text side by side
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 197, 236, 197)
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(
                              15), // Adjust the radius to fit the circle
                        ),
                        child: const Center(
                          child: Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Add spacing between icon and text
                      const Text(
                        'Click to add pictures.',
                        style: TextStyle(fontSize: 12, fontFamily: 'Sf'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: selectedImages.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Center(
                        child: Image.file(selectedImages[index]),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: const Icon(
                            Icons.remove_circle,
                            color: Color.fromARGB(255, 71, 185, 98),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
