import 'package:flutter/material.dart';
import '../utils/hex2color.dart';

class Pallete {
  // Colors
  static const blackColor = Color.fromARGB(255, 13, 16, 19); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: DenscordColors.scaffoldBackground,
    cardColor: greyColor,
    iconTheme: IconThemeData(color: Colors.blueGrey[300]),
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      elevation: 0,
      titleTextStyle: const TextStyle(fontFamily: "LobsterTwo", fontSize: 24),
      backgroundColor: DenscordColors.scaffoldBackground,
      iconTheme: const IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: redColor,
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    primaryColor: redColor,
  );
}

class DenscordColors {
  static Color scaffoldBackground = HexColor.fromHex("#0D0D0D");
  static Color scaffoldForeground = HexColor.fromHex("#1E1E1E");
  static Color buttonPrimary = HexColor.fromHex("#8758FF");
  static Color buttonSecondary = HexColor.fromHex("#242424");
  static Color textSecondary = HexColor.fromHex("#989898");
  static Color textHint = HexColor.fromHex("#444444");
  static Color link = HexColor.fromHex("#4BA7F5");
}

class DenscrodSizes {
  static double borderRadius = 10.0;
}
