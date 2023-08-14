import 'package:flutter/material.dart';
import '../components/textfield.dart';
import '../components/my_button2.dart';

class Register extends StatelessWidget {
  Register({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  void register() async {}

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
              const Text(
                'Register',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              //username textfield
              MyTextField(
                hintText: 'Username',
                controller: usernameController,
                obscureText: false,
              ),
              //password textfield
              MyTextField(
                hintText: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              //email textfield
              MyTextField(
                hintText: 'Email',
                controller: emailController,
                obscureText: false,
              ),
              //phone textfield
              MyTextField(
                hintText: 'Phone',
                controller: phoneController,
                obscureText: false,
              ),
              //register button
              MyButton2(
                text: 'Register',
                onTap: () {
                  register();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
