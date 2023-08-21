import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String groupId;
  final String groupName;
  final String adminId;
  final List<String> members;
  final String about;
  final String groupImage;
  final Timestamp lastMessageTime;

  Group({
    required this.groupId,
    required this.groupName,
    required this.adminId,
    required this.members,
    required this.about,
    required this.groupImage,
    required this.lastMessageTime,
  });

  factory Group.fromJson(Map<String, dynamic> json, String groupId) {
    return Group(
      groupId: groupId,
      groupName: json['groupName'] as String,
      adminId: json['adminId'] as String,
      members: List<String>.from(json['members'] as List<dynamic>),
      about: json['about'] as String,
      groupImage: json['groupImage'] as String,
      lastMessageTime: json['lastMessageTime'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'adminId': adminId,
      'members': members,
      'about': about,
      'groupImage': groupImage,
      'lastMessageTime': lastMessageTime,
    };
  }
}
