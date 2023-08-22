import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String imageUrl;
  final String title;
  final String author;
  final String originaluid;
  final String itemId;
  final Timestamp timestamp;

  Offer({
    required this.imageUrl,
    required this.title,
    required this.itemId,
    required this.author,
    required this.originaluid,
    required this.timestamp,
  });
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
        imageUrl: json['imageUrl'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        originaluid: json['originaluid'] as String,
        timestamp: json['timestamp'] as Timestamp,
        itemId: json['itemId'] as String);
  }
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'author': author,
      'originaluid': originaluid,
      'itemId': itemId,
      'timestamp': timestamp,
    };
  }
}
