// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'json_parse.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color.fromARGB(
              255, 91, 142, 85), // Set the color of the back arrow button
        ),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Image Upload',
                style: TextStyle(
                  color: Color.fromARGB(255, 91, 142, 85),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/camepic.jpg', width: 100, height: 100), // Change the dimensions as needed
                    SizedBox(width: 20), // Add spacing between image and button
                    ElevatedButton(
                      onPressed: _getImageFromCamera,
                      child: const Text('Pick Image from Camera'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/gllerypic.png', width: 100, height: 100), // Change the dimensions as needed
                    SizedBox(width: 20), // Add spacing between image and button
                    ElevatedButton(
                      onPressed: _getImageFromGallery,
                      child: const Text('Pick Image from Gallery'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
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
      'POST',
      Uri.parse('https://plant.id/api/v3/identification'),
    );
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
      final accessToken = jsonData['access_token'];

      var detailsRequest = http.Request(
        'GET',
        Uri.parse(
          'https://plant.id/api/v3/identification/$accessToken?details=common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering&language=en',
        ),
      );
      detailsRequest.headers.addAll(headers);

      http.StreamedResponse detailedResponse = await detailsRequest.send();
      if (detailedResponse.statusCode == 200 ||
          detailedResponse.statusCode == 201) {
        String detailedResponsebody =
            await detailedResponse.stream.bytesToString();
        var detailsData = jsonDecode(detailedResponsebody);
        print(detailsData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantIdResultScreen(detailsData: detailsData),
          ),
        );
      } else {
        print('Error fetching plant details');
      }

      // Save JSON data to shared preferences
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setString('plantIdJson', responseBody);
    } else {
      //print(response.statusCode);
      print(response.stream.bytesToString());
      print('Error: ${response.reasonPhrase}');
      setState(() {
        uploadStatus = 'Unsuccessful';
      });
    }
  }
}

class PlantIdResultScreen extends StatelessWidget {
  final dynamic detailsData;

  const PlantIdResultScreen({Key? key, required this.detailsData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant ID Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              JsonParser.buildJsonData(context, detailsData),
            ],
          ),
        ),
      ),
    );
  }
}
