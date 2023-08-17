import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${userProvider.userProfile.username}'),
            Text('Email: ${userProvider.userProfile.email}'),
            Text('Followers: ${userProvider.userProfile.followersCount}'),
            Text('Following: ${userProvider.userProfile.followingCount}'),
            Text('Posts: ${userProvider.userProfile.postsCount}'),
            ElevatedButton(
              onPressed: () async {
                await userProvider.fetchUserProfile();
                // Now the UI will update with the latest user profile data
              },
              child: Text('Refresh Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
