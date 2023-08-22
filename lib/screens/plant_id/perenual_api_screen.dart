import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PerenualApiScreen extends StatefulWidget {
  final String plantName;

  const PerenualApiScreen({Key? key, required this.plantName})
      : super(key: key);

  @override
  _PerenualApiScreenState createState() => _PerenualApiScreenState();
}

class _PerenualApiScreenState extends State<PerenualApiScreen> {
  String _plantId = "";

  @override
  void initState() {
    super.initState();
    _fetchPlantId();
  }

  Future<void> _fetchPlantId() async {
    try {
      final plantName = widget.plantName;
      final plantId = await _fetchPlants(plantName);
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

  Future<String> _fetchPlants(String searchText) async {
    final apiKey =
        'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
    final apiUrl =
        'https://perenual.com/api/species-list?key=$apiKey&q=$searchText';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print(result);
        final data = result['data'];
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
      throw Exception('Failed to get plant name: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plantName),
      ),
      body: Center(child: Text('Plant ID: $_plantId')
          //CircularProgressIndicator(),
          ),
    );
  }
}
