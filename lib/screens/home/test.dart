import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<File> selectedImages = [];
  List<String> imageURLs = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
    });
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    final storage = FirebaseStorage.instance;

    for (int i = 0; i < selectedImages.length; i++) {
      final imageFile = selectedImages[i];
      final storageReference = storage.ref().child('images/image_$i.jpg');
      final uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        final downloadURL = await storageReference.getDownloadURL();
        imageURLs.add(downloadURL);
      });
    }

    // Do something with the imageURLs array (e.g., save it to a database)

    setState(() {
      selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImages,
            child: const Text('Pick Images'),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.file(selectedImages[index]),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _uploadImages,
            child: const Text('Upload Images'),
          ),
        ],
      ),
    );
  }
}
