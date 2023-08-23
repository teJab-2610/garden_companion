import 'package:flutter/material.dart';
import 'perenual_api_screen.dart';

class SuggestionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> suggestion;

  const SuggestionDetailsScreen({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final details = suggestion['details'];

    // Extract and display the suggestion details here
    // Use details['common_names'], details['taxonomy'], etc.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestion Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Common Names: ${details['common_names'].join(", ")}'),
            Text('Taxonomy: ${details['taxonomy']}'),
            Text('URL: ${details['url']}'),
            Text('GBIF ID: ${details['gbif_id']}'),
            Text('Description: ${details['description']['value']}'),
            Text('Synonyms: ${details['synonyms']}'),
            Text('Image URL: ${details['image']['value']}'),
            Text('Edible Parts: ${details['edible_parts']}'),
            Text('Watering: ${details['watering']}'),
            Text('Propagation: ${details['propagation']}'),
            // Add more details as needed

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle 'more details' button
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerenualApiScreen(plantName : suggestion['name']),
                  ),
                );
              },
              child: const Text('More Details'),
            ),
          ],
        ),
      ),
    );
  }
}
