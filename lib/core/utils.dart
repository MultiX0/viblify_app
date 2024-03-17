import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';
import 'package:viblify_app/features/post/controller/post_controller.dart';

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

Future<File?> cropImage(File? imageFile) async {
  CroppedFile? cropped = await ImageCropper().cropImage(
    sourcePath: imageFile!.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
    ],
  );

  if (cropped != null) {
    return File(cropped.path);
  }
  return null;
}

bool containsUrl(String input) {
  // Regular expression to match a URL
  final urlRegExp = RegExp(
    r'https?://(?:www\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:/[^/\s]*)?',
    caseSensitive: false,
  );

  // Check if the input string contains a URL
  return urlRegExp.hasMatch(input);
}

List<String> extractUrls(String text) {
  final RegExp urlRegExp = RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    caseSensitive: false,
  );

  Iterable<Match> matches = urlRegExp.allMatches(text);
  List<String> urls = matches.map((match) => match.group(0)!).toList();
  return urls;
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
  FlutterClipboard.copy('https://viblify.com/p/$feedID').then((value) {
    final uid = ref.watch(userProvider)!.userID;

    Fluttertoast.showToast(msg: "تم نسخ رابط المنشور بنجاح");
    ref.watch(postControllerProvider.notifier).sharePost(feedID, uid);
  });
}

void copyProfileUrl(String uid, BuildContext context) {
  FlutterClipboard.copy('https://viblify.com/u/$uid').then((value) {
    Navigator.of(context).pop();
    Fluttertoast.showToast(msg: "تم نسخ رابط الملف الشخصي");
  });
}

void copyDashUrl(Map<String, dynamic> data, BuildContext context) {
  final encodedExtraData = Uri.encodeComponent(jsonEncode(data));

  FlutterClipboard.copy('https://viblify.com/dash/view/$encodedExtraData').then((value) {
    Navigator.of(context).pop();
    Fluttertoast.showToast(msg: "تم نسخ الرابط");
  });
}
