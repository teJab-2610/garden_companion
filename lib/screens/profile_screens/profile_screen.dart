import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      //show the current profile information
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.currentUser != null) {
            return Column(
              children: [
                Text('Username: ${userProvider.userProfile.username}'),
                Text('Email: ${userProvider.userProfile.email}'),
                Text('Followers: ${userProvider.userProfile.followersCount}'),
                Text('Following: ${userProvider.userProfile.followingCount}'),
                Text('Posts: ${userProvider.userProfile.postsCount}'),
                //refresh profile button
                ElevatedButton(
                  onPressed: () {
                    userProvider.fetchUserProfile(); // Refresh the profile
                  },
                  child: const Text('Refresh Profile'),
                ),
              ],
            );
          } else {
            return const Text('Not logged in');
          }
        },
      ),
    );
  }
}
