import 'package:flutter/material.dart';

class MyEmptyShowen extends StatelessWidget {
  final String text;
  const MyEmptyShowen({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/catCry.gif",
              height: MediaQuery.of(context).size.width / 4,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(text)
          ],
        ),
      ),
    );
  }
}
