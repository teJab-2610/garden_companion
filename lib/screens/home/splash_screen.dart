import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auths/signin_method.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToReqScreen(); // Navigate to LoginScreen after a delay
  }

  Future<void> _navigateToReqScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginReg()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/app_intro.jpg'), // Update with your image path
            fit: BoxFit.none, // This ensures the image covers the entire screen
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'GardenCompanion', // Update with your app's name
                style: TextStyle(
                  fontFamily: 'Sf',
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10), // Adding space
              Text(
                'Your Gardening Assignment', // Your caption goes here
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}