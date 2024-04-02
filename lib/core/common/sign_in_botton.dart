import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInButton extends ConsumerWidget {
  final String text;
  final bool isLogin;
  final Color color;
  const SignInButton(
      {super.key,
      required this.text,
      required this.isLogin,
      required this.color});

  void authMethod(BuildContext context, WidgetRef ref) {
    if (isLogin) {
      // ref.read(authControllerProvider.notifier).signInWithGoogle(context);
      context.push("/sigin");
    } else {
      context.push("/register");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: ElevatedButton.icon(
        onPressed: () => authMethod(context, ref),
        label: Text(
          text,
          style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300]!,
              fontFamily: "FixelText",
              fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
      ),
    );
  }
}
