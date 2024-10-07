import 'dart:developer';
import 'package:chattify/api/apis.dart';
import 'package:chattify/auth/loginscreen.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();


    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.tealAccent.shade700));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to CHATTIFY'),
      ),
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: _animation,
              child: Opacity(
                opacity: _animation.value,
                child: Image.asset(
                  'assets/chaticon.png',
                  width: mq.width * 0.4,
                  height: mq.width * 0.4,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width,
            child: const Text(
              'Chattify',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.tealAccent
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
