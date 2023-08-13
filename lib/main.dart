import 'package:flutter/material.dart';
import 'pages/LoginReg.dart';

void main() {
  runApp(const MyApp());
}

//My App with scaffold saying hello world
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //return page with only background image in the folder assets/login_bg.png . file name is "login_bg.png" .no  any other button
    return const MaterialApp(
      home: LoginReg(),
    );
  }
}
