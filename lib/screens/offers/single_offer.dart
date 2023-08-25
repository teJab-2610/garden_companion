import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garden_companion_2/screens/offers/offers_notificaction.dart';
import '../../models/offers.dart';

class PresentOffer extends StatefulWidget {
  final Offer offer;
  PresentOffer({required this.offer});
  @override
  _PresentOfferState createState() => _PresentOfferState();
}

class _PresentOfferState extends State<PresentOffer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream;
  final TextEditingController _textFieldController = TextEditingController();
  String defaultImages =
      "https://firebasestorage.googleapis.com/v0/b/gardencompanion2.appspot.com/o/images%2Fdummy-post-horisontal-thegem-blog-default.jpg?alt=media&token=34f778d3-d19f-4cb9-9fb4-ec7398c4983a";
  @override
  void initState() {
    super.initState();
    _itemsStream = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('items')
        .snapshots();
  }

  Future<void> createNotification(Offer offer, String beel) async {
    try {
      //check if offer exists in firebase collections
      beel = beel.trim();
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(offer.originaluid)
          .collection('items')
          .where('itemId', isEqualTo: offer.itemId)
          .get();
      print("Step 1 done");
      if (querySnapshot.docs.isEmpty) {
        showSnackBar("Sorry! This offer was closed");
        print("Offer Closed");
        Navigator.pop(context);
        return;
      } else {
        print("else");
        print(FirebaseAuth.instance.currentUser!.uid);
        print(beel);
        final QuerySnapshot data = await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('items')
            .where('title', isEqualTo: beel)
            .get();
        print("else done");
        if (data.docs.isEmpty) {
          print("in if");
          showSnackBar("Sorry! This offer was closed");
          Navigator.pop(context);
          return;
        } else {
          // print("adding");
          // print(data.docs[0].get('itemId'));
          // print(FirebaseAuth.instance.currentUser!.uid);
          // print(offer.originaluid);
          // print(offer.itemId);
          final senderItemId = data.docs[0].get('itemId');
          final senderUid = FirebaseAuth.instance.currentUser!.uid;
          final receiverUid = offer.originaluid;
          final receiverItemId = offer.itemId;
          final senderItemTitle = data.docs[0].get('title');
          print(receiverUid);
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
            'timestamp': Timestamp.now(),
            'senderItemTitle': senderItemTitle,
            'recieverItemTitle': offer.title,
          });
          print("added");
          showSnackBar("Offer Created");
          Navigator.pop(context);
          return;
        }
      }
    } catch (error) {
      print('Error in creating notification');
    }
  }

  Widget showSnackBar(String Message) {
    return SnackBar(
      content: Text(Message),
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading indicator
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final items = snapshot.data?.docs ?? [];
          items.removeWhere((item) => item['author'] == 'dummy');
          for (var item in items) print(item.data());

          final titles = items.map((item) => item['title'] as String).toList();
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Color.fromARGB(255, 238, 245, 231),
                  elevation: 4.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(widget.offer.imageUrl.isNotEmpty
                          ? widget.offer.imageUrl
                          : defaultImages),
                      ListTile(
                        title: Text(widget.offer.title,
                            style: TextStyle(fontSize: 20.0, fontFamily: 'Sf')),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(""),
                            Text('Author: ${widget.offer.author}',
                                style: TextStyle(fontFamily: 'Sf')),
                            Text(""),
                            Text('Original ID: ${widget.offer.originaluid}',
                                style: TextStyle(fontFamily: 'Sf')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Card(
                  elevation: 4.0,
                  color: const Color.fromARGB(
                      255, 238, 245, 231), // Set the background color
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              // padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  controller: _textFieldController,
                                  decoration: const InputDecoration(
                                      hintText: '  Enter text here',
                                      hintStyle: TextStyle(fontFamily: 'Sf')),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    if (!titles.contains(value)) {
                                      return 'Entered Value is not in your offers list!';
                                    }
                                    return null;
                                  }),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () async {
                              print("outside");
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                print("inside");
                                try {
                                  await createNotification(
                                      widget.offer, _textFieldController.text);
                                  print("tried");
                                } catch (error) {
                                  _showErrorDialog(
                                      context, 'Registration failed: $error');
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Card(
                  color: const Color.fromARGB(255, 238, 245, 231),
                  elevation: 4.0,
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('List of Items You Have :',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Sf',
                                fontWeight: FontWeight.bold)),
                      ),
                      //dashed line
                      const Divider(
                        height: 1.0,
                        indent: 20.0,
                        endIndent: 20.0,
                        color: Colors.black,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: titles.map((string) {
                          return ListTile(
                            title: Text("-->   ${string}",
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: 'Sf')),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
