import 'package:flutter/material.dart';
import 'dart:async';

class TypingAnimation extends StatefulWidget {
  const TypingAnimation({Key? key}) : super(key: key);

  @override
  _TypingAnimationState createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: const Text(
        '...',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// TypingText widget for text animation
class TypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed; // Speed of typing animation

  const TypingText({
    Key? key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  _TypingTextState createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  late String _displayedText; // Text to display
  late Timer _timer; // Timer for animation
  int _currentIndex = 0; // Current character index

  @override
  void initState() {
    super.initState();
    _displayedText = ''; // Start with empty text
    _timer = Timer.periodic(widget.speed, (timer) {
      setState(() {
        if (_currentIndex < widget.text.length) {
          _displayedText += widget.text[_currentIndex]; // Add character
          _currentIndex++; // Move to next character
        } else {
          _timer.cancel(); // Stop animation when text is complete
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Ensure timer is canceled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayedText, style: widget.style);
  }
}
