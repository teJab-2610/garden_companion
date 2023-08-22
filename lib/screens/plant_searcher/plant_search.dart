import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'details_fetcher.dart';
import 'display_details.dart';


class Plant {
  final int id;
  final String searchText;
  final String name;
  final String scientificName;
  final String imageUrl;
  final String cycle;
  final String watering;
  final String sunlight;

  Plant(
      {required this.id,
      required this.searchText,
      required this.name,
      required this.scientificName,
      required this.imageUrl,
      required this.cycle,
      required this.watering,
      required this.sunlight});
}

class PlantSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Searcher'),
      ),
      body: Column(
        children: [
          SearchBar(onSearch: (searchText) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlantListScreen(searchText: searchText, ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final void Function(String) onSearch;

  SearchBar({required this.onSearch});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for plants',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              widget.onSearch(_searchController.text);
            },
          ),
        ],
      ),
    );
  }
}

class PlantListScreen extends StatefulWidget {
  final String searchText;

  PlantListScreen({required this.searchText});

  @override
  _PlantListScreenState createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<Plant> _plants = [];

  @override
  void initState() {
    super.initState();
    _fetchPlants(widget.searchText);
  }

  void _fetchPlants(String searchText) async {
    final apiKey =
        'sk-MWmz64de0acb084cd1886'; 
    final apiUrl =
        'https://perenual.com/api/species-list?key=$apiKey&q=$searchText';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      //print(response.statusCode);
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        ////print("here");
        List<Plant> plants =
            parsePlantsFromJson(result,searchText); // Use the parsing function
        ////print("here2");
        //print(plants.length);
        setState(() {
          _plants = plants;
        });
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (error) {
      //print(error);
      // Handle the error by showing a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant List'),
      ),
      body: ListView.builder(
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlantDetailScreen(plant: _plants[index]),
                ),
              );
            },
            child: ListTile(
              title: Text(_plants[index].name),
              leading: Image.network(_plants[index].imageUrl),
            ),
          );
        },
      ),
    );
  }
}

List<Plant> parsePlantsFromJson(dynamic jsonData, String search_text) {
  List<Plant> plants = [];
  if (jsonData != null && jsonData is Map) {
    final data = jsonData['data'];
    if (data != null && data is List) {
      //print(jsonData['data']);
      data.forEach((plantData) {
        if (plantData['id'] <= 3000) {
          //print(plantData['id']);
          plants.add(Plant(
              id: plantData['id'],
              searchText: search_text,
              name: plantData['common_name'],
              scientificName: plantData['scientific_name'].toList().join(", "),
              imageUrl: plantData['default_image']['original_url'],
              cycle: plantData['cycle'],
              watering: plantData['watering'],
              sunlight: plantData['sunlight'].toList().join(", ")));
        }
      });
      // //print("inside4");
    }
  }

  return plants;
}

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  PlantDetailScreen({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(plant.imageUrl),
            SizedBox(height: 16),
            Text('Scientific Name: ${plant.scientificName}'),
            Text('Cycle: ${plant.cycle}'),
            Text('Watering: ${plant.watering}'),
            Text('Sunlight: ${plant.sunlight}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                dynamic details = await fetchMoreDetails(plant.id);
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
                    await care_guideDetails(plant.scientificName);
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
            ElevatedButton(
              onPressed: () async {
                ////print("here");
                dynamic details = await disease_Details(plant.searchText);
                //print('success 2');
                //print("details");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => disease_Screen(diseaseDetailsList: details),
                  ),
                );
              },
              child: Text('Diseases/Pests'),
            ),
            ElevatedButton(
              onPressed: () async {
                dynamic FAQ = await FAQ_details(plant.scientificName);
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
