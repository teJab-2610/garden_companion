import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/offers.dart';

class Notification {
  String senderItemId;
  String senderUid;
  String receiverUid;
  String receiverItemId;
  String notifId;

  Notification({
    required this.senderItemId,
    required this.senderUid,
    required this.receiverUid,
    required this.receiverItemId,
    required this.notifId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      senderItemId: json['senderItemId'] as String,
      senderUid: json['senderUid'] as String,
      receiverUid: json['receiverUid'] as String,
      receiverItemId: json['receiverItemId'] as String,
      notifId: json['notifId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderItemId': senderItemId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'receiverItemId': receiverItemId,
      'notifId': notifId,
    };
  }
}

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Notification> offers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> acceptNotification(String notifId) async {
    final notifsnap = await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notifications')
        .doc(notifId)
        .get();
    final notif =
        Notification.fromJson(notifsnap.data() as Map<String, dynamic>);
    try {
      //check if offer exists in firebase collections
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(notif.receiverUid)
          .collection('items')
          .where('itemId', isEqualTo: notif.receiverItemId)
          .get();
      if (querySnapshot.docs.isEmpty) {
        showDialogBox("Sorry! This offer was closed");
        Navigator.pop(context);
        return;
      } else {
        await _firestore
            .collection('users')
            .doc(notif.receiverUid)
            .collection('items')
            .doc(notif.receiverItemId)
            .delete();
        await _firestore
            .collection('users')
            .doc(notif.senderUid)
            .collection('items')
            .doc(notif.senderItemId)
            .delete();
        await _firestore
            .collection('users')
            .doc(notif.receiverUid)
            .collection('notifications')
            .doc(notif.notifId)
            .delete();
        showDialogBox("Offer Accepted successfully");
        Navigator.pop(context);
        return;
      }
    } catch (error) {
      print('Error in creating notification');
    }
  }

  Future<void> createNotification(Offer offer, String title) async {
    try {
      //check if offer exists in firebase collections
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(offer.originaluid)
          .collection('items')
          .where('itemId', isEqualTo: offer.itemId)
          .get();
      if (querySnapshot.docs.isEmpty) {
        showDialogBox("Sorry! This offer was closed");
        Navigator.pop(context);
        return;
      } else {
        final QuerySnapshot data = await _firestore
            .collection('users')
            .doc(offer.originaluid)
            .collection('items')
            .where('title', isEqualTo: title)
            .get();
        if (data.docs.isEmpty) {
          showDialogBox("Sorry! This offer was closed");
          Navigator.pop(context);
          return;
        } else {
          //get the field itemId from the above created snapshot data
          final senderItemId = data.docs[0].get('itemId');
          final senderUid = data.docs[0].get('uid');
          final receiverUid = offer.originaluid;
          final receiverItemId = offer.itemId;
          final postDocRef = await _firestore
              .collection('users')
              .doc(offer.originaluid)
              .collection('notifications')
              .add(offer.toJson());
          await _firestore
              .collection('users')
              .doc(offer.originaluid)
              .collection('notifications')
              .doc(postDocRef.id)
              .set({
            'senderItemId': senderItemId,
            'sender': senderUid,
            'recieverUid': receiverUid,
            'recieverItemId': receiverItemId,
            'notifId': postDocRef.id,
          });
          showDialogBox("Offer Accepted successfully");
          Navigator.pop(context);
          return;
        }
      }
    } catch (error) {
      print('Error in creating notification');
    }
  }

  Future<void> rejectNotification(String notifId) async {
    final notifsnap = await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notifications')
        .doc(notifId)
        .get();
    final notif =
        Notification.fromJson(notifsnap.data() as Map<String, dynamic>);
    try {
      await _firestore
          .collection('users')
          .doc(notif.receiverUid)
          .collection('notifications')
          .doc(notif.notifId)
          .delete();
      showDialogBox("Offer Deleted successfully");
      Navigator.pop(context);
      return;
    } catch (error) {
      print('Error in deleting notification');
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final User currentUser = FirebaseAuth.instance.currentUser!;
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .get();
      offers = querySnapshot.docs
          .map((doc) =>
              Notification.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return;
    } catch (error) {
      print('Error in fetching notifications');
    }
  }

  Widget showDialogBox(String text) {
    return AlertDialog(
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Handle back button press
                  },
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 91, 142, 85),
                  ),
                ),
                const Spacer(), // Add a spacer to push the refresh button to the right
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Handle refresh button press
                  },
                  child: const Icon(
                    CupertinoIcons.refresh,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: offers.length, // Number of tiles
              itemBuilder: (context, index) {
                return Card(
                  color:
                      const Color.fromARGB(224, 172, 199, 177), // Light green color
                  elevation: 3,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      'Notification ${index + 1}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Sample text for Notification ${index + 1}'),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.green), // Check icon
                        SizedBox(width: 10),
                        Icon(Icons.close, color: Colors.red), // Cross icon
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
