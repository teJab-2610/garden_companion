import 'package:flutter/material.dart';
import 'suggestion_details.dart'; // Import the SuggestionDetailsScreen

class JsonParser {
  static Widget buildJsonData(BuildContext context, dynamic data) {
    if (data is Map) {
      final resultValue = data['result'];

      if (resultValue != null) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                //child: Text('Result: $resultValue'),
              ),
              const SizedBox(height: 10),
              _buildDataFields(context, data['result']),
            ],
          ),
        );
      }
    }
    return Container(); // Return an empty container if not displaying anything
  }

  static Widget _buildDataFields(BuildContext context, dynamic data) {
    if (data is Map) {
      final isPlantProbability = data['is_plant']['probability'];
      final suggestions = data['classification']['suggestions'];
      if (isPlantProbability > 0.5) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Is Plant Probability: $isPlantProbability'),
            ),
            const SizedBox(height: 10),
            _buildSuggestionsList(context, suggestions),
          ],
        );
      } else {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('High chance that image does not contain a plant'),
            ),
            SizedBox(height: 10),
            // Text('Not a plant'),
          ],
        );
      }
    }
    //print('data is not map 2');
    return Container(); // Return an empty container if not displaying anything
  }

  static Widget _buildSuggestionsList(
      BuildContext context, List<dynamic> suggestions) {
    if (suggestions.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: suggestions
            .map<Widget>((suggestion) => _buildSuggestion(
                context, suggestion)) // Pass context as a parameter
            .toList(),
      );
    }
    //print("suggestions empty");
    return Container(); // Return an empty container if not displaying anything
  }

  static Widget _buildSuggestion(
      BuildContext context, Map<String, dynamic> suggestion) {
    //final id = suggestion['id'];
    final name = suggestion['name'];
    final probability = suggestion['probability'];
    final imageUrl = suggestion['similar_images'][0]['url'];

    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                SuggestionDetailsScreen(suggestion: suggestion),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            Text('Name: $name'),
            Text('Probability: $probability'),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
