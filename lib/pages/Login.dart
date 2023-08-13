/*
Page for Login after user clicks on /login Button in LoginReg Page  having two boxes username and password to fill the details 
*/
import 'package:flutter/material.dart';
import 'textfield.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //login page that has only two text fields defined in textfield.dart and has a hint text and a controller to store the value entered by the user
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
              //username textfield
              MyTextField(
                hintText: 'Username',
                controller: usernameController,
              ),
              //password textfield
              MyTextField(
                hintText: 'Password',
                controller: passwordController,
              ),
              //login button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 3, 36, 1),
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
                child: const Text('LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
