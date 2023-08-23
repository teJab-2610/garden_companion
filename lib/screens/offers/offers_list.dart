import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/offers/create_offer.dart';
import 'package:garden_companion_2/screens/offers/offers_notificaction.dart';
import 'package:provider/provider.dart';
import '../../models/offers.dart';
import '../../providers/user_provider.dart';
import '../offers/offer_tile.dart';
import 'offer_list_self.dart';

class OffersList extends StatefulWidget {
  const OffersList({super.key});

  @override
  _OffersListState createState() => _OffersListState();
}

class _OffersListState extends State<OffersList> {
  late Future<List<String>> commonFollowers;
  late Future<List<Offer>> allOffers;
  @override
  void initState() {
    super.initState();
    commonFollowers = _loadCommonFollowers();
    allOffers = _getItemsForAllUsers();
  }

  Future<List<String>> _loadCommonFollowers() async {
    List<String> common = [];
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User currentUser = FirebaseAuth.instance.currentUser!;
    final uid = currentUser.uid;
    common = await userProvider.getCommonFollowers(uid);
    return common;
  }

  Future<List<Offer>> _getItemsForAllUsers() async {
    List<Offer> all = [];
    List<String> common = [];
    common = await commonFollowers;
    for (String uid in common) {
      if (uid != "dummy") {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('items')
            .get();

        final List<Offer> offers = querySnapshot.docs
            .map((doc) => Offer.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        //sort offers based on timestamps
        offers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        all.addAll(offers);
      }
    }
    return all;
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Notifications()),
    );
  }

  void _navigateToCreateOffer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewOfferScreen()),
    );
  }

  void _navigateToSelfOffers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OffersListSelf()),
    );
  }

  void printhere() {
    print("inside print");
    print(commonFollowers);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return FutureBuilder<List<String>>(
          future: commonFollowers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                  home: Scaffold(
                      body: Center(
                          child:
                              CircularProgressIndicator()))); // Loading indicator
            } else if (snapshot.hasError) {
              return Text('Error 1: ${snapshot.error}');
            } else {
              final List<String> commonFollowers = snapshot.data ?? [];
              return FutureBuilder<List<Offer>>(
                future: Future.value(allOffers),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MaterialApp(
                        home: Scaffold(
                            body: Center(child: CircularProgressIndicator())));
                  } else if (snapshot.hasError) {
                    return Text('Error 2: ${snapshot.error}');
                  } else {
                    final List<Offer> allOffers = snapshot.data ?? [];
                    return _buildBody(allOffers);
                  }
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBody(List<Offer> blogItems) {
    if (blogItems.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: const Color(0xFF5B8E55),
                  ),
                  const Text(
                    'Offers ',
                    style: TextStyle(
                      color: Color(0xFF5B8E55),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          _navigateToSelfOffers(context);
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          _navigateToNotifications(context);
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          print("On refresh");
                          commonFollowers = _loadCommonFollowers();
                          allOffers = _getItemsForAllUsers();
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _navigateToCreateOffer(context);
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'No offerings to show right now.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 212, 66, 66),
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: const Color(0xFF5B8E55),
                  ),
                  const Text(
                    'Offers ',
                    style: TextStyle(
                      color: Color(0xFF5B8E55),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          _navigateToSelfOffers(context);
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          _navigateToNotifications(context);
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          commonFollowers = _loadCommonFollowers();
                          allOffers = _getItemsForAllUsers();
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _navigateToCreateOffer(context);
                        },
                        color: const Color(0xFF5B8E55),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: GridView.builder(
                  itemCount: blogItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         BlogDetailScreen(blogItem: blogItems[index]),
                        //   ),
                        // );
                      },
                      child: BlogTile(blogItem: blogItems[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
