import 'package:flutter_dotenv/flutter_dotenv.dart';

final encryptKey = dotenv.env['ENCRYPTION_KEY'] ?? "";

class Constant {
  static const logoPath = 'assets/images/logo.png';
  static const cryPath = 'assets/images/cry.gif';
  static const loginEmotePath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';

  static const bannerDefault =
      'https://firebasestorage.googleapis.com/v0/b/viblify.appspot.com/o/bannerPic.jpg?alt=media&token=1a046e78-2b1d-4bd0-a83e-b77985a3219f';
  static const avatarDefault =
      'https://firebasestorage.googleapis.com/v0/b/viblify.appspot.com/o/groupPic.jpg?alt=media&token=0b80e30b-c536-4f5d-8a88-564d9b66302d';
  static const userIcon =
      "https://firebasestorage.googleapis.com/v0/b/viblify.appspot.com/o/user.jpg?alt=media&token=beba7cb7-c3db-4c51-8449-edc0fac54605";
}
