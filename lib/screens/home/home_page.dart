import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/home/search_screen.dart';
import 'package:garden_companion_2/screens/home/splash_screen.dart';
import 'package:garden_companion_2/screens/posts/create_post_screen.dart';
import 'package:garden_companion_2/screens/profile_screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../Groups/groups_list.dart';
import '../posts/posts_screens.dart';

class HomePage extends StatefulWidget {
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
        context, MaterialPageRoute(builder: (context) => SplashScreen()));

    // Clear route history
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (route) => false);
  }

  void _navigateToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _navigateToPostsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostsScreen()),
    );
  }

  Future<bool> redirectto() async {
    //exit app
    return true;
  }

  void _navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPostScreen()),
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
      selectedItemColor: const Color.fromARGB(255, 249, 13, 13),
      //make the bar color blue
      backgroundColor: Color.fromARGB(255, 88, 249, 13),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_enhance),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
      ],
      onTap: (index) {
        if (index == 1) {
          _navigateToProfilePage(context);
        }
        if (index == 2) {
          // _navigateToProfilePage(context);
        }
        if (index == 3) {
          _navigateToPostsPage(context);
        }
        if (index == 4) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => GroupChats()),
          // );
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
