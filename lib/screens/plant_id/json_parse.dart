import 'package:flutter/material.dart';
import 'suggestion_details.dart'; // Import the SuggestionDetailsScreen

class JsonParser {
  static Widget buildJsonData(BuildContext context, dynamic data) {
    if (data is Map) {
      final resultValue = data['result'];

      if (resultValue != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              //child: Text('Result: $resultValue'),
            ),
            const SizedBox(height: 10),
            _buildPlantList(context, data['result']),
          ],
        );
      }
    }
    return Container(); // Return an empty container if not displaying anything
  }

  static Widget _buildPlantList(BuildContext context, dynamic data) {
    if (data is Map) {
      final isPlantProbability = data['is_plant']['probability'];
      final suggestions = data['classification']['suggestions'];

      if (isPlantProbability > 0.5 && suggestions.isNotEmpty) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return _buildSuggestion(context, suggestions[index]);
          },
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

  static Widget _buildSuggestion(
      BuildContext context, Map<String, dynamic> suggestion) {
    final name = suggestion['name'];
    final probability = suggestion['probability'];

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
            Image.network(
              suggestion['similar_images'][0]['url'],
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
