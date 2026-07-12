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

    Timer(const Duration(seconds: 3), () {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Home_Screen(),
        ),
      );

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        fit: StackFit.expand,

        children: [

          Image.asset(
            "assets/image/files.jpg",
            fit: BoxFit.cover,
          ),

          Container(
            color: Colors.black.withOpacity(.45),
          ),

          Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: const [

              Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
                size: 90,
              ),

              SizedBox(height: 20),

              Text(
                "DOCUFLOW",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Manage • Edit • Convert",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              SizedBox(height: 50),

              CircularProgressIndicator(
                color: Colors.white,
              ),

            ],
          )

        ],
      ),
    );
  }
}