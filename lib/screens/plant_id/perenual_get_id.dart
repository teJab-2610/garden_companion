import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Plant {
  final int id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final String cycle;
  final String watering;
  final String sunlight;

  Plant(
      {required this.id,
      required this.name,
      required this.scientificName,
      required this.imageUrl,
      required this.cycle,
      required this.watering,
      required this.sunlight});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Searcher',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: PlantSearchScreen(),
    );
  }
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
                builder: (context) => PlantListScreen(searchText: searchText),
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
        'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
    final apiUrl =
        'https://perenual.com/api/species-list?key=$apiKey&q=$searchText';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        print("here");
        List<Plant> plants =
            parsePlantsFromJson(result); // Use the parsing function
        print("here2");
        print(plants.length);
        setState(() {
          _plants = plants;
        });
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (error) {
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

List<Plant> parsePlantsFromJson(dynamic jsonData) {
  List<Plant> plants = [];
  //print("inside1");
  if (jsonData != null && jsonData is Map) {
    final data = jsonData['data'];
    //print("inside2");
    if (data != null && data is List) {
      //print("inside3");
      print(jsonData['data']);
      data.forEach((plantData) {
        // print(plantData['common_name']);
        // print(plantData['scientific_name'].toList().join(", "));
        // print(
        //   plantData['default_image']['original_url'],
        // );
        plants.add(Plant(
          id: plantData['id'],
          name: plantData['common_name'],
          scientificName: plantData['scientific_name'].toList().join(", "),
          imageUrl: plantData['default_image']['original_url'],
          cycle: plantData['cycle'],
          watering: plantData['watering'],
          sunlight: plantData['sunlight'].toList().join(", ")
        ));
      });
      // print("inside4");
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
              onPressed: () {
                // Handle 'more details' button
              },
              child: Text('More Details'),
            ),
            ElevatedButton(
              onPressed: () {
                fetchMoreDetails(context,plant.id);
              },
              child: Text('Care Guide'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle 'diseases/pests' button
              },
              child: Text('Diseases/Pests'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle 'FAQ' button
              },
              child: Text('FAQ'),
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> fetchMoreDetails(context,int plantId) async {
  final apiKey = 'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
  final apiUrl = 'https://perenual.com/api/species/details/$plantId?key=$apiKey';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      print(result);
      // Handle the result and display the additional details
    } else {
      throw Exception('Failed to load more details');
    }
  } catch (error) {
    // Handle the error by showing a snackbar or dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}
