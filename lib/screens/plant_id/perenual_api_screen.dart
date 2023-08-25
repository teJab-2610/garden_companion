import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../plant_searcher/details_fetcher.dart';
import 'display_more_details.dart';

class PerenualApiScreen extends StatefulWidget {
  final String plantName;

  const PerenualApiScreen({Key? key, required this.plantName})
      : super(key: key);

  @override
  _PerenualApiScreenState createState() => _PerenualApiScreenState();
}

class _PerenualApiScreenState extends State<PerenualApiScreen> {
  int _plantId = -1;

  @override
  void initState() {
    super.initState();
    _fetchPlantId();
  }

  Future<dynamic> _fetchPlantId() async {
    try {
      final plantName = widget.plantName;
      final plantId = await _fetchPlants(plantName);
      //plant detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailScreen(
              plantId: plantId,
              plantSciName: plantName,
              plantName: plantName,
              plantImageUrl:
                  "https://perenual.com/api/species-image?id=$plantId"),
        ),
      );
      //.....//
      setState(() {
        _plantId = plantId;
      });
    } catch (error) {
      // Handle the error by showing a snackbar or dialog
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<int> _fetchPlants(String searchText) async {
    final apiKey =
        'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
    final apiUrl =
        'https://perenual.com/api/species-list?key=$apiKey&q=$searchText';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("here");
        print(result);
        final data = result['data'];
        print("here too");
        if (data.isNotEmpty) {
          print(data);
          final firstPlant = data[0];
          print(firstPlant);
          final plantId = firstPlant['id'];
          print(plantId);
          return plantId;
        } else {
          throw Exception('No plants found');
        }
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (error) {
      throw Exception('Failed to get plant name 2: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 91, 142,85), // Set the color of the back arrow button
        ),
        //print plantname in richtext with green color
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.plantName,
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class PlantDetailScreen extends StatelessWidget {
  final int plantId;
  final String plantSciName;
  final String plantName;
  final String plantImageUrl;

  PlantDetailScreen({
    required this.plantId,
    required this.plantSciName,
    required this.plantName,
    required this.plantImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 91, 142, 85),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: plantSciName,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  dynamic details = await fetchMoreDetails(plantId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetailsScreen(details: details),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the background color
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                ),
                child: Text('More Details', style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  dynamic careGuideDetails = await care_guideDetails(plantSciName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => careGuideScreen(careGuideDetails: careGuideDetails),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the background color
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                ),
                child: Text('Care Guide', style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  dynamic FAQ = await FAQ_details(plantSciName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FAQ_screen(FAQ: FAQ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the background color
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                ),
                child: Text('FAQ', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
