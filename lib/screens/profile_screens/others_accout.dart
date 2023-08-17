import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class OtherAccountPage extends StatefulWidget {
  final String documentId;

  OtherAccountPage({required this.documentId});

  @override
  _OtherAccountPageState createState() => _OtherAccountPageState();
}

class _OtherAccountPageState extends State<OtherAccountPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;

  @override
  void initState() {
    super.initState();
    print('Document ID: ${widget.documentId}');
    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .get();
  }

  Future<void> _toggleFollowUser(
      String otherID, UserProvider userProvider) async {
    print(otherID);
    bool isFollowing = await userProvider.isFollowingUser(otherID);
    if (isFollowing) {
      await userProvider.unFollowing(otherID);
    } else {
      await userProvider.followUser(otherID);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('User not found.'));
            }

            Map<String, dynamic> userData = snapshot.data!.data()!;

            //return Scaffold in safe area only with a follow button
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            userData['email'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          _toggleFollowUser(widget.documentId, userProvider),
                      child: const Text('Follow'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
