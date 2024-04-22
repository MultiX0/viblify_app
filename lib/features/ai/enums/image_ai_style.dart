import 'package:flutter/material.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

enum AiImageStyle {
  noStyle,
  anime,
  moreDetails,
  cyberPunk,
  kandinskyPainter,
  aivazovskyPainter,
  malevichPainter,
  picassoPainter,
  goncharovaPainter,
  classicism,
  renaissance,
  oilPainting,
  pencilDrawing,
  digitalPainting,
  medievalStyle,
  render3D,
  cartoon,
  sovietCartoon,
  studioPhoto,
  portraitPhoto,
  khokhlomaPainter,
  christmas,
}

ImageAIStyle convertToImageAIStyle(AiImageStyle aiImageStyle) {
  switch (aiImageStyle) {
    case AiImageStyle.noStyle:
      return ImageAIStyle.noStyle;
    case AiImageStyle.anime:
      return ImageAIStyle.anime;
    case AiImageStyle.moreDetails:
      return ImageAIStyle.moreDetails;
    case AiImageStyle.cyberPunk:
      return ImageAIStyle.cyberPunk;
    case AiImageStyle.kandinskyPainter:
      return ImageAIStyle.kandinskyPainter;
    case AiImageStyle.aivazovskyPainter:
      return ImageAIStyle.aivazovskyPainter;
    case AiImageStyle.malevichPainter:
      return ImageAIStyle.malevichPainter;
    case AiImageStyle.picassoPainter:
      return ImageAIStyle.picassoPainter;
    case AiImageStyle.goncharovaPainter:
      return ImageAIStyle.goncharovaPainter;
    case AiImageStyle.classicism:
      return ImageAIStyle.classicism;
    case AiImageStyle.renaissance:
      return ImageAIStyle.renaissance;
    case AiImageStyle.oilPainting:
      return ImageAIStyle.oilPainting;
    case AiImageStyle.pencilDrawing:
      return ImageAIStyle.pencilDrawing;
    case AiImageStyle.digitalPainting:
      return ImageAIStyle.digitalPainting;
    case AiImageStyle.medievalStyle:
      return ImageAIStyle.medievalStyle;
    case AiImageStyle.render3D:
      return ImageAIStyle.render3D;
    case AiImageStyle.cartoon:
      return ImageAIStyle.cartoon;
    case AiImageStyle.sovietCartoon:
      return ImageAIStyle.sovietCartoon;
    case AiImageStyle.studioPhoto:
      return ImageAIStyle.studioPhoto;
    case AiImageStyle.portraitPhoto:
      return ImageAIStyle.portraitPhoto;
    case AiImageStyle.khokhlomaPainter:
      return ImageAIStyle.khokhlomaPainter;
    case AiImageStyle.christmas:
      return ImageAIStyle.christmas;
    default:
      throw ArgumentError('Unknown AiImageStyle: $aiImageStyle');
  }
}

void showStylePicker(
    {required BuildContext context,
    required AiImageStyle currentStyle,
    required ValueChanged<AiImageStyle> onStyleSelected}) {
  // Display the modal bottom sheet with the styles
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        children: AiImageStyle.values.map((style) {
          // Check if the current style is the one selected
          bool isSelected = style == currentStyle;

          return ListTile(
            leading: const Icon(
              Icons.style,
              color: Colors.white,
            ),
            title: Text(
              style.toString().split('.').last, // Display the style name
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white, // Change color for selected
              ),
            ),
            onTap: () {
              // Call the callback with the selected style
              onStyleSelected(style);
              Navigator.pop(context); // Close the modal bottom sheet
            },
          );
        }).toList(),
      );
    },
  );
}
