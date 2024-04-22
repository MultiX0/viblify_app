import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';
import 'dart:ui' as ui;

Widget parseText(String text) {
  List<Widget> widgets = [];

  // Find and replace the text between ** with bold and larger text
  RegExp boldRegex =
      RegExp(r'\*\*(\S(?:.*?\S)?)\*\*'); // Match non-whitespace characters surrounded by **
  text.splitMapJoin(
    boldRegex,
    onMatch: (Match match) {
      bool isArabic = Bidi.hasAnyRtl(match.group(1)!);
      String boldText =
          match.group(1)!; // Extract matched group without leading/trailing whitespace
      widgets.add(
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            boldText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          ),
        ),
      );
      return '';
    },
    onNonMatch: (String nonMatch) {
      bool isArabic = Bidi.hasAnyRtl(nonMatch);
      widgets.add(Linkable(
        textColor: Colors.grey[300],
        text: nonMatch.replaceAll('*', '').replaceAll('\n\n', '\n'),
        style: TextStyle(color: Colors.grey[300]),
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      ));
      return '';
    },
  );

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}
