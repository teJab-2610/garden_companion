import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            final previewRatio = _controller.value.previewSize!.height /
                _controller.value.previewSize!.width;

            return Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio:
                        previewRatio > deviceRatio ? previewRatio : deviceRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton(
                    onPressed: () async {
                      try {
                        final image = await _controller.takePicture();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imagePath: image.path,
                              onUpload: () {
                                // TODO: Upload the file to the server
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      final pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (pickedFile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imagePath: pickedFile.path,
                              onUpload: () {
                                // TODO: Upload the file to the server
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.photo_library),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// class ImagePreviewScreen extends StatefulWidget {
//   final String imagePath;

//   const ImagePreviewScreen(
//       {Key? key, required this.imagePath, required Null Function() onUpload})
//       : super(key: key);

//   @override
//   _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
// }

// class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
//   late XFile _imageFile;
//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     _imageFile = XFile(widget.imagePath);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Image Preview')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.file(File(_imageFile.path)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _isUploading
//                   ? null
//                   : () async {
//                       setState(() {
//                         _isUploading = true;
//                       });
//                       // TODO: Upload the file to the server
//                       setState(() {
//                         _isUploading = false;
//                       });
//                     },
//               child: _isUploading
//                   ? const CircularProgressIndicator()
//                   : const Text('Upload'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final VoidCallback onUpload;

  const ImagePreviewScreen(
      {Key? key, required this.imagePath, required this.onUpload})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Preview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(File(imagePath)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, 'retake');
                  },
                  child: Text('Retake'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    onUpload(); // Call the onUpload callback
                    Navigator.pop(context, 'upload');
                  },
                  child: Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final cameras = await availableCameras();
            final camera = cameras.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraScreen(camera: camera),
              ),
            );
          },
          child: Text('Open Camera'),
        ),
      ),
    );
  }
}
