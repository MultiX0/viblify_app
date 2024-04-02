// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';

Future<List<dynamic>> doImageLabeling(File? image, dynamic imageLabeler) async {
  List<dynamic> _labels = [];
  InputImage inputImage = InputImage.fromFile(image!);

  final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

  for (ImageLabel label in labels) {
    final String text = label.label;

    _labels.add(text);
  }

  return _labels;
}
