
import 'dart:async';

import 'package:file_manager/home_screen.dart';
import 'package:flutter/material.dart';

class Splash_screen extends StatefulWidget {
  const Splash_screen({super.key});

  @override
  State<Splash_screen> createState() => _Splash_screenState();
}

class _Splash_screenState extends State<Splash_screen> {
  @override
  void initState() {
    super.initState();

    // delay then go to home screen
    Timer(const Duration(seconds:5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home_Screen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/image/files.jpg"),
        )
          ),

          ),

    );
  }

}