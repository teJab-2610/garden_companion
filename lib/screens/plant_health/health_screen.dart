import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../plant_searcher/details_fetcher.dart';
import '../plant_searcher/display_details.dart';

class CameraScreen1 extends StatefulWidget {
  const CameraScreen1({Key? key}) : super(key: key);

  @override
  _CameraScreen1State createState() => _CameraScreen1State();
}

class _CameraScreen1State extends State<CameraScreen1> {
  String uploadStatus = '';

  Future<void> _getImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await sendImageToAPI(imageFile);
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await sendImageToAPI(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Upload')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _getImageFromCamera,
                  child: const Text('Pick Image from Camera'),
                ),
                ElevatedButton(
                  onPressed: _getImageFromGallery,
                  child: const Text('Pick Image from Gallery'),
                ),
                const SizedBox(height: 20),
                Text(uploadStatus, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendImageToAPI(File imageFile) async {
    var headers = {
      'Api-Key': 'OTSszilVvpgUXNRs1TZP2YJRY3biCymMjVNGzjNtkxSgG1pmId',
      'Content-Type': 'application/json'
    };

    var request = http.Request(
        'POST', Uri.parse('https://plant.id/api/v3/health_assessment'));
    request.headers.addAll(headers);

    // Convert image to Base64
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Prepare the request body
    var requestBody = json.encode({
      "images": ["data:image/jpeg;base64,$base64Image"],
      "similar_images": true,
    });
    request.body = requestBody;

    // Send the request
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      String responseBody = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseBody);
      /////////////////////

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiseaseScreen(diseaseData: jsonData),
        ),
      );
    } else {
      print('Error fetching disease details');
    }

    // Save JSON data to shared preferences
    //   final prefs = await SharedPreferences.getInstance();
    //   prefs.setString('plantIdJson', responseBody);
    // } else {
    //   //print(response.statusCode);
    //   print(response.stream.bytesToString());
    //   print('Error: ${response.reasonPhrase}');
    //   setState(() {
    //     uploadStatus = 'Unsuccessful';
    //   });
  }
}

class DiseaseScreen extends StatelessWidget {
  final dynamic diseaseData;

  DiseaseScreen({required this.diseaseData});

  @override
  Widget build(BuildContext context) {
    final suggestions = diseaseData['result']['disease']['suggestions'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Screen'),
      ),
      body: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  suggestion['similar_images'][0]['url'],
                  height: 40,
                  width: 40,
                ),
                Text(suggestion['name']),
                Text(
                    'Probability: ${suggestion['probability'].toStringAsFixed(2)}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DiseaseDetailsScreen extends StatelessWidget {
  final dynamic suggestion;

  DiseaseDetailsScreen({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Disease Name: ${suggestion['name']}'),
            Text(
                'Probability: ${suggestion['probability'].toStringAsFixed(2)}'),
            Image.network(
              suggestion['similar_images'][0]['url'],
              height: 200,
            ),
            Text('Successful'),
          ],
        ),
      ),
    );
  }
}
