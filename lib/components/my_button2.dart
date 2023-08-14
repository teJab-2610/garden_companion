import 'package:flutter/material.dart';

class MyButton2 extends StatelessWidget {
  final String text;
  final Function()? onTap;

  const MyButton2({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 148, 160, 137),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text(
            'Register',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'sf',
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
