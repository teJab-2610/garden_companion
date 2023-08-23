import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/plant_health/health_screen.dart';

import '../plant_id/camera_screen.dart';

class ImageSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Search Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: Text('Search for Plant Identification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen1()),
                );
              },
              child: Text('Search for Plant Health'),
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
