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
        title: Text(widget.plantName),
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

  PlantDetailScreen(
      {required this.plantId,
      required this.plantSciName,
      required this.plantName,
      required this.plantImageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantSciName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //   Image.network(plant.imageUrl),
            //   SizedBox(height: 16),
            //   Text('Scientific Name: ${plant.scientificName}'),
            //   Text('Cycle: ${plant.cycle}'),
            //   Text('Watering: ${plant.watering}'),
            //   Text('Sunlight: ${plant.sunlight}'),
            //SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                dynamic details = await fetchMoreDetails(plantId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoreDetailsScreen(details: details),
                  ),
                );
              },
              child: Text('More Details'),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic careGuideDetails =
                    await care_guideDetails(plantSciName);
                //print("success 1");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        careGuideScreen(careGuideDetails: careGuideDetails),
                  ),
                );
              },
              child: Text('Care Guide'),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     ////print("here");
            //     dynamic details = await disease_Details(plant.searchText);
            //     //print('success 2');
            //     //print("details");
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             disease_Screen(diseaseDetailsList: details),
            //       ),
            //     );
            //   },
            //   child: Text('Diseases/Pests'),
            // ),
            ElevatedButton(
              onPressed: () async {
                dynamic FAQ = await FAQ_details(plantSciName);
                ////print("success 1");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FAQ_screen(FAQ: FAQ),
                  ),
                );
              },
              child: Text('FAQ'),
            ),
          ],
        ),
      ),
    );
  }
}
