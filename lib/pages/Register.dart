import 'package:flutter/material.dart';
import 'textfield.dart';

class Register extends StatelessWidget {
  Register({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

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
              //email textfield
              MyTextField(
                hintText: 'Email',
                controller: emailController,
              ),
              //phone textfield
              MyTextField(
                hintText: 'Phone',
                controller: phoneController,
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
                child: const Text('REGISTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
