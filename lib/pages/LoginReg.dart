/*
Code for the login and registration page. Will be re-routed to the home page if the user is already logged in.
Else will be taken to login page if already has an accout or registration page if not.
This page also includes option to login with google 
*/
import 'package:flutter/material.dart';
import 'package:garden_companion/auth/google_signIn.dart';
import 'Login.dart';
import 'Register.dart';

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
            children: [
              //login button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: const Text('LOGIN'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  minimumSize: const Size(300, 50),
                  //add outline to the box
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 25,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: const Text('REGISTER'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  //increase size of box
                  minimumSize: const Size(300, 50),
                  onPrimary: Color.fromARGB(255, 6, 93, 0),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              //divider with text in Between lines

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 2,
                        color: Color.fromARGB(255, 3, 36, 1),
                        indent: 30,
                        endIndent: 2,
                      ),
                    ),
                    Text(
                      'Or Login with',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 2,
                        color: Color.fromARGB(255, 3, 36, 1),
                        indent: 2,
                        endIndent: 30,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 4,
              ),
              ElevatedButton(
                onPressed: () {
                  //login with google
                  Ggl_signIn().signInWithGoogle();
                },
                //Custom google logo as button without borders

                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  minimumSize: const Size(100, 50),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 25,
                  ),
                ),
                child: Image.asset(
                  'assets/images/google_logo.png',
                  height: 30,
                  width: 30,
                ),
                // style: ElevatedButton.styleFrom(
                //   primary: Colors.transparent,
                //   minimumSize: const Size(300, 50),
                //   //add outline to the box
                //   side: const BorderSide(
                //     color: Colors.white,
                //     width: 2,
                //   ),
                //   elevation: 0,
                //   textStyle: const TextStyle(
                //     fontFamily: 'Poppins',
                //     fontSize: 25,
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
