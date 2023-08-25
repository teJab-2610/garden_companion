import 'package:flutter/material.dart';
import '../plant_searcher/details_fetcher.dart';

class MoreDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> details;

  MoreDetailsScreen({required this.details});

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
                text: 'More Details',
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
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(details['image']),
            Text('Origin: ${details['origin'].join(", ")}'),
            Text('Other Names: ${details['other_name']}'),
            Text('Type: ${details['type']}'),
            Text('Dimension: ${details['dimension']}'),
            Text('Propagation: ${details['propagation']}'),
            Text('Watering: ${details['watering']}'),
            Text(
                'Depth Watering Requirement: ${details['depth_watering_requirement']}'),
            Text(
                'Volume Water Requirement: ${details['volume_water_requirement']}'),
            Text('Maintenance: ${details['maintenance']}'),
            Text('Growth Rate: ${details['growth_rate']}'),
            Text('Care Level: ${details['care_level']}'),
            Text('Medicinal: ${details['medicinal']}'),
            Text('Poisonous to Humans: ${details['poisonous_to_humans']}'),
            Text('Poisonous to Pets: ${details['poisonous_to_pets']}'),
            Text('Description: ${details['description']}'),

            // Add other fields you want to display
          ],
        ),
      ),
    );
  }
}

class careGuideScreen extends StatelessWidget {
  final Map<String, dynamic> careGuideDetails;

  careGuideScreen({required this.careGuideDetails});

  @override
  Widget build(BuildContext context) {
    //print(careGuideDetails['watering']);
    //print(careGuideDetails['sunlight']);
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
                text: 'Care Guide',
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
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Watering: ${careGuideDetails['watering']}'),
            Text('Sunlight: ${careGuideDetails['sunlight']}'),
            // Add other fields you want to display
          ],
        ),
      ),
    );
  }
}

class FAQ_screen extends StatelessWidget {
  final List<Map<String, dynamic>> FAQ;

  FAQ_screen({required this.FAQ});
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
                text: 'FAQ',
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
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (FAQ.length == 0) Text('No FAQ available for this plant'),
            for (int i = 0; i < FAQ.length; i++)
              Text(
                '${FAQ[i]['question']} : ${FAQ[i]['answer']}\n'
                'tags : ${FAQ[i]['tags']}',
                style: TextStyle(fontSize: 16),
              ),
            // Add other fields you want to display
          ],
        ),
      ),
    );
  }
}

class disease_Screen extends StatelessWidget {
  final List<Map<String, dynamic>> diseaseDetailsList;

  disease_Screen({required this.diseaseDetailsList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diseases/Pests'),
      ),
      body: ListView.builder(
        itemCount: diseaseDetailsList.length,
        itemBuilder: (context, index) {
          final details = diseaseDetailsList[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiseaseDetailsScreen(details: details),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                leading: FutureBuilder<bool>(
                  future:
                      ImageUrlValidator.isValidImageUrl(details['thumbnail']),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While waiting for the result, you could show a loading indicator.
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError || snapshot.data == false) {
                      // In case of an error or invalid URL, show a placeholder image.
                      return Image.network(
                          'https://img.freepik.com/free-photo/flowing-purple-mountain-spiral-bright-imagination-generated-by-ai_188544-9853.jpg?q=10&h=200');
                    } else {
                      // If the URL is valid and no error, show the actual image.
                      return Image.network(details['thumbnail']);
                    }
                  },
                ),
                title: Text(details['common_name']),
                subtitle: Text(details['scientific_name']),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DiseaseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> details;

  DiseaseDetailsScreen({required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details['common_name']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<bool>(
              future: ImageUrlValidator.isValidImageUrl(details['image']),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the result, you could show a loading indicator.
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == false) {
                  // In case of an error or invalid URL, show a placeholder image.
                  return Image.network(
                      'https://img.freepik.com/free-photo/flowing-purple-mountain-spiral-bright-imagination-generated-by-ai_188544-9853.jpg?q=10&h=200');
                } else {
                  // If the URL is valid and no error, show the actual image.
                  return Image.network(details['image']);
                }
              },
            ),
            SizedBox(height: 16),
            Text('Scientific Name: ${details['scientific_name']}'),
            // Text('Family: ${details['family']}'),
            Text('Host: ${details['host'].join(', ')}'),
            SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var description in details['description'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description['subtitle'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description['description']),
                  SizedBox(height: 12),
                ],
              ),
            SizedBox(height: 16),
            Text('Solution:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var solution in details['solution'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(solution['subtitle'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(solution['description']),
                  SizedBox(height: 12),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
