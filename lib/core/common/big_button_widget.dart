import 'package:flutter/material.dart';
import 'package:viblify_app/theme/pallete.dart';

class BigButtonWidget extends StatelessWidget {
  const BigButtonWidget(
      {super.key,
      required this.text,
      required this.isLoading,
      required this.height,
      required this.onPressed,
      required this.backgroundColor});

  final String text;
  final double height;
  final bool isLoading;
  final Color backgroundColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLoading ? backgroundColor.withOpacity(0.5) : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DenscrodSizes.borderRadius),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "FixelText",
                )),
      ),
    );
  }
}
