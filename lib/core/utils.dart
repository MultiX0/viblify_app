import 'dart:typed_data';

import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:viblify_app/encrypt/encrypt.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';

String encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? '';

void showSnackBar(BuildContext context, String text) {
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

  if (scaffoldMessenger != null) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }
}

Future<FilePickerResult?> pickImage() async {
  final image = FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  return image;
}

String extractWebsiteName(String url) {
  try {
    Uri uri = Uri.parse(url);
    String host = uri.host;

    // Remove 'www.' if present
    if (host.startsWith('www.')) {
      host = host.substring(4);
    }

    return host;
  } catch (e) {
    // Handle invalid URL or parsing errors
    print('Error extracting website name: $e');
    return '';
  }
}

void copyPostUrl(String feedID, WidgetRef ref) {
  final id = encrypt(feedID, encryptionKey, Uint8List(16));
  FlutterClipboard.copy('https://viblify.com/p/$id').then((value) {
    final uid = ref.watch(userProvider)!.userID;

    Fluttertoast.showToast(msg: "تم نسخ رابط المنشور بنجاح");
    ref.watch(postControllerProvider.notifier).sharePost(feedID, uid);
  });
}

void copyProfileUrl(String uid, BuildContext context) {
  final id = encrypt(uid, encryptionKey, Uint8List(16));

  FlutterClipboard.copy('https://viblify.com/u/$id').then((value) {
    Navigator.of(context).pop();
    Fluttertoast.showToast(msg: "تم نسخ رابط الملف الشخصي");
  });
}
