import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/auths/login_screen.dart';
import 'package:garden_companion_2/screens/auths/register_screen.dart';
import 'package:garden_companion_2/providers/auth_provider.dart';
import 'package:garden_companion_2/screens/home/home_page.dart';
import 'package:provider/provider.dart';

class LoginReg extends StatefulWidget {
  const LoginReg({Key? key}) : super(key: key);

  @override
  _LoginRegState createState() => _LoginRegState();
}

class _LoginRegState extends State<LoginReg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.none,
            image: AssetImage('assets/images/login_bg.png'),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 80, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'To GardenCompanion',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Feel Fresh with Plants World.\nIt will enhance your living space.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(300, 50),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                child: const Text('LOGIN'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 6, 93, 0), backgroundColor: Colors.white,
                  minimumSize: const Size(300, 50),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                child: const Text('REGISTER'),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Color.fromARGB(255, 3, 36, 1),
                thickness: 2,
                indent: 50,
                endIndent: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                'Or Login with',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              ElevatedButton(
                onPressed: () {
                  _onGoogleSignInPressed(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(300, 50),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                child: Image.asset(
                  'assets/images/google_logo.png',
                  height: 30,
                  width: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onGoogleSignInPressed(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.loginWithGoogle();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } catch (error) {
      _showErrorDialog(context, 'Google Sign-In failed: $error');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
