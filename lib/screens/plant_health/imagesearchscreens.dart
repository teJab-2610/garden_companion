import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/plant_health/health_screen.dart';

import '../plant_id/camera_screen.dart';

class ImageSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 91, 142,85), // Set the color of the back arrow button
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Image Search Screen',
                style: TextStyle(
                  color: Color.fromARGB(255, 91, 142,85),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/plant_iden.jpg'), // Add your image asset here
            SizedBox(height: 20),
            buildElevatedButton(
              context,
              'Search for Plant Identification',
              const CameraScreen(),
            ),
            SizedBox(height: 20),
            buildElevatedButton(
              context,
              'Search for Plant Health',
              const CameraScreen1(),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantIdentificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Identification Screen'),
      ),
      body: Center(
        child: Text('Plant Identification Screen Content'),
      ),
    );
  }
}

class PlantHealthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Health Screen'),
      ),
      body: Center(
        child: Text('Plant Health Screen Content'),
      ),
    );
  }
}


Widget buildElevatedButton(BuildContext context, String text, Widget screen) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 91, 142,85), // Background color
        onPrimary: Colors.white, // Text color
        padding: EdgeInsets.all(15), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Button shape
        ),
        elevation: 5, // Elevation
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}