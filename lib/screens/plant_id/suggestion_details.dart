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
                text: 'Suggestion Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Image.network(suggestion['similar_images'][0]['url']),
            // Text('Common Names: ${details['common_names'].join(", ")}'),
            // Text('Taxonomy: ${details['taxonomy']}'),
            // Text('URL: ${details['url']}'),
            // Text('GBIF ID: ${details['gbif_id']}'),
            // Text('Description: ${details['description']['value']}'),
            // Text('Synonyms: ${details['synonyms']}'),
            // Text('Image URL: ${details['image']['value']}'),
            // Text('Edible Parts: ${details['edible_parts']}'),
            // Text('Watering: ${details['watering']}'),
            // Text('Propagation: ${details['propagation']}'),
            // Add more details as needed
            //make headings bold
            Text(
              'Common Names: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${details['common_names'].join(", ")}'),
            Text('Taxonomy: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['taxonomy']}'),
            Text('URL: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['url']}'),
            Text('GBIF ID: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['gbif_id']}'),
            Text('Description: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['description']['value']}'),
            Text('Synonyms: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['synonyms']}'),
            Text('Image URL: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['image']['value']}'),
            Text('Edible Parts: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['edible_parts']}'),
            Text('Watering: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['watering']}'),
            Text('Propagation: ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${details['propagation']}'),


            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  backgroundColor: Colors.green, // Set the background color
                ),
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
