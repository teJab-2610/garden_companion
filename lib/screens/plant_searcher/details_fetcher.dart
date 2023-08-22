import 'package:http/http.dart' as http;
import 'dart:convert';


class ImageUrlValidator {
  static Future<bool> isValidImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 &&
          response.headers['content-type']!.startsWith('image/');
    } catch (e) {
      return false;
    }
  }
}

Future<Map<String, dynamic>> fetchMoreDetails(int plantId) async {
  final apiKey = 'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
  final apiUrl =
      'https://perenual.com/api/species/details/$plantId?key=$apiKey';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      Map<String, dynamic> detailsMap = {
        'origin': result['origin'],
        'other_name': result['other_name'].toList().join(", "),
        'type': result['type'],
        'dimension': result['dimension'],
        'propagation': result['propagation'].toList().join(", "),
        'watering': result['watering'],
        'depth_watering_requirement': result['depth_watering_requirement'],
        'volume_water_requirement': result['volume_water_requirement'],
        'maintenance': result['maintenance'],
        'growth_rate': result['growth_rate'],
        'care_level': result['care_level'],
        'medicinal': result['medicinal'],
        'poisonous_to_humans': result['poisonous_to_humans'],
        'poisonous_to_pets': result['poisonous_to_pets'],
        'description': result['description'],
        'image': result['default_image']['original_url'],
        // Add other fields you want to include in the map
      };
      return detailsMap;
      //create a map of keys and values
    } else {
      throw Exception('Failed to load more details');
    }
  } catch (error) {
    throw error;
  }
}

Future<Map<String, dynamic>> care_guideDetails(String scientific_name) async {
  final apiKey = 'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
  final apiUrl =
      'https://perenual.com/api/species-care-guide-list?key=$apiKey&q=$scientific_name';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      var data = result['data'][0]['section'];
      Map<String, dynamic> careGuide = {
        'watering': data[0]['description'],
        'sunlight': data[1]['description'],
      };
      return careGuide;
      //create a map of keys and values
    } else {
      throw Exception('Failed to load more details');
    }
  } catch (error) {
    throw error;
  }
}

Future<List<Map<String, dynamic>>> disease_Details(
    String name) async {
  final apiKey = 'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
  final apiUrl =
      'https://perenual.com/api/pest-disease-list?key=$apiKey&q=$name';
  ////print('here 1');
  try {
    final response = await http.get(Uri.parse(apiUrl));
    ////print(response.statusCode);
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      ////print(result);
      var data = result['data'];
      ////print(data);
      List<Map<String, dynamic>> disease_details = parse_diseaseData(data);
      ////print('here 2');
      ////print(disease_details);
      return disease_details;
      //create a map of keys and values
    } else {
      throw Exception('Failed to load more details');
    }
  } catch (error) {
    //print('here1 $error');
    throw error;
  }
}

Future<List<Map<String, dynamic>>> FAQ_details(String scientific_name) async {
  final apiKey = 'sk-MWmz64de0acb084cd1886'; // Replace with your actual API key
  final apiUrl =
      'https://perenual.com/api/article-faq-list?key=$apiKey&q=$scientific_name';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      var data = result['data'];
      List<Map<String, dynamic>> FAQ = [];
      data.forEach((element) {
        FAQ.add({
          'question': element['question'],
          'answer': element['answer'],
          'tags': element['tags'].toList().join(", ")
        });
      });
      return FAQ;
      //create a map of keys and values
    } else {
      throw Exception('Failed to load more details');
    }
  } catch (error) {
    throw error;
  }
}

List<Map<String, dynamic>> parse_diseaseData(dynamic jsonData) {
  List<Map<String, dynamic>> disease_details_list = [];

  try {
    //final List<dynamic> parsedList = json.decode(jsonDataList);
    //print(jsonData);
    for (var i = 0; i < jsonData.length; i++) {
      var parsedData = jsonData[i];
      Map<String, dynamic> disease_details = {};
      disease_details['id'] = parsedData['id'];
      //print(parsedData['id']);
      disease_details['common_name'] = parsedData['common_name'];
      //print(parsedData['common_name']);
      disease_details['scientific_name'] = parsedData['scientific_name'];
      //print(parsedData['scientific_name']);
      disease_details['other_name'] = parsedData['other_name'];
      //print(parsedData['other_name']);
      disease_details['family'] = parsedData['family'];
      //print(parsedData['family']);
      disease_details['thumbnail'] = parsedData['images'][0]['thumbnail'];

      //print(parsedData['images'][0]['thumbnail']);
      //print(parsedData);
      //print(parsedData['images']);
      disease_details['image'] = parsedData['images'][0]['regular_url'];
      //print(parsedData['images'][0]['regular_url']);

      List<Map<String, String>> descriptionList = [];
      for (var description in parsedData['description']) {
        descriptionList.add({
          'subtitle': description['subtitle'],
          'description': description['description'],
        });
      }
      disease_details['description'] = descriptionList;

      List<Map<String, String>> solutionList = [];
      for (var solution in parsedData['solution']) {
        solutionList.add({
          'subtitle': solution['subtitle'],
          'description': solution['description'],
        });
      }
      disease_details['solution'] = solutionList;

      disease_details['host'] = List<String>.from(parsedData['host']);

      // List<Map<String, dynamic>> imagesList = [];
      // for (var image in parsedData['images']) {
      //   imagesList.add({
      //     'license': image['license'],
      //     'license_name': image['license_name'],
      //     'license_url': image['license_url'],
      //     'original_url': image['original_url'],
      //     'regular_url': image['regular_url'],
      //     'medium_url': image['medium_url'],
      //     'small_url': image['small_url'],
      //     'thumbnail': image['thumbnail'],
      //   });
      // }
      // disease_details['images'] = imagesList;

      disease_details_list.add(disease_details);
    }
  } catch (e) {
    //print('Error parsing JSON data here 1: $e');
  }

  return disease_details_list;
}
