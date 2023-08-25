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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/bgplant.jpg', // Replace with your image path
                width: 300, // Adjust the width as needed
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Plant",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " Searcher",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
              child: Container(
                padding: EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: Colors.green),
                  decoration: InputDecoration(
                    hintText: "Search for the plants.....",
                    hintStyle: TextStyle(color: Colors.green.withOpacity(0.5)),
                    icon: Icon(Icons.search, color: Colors.green),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (searchText) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantListScreen(
                          searchText: searchText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
    final apiKey = 'sk-MWmz64de0acb084cd1886';
    final apiUrl =
        'https://perenual.com/api/species-list?key=$apiKey&q=$searchText';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      print(searchText + " here");
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        ////print("here");
        List<Plant> plants =
            parsePlantsFromJson(result, searchText); // Use the parsing function
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
    print(_plants.length);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.green, // Set the color of the back arrow button
        ),
        elevation: 0.0,
        title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Plant",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " List",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
      ),
      body: ListView.builder(
        itemCount: _plants.isEmpty ? 1 : _plants.length + 1,
        itemBuilder: (context, index) {
          if (_plants.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (index < _plants.length) {
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
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    _plants[index].name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  leading: Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(_plants[index].imageUrl),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'End of List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
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
      print(jsonData['data']);
      data.forEach((plantData) {
        if (plantData['id'] <= 3000) {
          //print(plantData['id']);
          print("hi");
          //print(plantData['default_image']['original_url']);
          try {
            plants.add(Plant(
                id: plantData['id'],
                searchText: search_text,
                name: plantData['common_name'],
                scientificName:
                    plantData['scientific_name'].toList().join(", "),
                imageUrl: plantData['default_image']['original_url'],
                cycle: plantData['cycle'],
                watering: plantData['watering'],
                sunlight: plantData['sunlight'].toList().join(", ")));
          } catch (e) {
            print("error");
          }
        }
        print("inside3");
      });
      print("inside4");
    }
    print(plants.length);
  }

  return plants;
}

// class PlantDetailScreen extends StatelessWidget {
//   final Plant plant;

//   PlantDetailScreen({required this.plant});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(
//           color: Colors.green, // Set the color of the back arrow button
//         ),
//         //print plantname in richtext with green color
//         title: RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: plant.name,
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Image.network(plant.imageUrl),
//             SizedBox(height: 16),
//             Text('Scientific Name: ${plant.scientificName}'),
//             Text('Cycle: ${plant.cycle}'),
//             Text('Watering: ${plant.watering}'),
//             Text('Sunlight: ${plant.sunlight}'),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 dynamic details = await fetchMoreDetails(plant.id);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => MoreDetailsScreen(details: details),
//                   ),
//                 );
//               },
//               child: Text('More Details'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 dynamic careGuideDetails =
//                     await care_guideDetails(plant.scientificName);
//                 //print("success 1");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         careGuideScreen(careGuideDetails: careGuideDetails),
//                   ),
//                 );
//               },
//               child: Text('Care Guide'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 dynamic details = await disease_Details(plant.searchText);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         disease_Screen(diseaseDetailsList: details),
//                   ),
//                 );
//               },
//               child: Text('Diseases/Pests'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 dynamic FAQ = await FAQ_details(plant.scientificName);
//                 ////print("success 1");
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FAQ_screen(FAQ: FAQ),
//                   ),
//                 );
//               },
//               child: Text('FAQ'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  PlantDetailScreen({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.green, // Set the color of the back arrow button
        ),
        //print plantname in richtext with green color
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: plant.name,
                style: TextStyle(
                  color: Colors.green,
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
          children: [
            Image.network(plant.imageUrl),
            SizedBox(height: 20),
            buildInfoRow('   Scientific Name :', plant.scientificName),
            buildInfoRow('   Cycle           :', plant.cycle),
            buildInfoRow('   Watering        :', plant.watering),
            buildInfoRow('   Sunlight        :', plant.sunlight),
            SizedBox(height: 16),
            buildTile(
              context,
              'More Details',
              Color.fromARGB(255, 132, 227, 110),
              () async {
                dynamic details = await fetchMoreDetails(plant.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoreDetailsScreen(details: details),
                  ),
                );
              },
            ),
            // Repeat the same structure for other buttons
            buildTile(
              context,
              'Care Guide',
              Color.fromARGB(255, 132, 227, 110),
              () async {
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
            ),
            // Repeat the same structure for other buttons
            buildTile(
              context,
              'Diseases/Pests',
              Color.fromARGB(255, 132, 227, 110),
              () async {
                dynamic details = await disease_Details(plant.searchText);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        disease_Screen(diseaseDetailsList: details),
                  ),
                );
              },
            ),
            // Repeat the same structure for other buttons
            buildTile(
              context,
              'FAQ',
              Color.fromARGB(255, 132, 227, 110),
              () async {
                dynamic FAQ = await FAQ_details(plant.scientificName);
                ////print("success 1");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FAQ_screen(FAQ: FAQ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile(BuildContext context, String title, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 60, // Fixed height for all tiles
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Add margin for spacing
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20), // Padding
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
Widget buildInfoRow(String heading, String value) {
  return Row(
    children: [
      Text(
        heading,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(width: 8), // Add spacing between heading and value
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    ],
  );
}
