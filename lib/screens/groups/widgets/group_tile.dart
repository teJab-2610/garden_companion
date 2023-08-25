import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/groups/widgets/widgets.dart';

import '../chat_page.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupTile(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  late Future<String> lastMessageTime;
  @override
  void initState() {
    super.initState();
    lastMessageTime = fetchLastMessageTime();
  }

  Future<String> fetchLastMessageTime() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .get();
    final test = documentSnapshot['recentMessageTime'];
    if (test == "start") return "(No messages yet)";

    final timestamp = documentSnapshot['recentMessageTime'] as Timestamp;
    final dateTime = timestamp.toDate();
    final formattedTime = DateFormat.yMd().add_jm().format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Color.fromARGB(255, 76, 175, 80),
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Sf'),
            ),
          ),
          title: Text(
            widget.groupName,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Sf'),
          ),
          subtitle: FutureBuilder<String>(
            future: lastMessageTime,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading...",
                    style: TextStyle(
                      fontFamily: 'Sf',
                    ));
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}",
                    style: TextStyle(
                      fontFamily: 'Sf',
                    ));
              } else {
                return Text("Last Message was on ${snapshot.data}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Sf',
                    ));
              }
            },
          ),
        ),
      ),
    );
  }
}
