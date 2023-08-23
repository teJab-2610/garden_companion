import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile_screens/others_accout.dart'; // Make sure to import the correct file

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final User currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _searchUser() async {
    String email = _searchController.text.trim();

    if (email.isNotEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.size > 0) {
        String documentId = querySnapshot.docs[0].id;
        //if the documentID is same as the current user's ID, then show user not found
        if (documentId == currentUser.uid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found.')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtherAccountPage(userId: documentId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search User'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'User Email',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
