import 'package:http/http.dart' as http;

class VideoURLValidator {
  static const String youtubeRegex =
      r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$';
  static bool validateYouTubeVideoURL({required String url}) {
    final RegExp pattern = RegExp(youtubeRegex);
    final bool match = pattern.hasMatch(url);
    return match;
  }

  static Future<bool> checkVideoIsAvailOnYoutube({required String url}) async {
    var uri = Uri.parse("https://www.youtube.com/oembed?url=$url");
    var res = await http.get(uri);
    if (res.body.contains("title")) {
      return true;
    }
    return false;
  }
}
