import 'package:flutter/material.dart';

//
class BotBody extends StatelessWidget {
  const BotBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "No Data Yet..",
            style: TextStyle(fontFamily: "FixelDisplay", color: Colors.grey[200], fontSize: 32),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            "Engage your imagination",
            style: TextStyle(
              fontFamily: "FixelText",
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
