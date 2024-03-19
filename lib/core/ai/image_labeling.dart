import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';

Future<List<dynamic>> doImageLabeling(File? _image, dynamic imageLabeler) async {
  List<dynamic> _labels = [];
  InputImage inputImage = InputImage.fromFile(_image!);

  final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

  for (ImageLabel label in labels) {
    final String text = label.label;

    _labels.add(text);
  }

  return _labels;
}
