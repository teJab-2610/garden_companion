import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isOwnProfile = _isOwnProfile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'My Profile' : 'Profile'),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Navigate to profile settings screen
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Display user information, profile picture, etc.
          // ...

          SizedBox(height: 20),

          _buildFollowersCount(),

          _buildFollowingCount(),

          SizedBox(height: 20),

          // You can include additional profile content or widgets here
          // ...
        ],
      ),
    );
  }

  bool _isOwnProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    //return authProvider.currentUser.id == userId; // Replace with your logic
    return true;
  }

  Widget _buildFollowersCount() {
    return FutureBuilder<int>(
      future: _getFollowersCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading followers count');
        } else {
          final followersCount = snapshot.data ?? 0;

          return Text(
            'Followers: $followersCount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  Widget _buildFollowingCount() {
    return FutureBuilder<int>(
      future: _getFollowingCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading following count');
        } else {
          final followingCount = snapshot.data ?? 0;

          return Text(
            'Following: $followingCount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  Future<int> _getFollowersCount() async {
    // Replace with your logic to retrieve followers count
    return 0;
  }

  Future<int> _getFollowingCount() async {
    // Replace with your logic to retrieve following count
    return 0;
  }
}
