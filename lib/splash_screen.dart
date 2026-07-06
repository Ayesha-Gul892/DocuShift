
import 'dart:async';

import 'package:docushift/home_screen.dart';
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
    Timer(const Duration(seconds:50), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home_Screen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {   return Scaffold(
    body: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
           Colors.white,
            Colors.blue.shade400,

          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // LOGO
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.blue,
              size: 70,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "DOCUSHIFT",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Convert CSV Files to PDF",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 50),

          const CircularProgressIndicator(
            color: Colors.blue,

          ),
          const Text(
            "loading",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
          ),

        ],
      ),

    ),
  );
  }
}