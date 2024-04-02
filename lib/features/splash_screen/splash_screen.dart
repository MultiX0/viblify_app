import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        if (FirebaseAuth.instance.currentUser != null) {
          context.go("/");
        } else {
          context.go("/login");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TitleWidget();
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'viblify',
          style: TextStyle(fontSize: 85, fontFamily: "LobsterTwo"),
        ),
      ),
    );
  }
}
