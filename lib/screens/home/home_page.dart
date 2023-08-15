import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auths/login_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Hello World',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    // Navigate to the login screen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
