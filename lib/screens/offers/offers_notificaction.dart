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
  String senderItemTitle;
  String recieverItemTitle;
  Timestamp timestamp = Timestamp.now();

  Notification({
    required this.senderItemId,
    required this.senderUid,
    required this.receiverUid,
    required this.receiverItemId,
    required this.notifId,
    required this.timestamp,
    required this.senderItemTitle,
    required this.recieverItemTitle,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      senderItemTitle: json['senderItemTitle'] as String,
      recieverItemTitle: json['recieverItemTitle'] as String,
      senderItemId: json['senderItemId'] as String,
      senderUid: json['sender'] as String,
      receiverUid: json['recieverUid'] as String,
      receiverItemId: json['recieverItemId'] as String,
      notifId: json['notifId'] as String,
      timestamp: json['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderItemId': senderItemId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'receiverItemId': receiverItemId,
      'notifId': notifId,
      'timestamp': timestamp,
    };
  }
}

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Notification> offers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

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
      final User _currentUser = FirebaseAuth.instance.currentUser!;
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUser.uid)
          .collection('notifications')
          .get();
      setState(() {
        offers = querySnapshot.docs
            .map((doc) =>
                Notification.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        print("false");
      });
    } catch (error) {
      print('Error in fetching notifications $error');
    }
  }

  Widget showDialogBox(String text) {
    return AlertDialog(
      content: Text('$text'),
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

  Future<String> getSenderName(String senderUid) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderUid)
        .get();
    final senderName = snap.data()!['name'];
    return senderName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 60, left: 20, right: 20),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {},
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 91, 142, 85),
                  ),
                ),
                Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await fetchNotifications();
                    setState(() {});
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
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final notification = offers[index];
                return Card(
                  child: ListTile(
                    title: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(notification.senderUid)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading...");
                        }
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        final senderName = snapshot.data!['name'];
                        final senderItemTitle = notification.senderItemTitle;
                        final receiverItemTitle =
                            notification.recieverItemTitle;
                        return Card(
                          color: Color.fromARGB(224, 172, 199, 177),
                          elevation: 3,
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              "Offer From: $senderName",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                "$senderName wants to exchange $senderItemTitle with your $receiverItemTitle"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    acceptNotification(notification.notifId);
                                  },
                                  icon: Icon(Icons.check, color: Colors.green),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    rejectNotification(notification.notifId);
                                  },
                                  icon: Icon(Icons.close, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
