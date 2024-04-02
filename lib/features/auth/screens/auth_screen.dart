import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viblify_app/core/common/sign_in_botton.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';

import '../../../core/common/loader.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      body: isLoading
          ? const Loader()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'viblify',
                  style: TextStyle(
                    fontSize: 55,
                    fontFamily: "LobsterTwo",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Hi dear user! , You are about to embark on a new experience on our digital platform. I hope you enjoy it and share your thoughts and ideas with the world around you.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                const SignInButton(
                  text: "Register",
                  isLogin: false,
                  color: Color.fromARGB(202, 135, 88, 255),
                ),
                const SignInButton(
                  text: "Login",
                  isLogin: true,
                  color: Color(0xff242424),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
