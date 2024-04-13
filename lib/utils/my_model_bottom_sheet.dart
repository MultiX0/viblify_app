import 'package:flutter/material.dart';

void moreData({required VoidCallback onTap, required BuildContext context}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('حذف التعليق'),
            onTap: onTap,
          ),
        ],
      );
    },
  );
}
