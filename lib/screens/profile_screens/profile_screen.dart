import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userProfile = userProvider.userProfile;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('User ID: ${userProfile.email}'),
                Text('Followers: ${userProfile.followersCount}'),
                Text('Following: ${userProfile.followingCount}'),
                // Other profile information
                ElevatedButton(
                  onPressed: () async {
                    await userProvider.fetchUserProfile();
                  },
                  child: const Text('Refresh Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
