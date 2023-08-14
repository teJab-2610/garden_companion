import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
              onPressed: () {
                signUserOut();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
          child:
              Text("Logged In!${FirebaseAuth.instance.currentUser!.email!}")),
    );
  }
}