import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/home/search_screen.dart';
import 'package:garden_companion_2/screens/home/splash_screen.dart';
import 'package:garden_companion_2/screens/plant_health/imagesearchscreens.dart';
import 'package:garden_companion_2/screens/plant_searcher/plant_search.dart';
import 'package:garden_companion_2/screens/offers/offers_list.dart';
import 'package:garden_companion_2/screens/posts/create_post_screen.dart';
import 'package:garden_companion_2/screens/profile_screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../Groups/groups_list.dart';
import '../groups/groups_page.dart';
import '../posts/posts_screens.dart';
import '../plant_id/camera_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SplashScreen()));

    // Clear route history
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false);
  }

  void _navigateToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OffersList()),
    );
  }

  void _navigateToGroupsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsPage()),
    );
  }

  void _navigateToPostsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostsScreen()),
    );
  }

  Future<bool> redirectto() async {
    //exit app
    return true;
  }

  void _navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPostScreen()),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Home Page'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _navigateToSearchPage(context),
        ),
        IconButton(
          icon: const Icon(Icons.plus_one),
          onPressed: () => _navigateToCreatePostScreen(context),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      //make it blue
      selectedItemColor: const Color.fromARGB(255, 43, 114, 7),
      unselectedItemColor: Colors.grey,
      //make the bar color blue

      backgroundColor: const Color.fromARGB(255, 88, 249, 13),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          label: 'Camera',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlantSearchScreen()),
          );
        }
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImageSearchScreen()),
          );

        }
        if (index == 3) {
          _navigateToPostsPage(context);
        }
        if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: WillPopScope(
        onWillPop: redirectto,
        child: const Center(
          child: Text('Hello World'),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}
