import 'package:flutter/material.dart';

class LeadingBackButton extends StatelessWidget {
  final VoidCallback func;
  const LeadingBackButton({super.key, required this.func});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: func,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          Text(
            "Back",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
