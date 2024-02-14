import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
