import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

class VideoURLValidator {
  static bool isYouTubeLink(String link) {
    // Define a regular expression pattern for YouTube links
    RegExp youtubePattern = RegExp(r'(https?://)?(www\.)?'
        '(youtube|youtu|youtube-nocookie)\.(com|be)/'
        '(watch\?v=|embed/|v/|.+\?v=)?([^&=%\?]{11})');

    // Check if the link matches the pattern
    return youtubePattern.hasMatch(link);
  }

  static Future<bool> checkVideoIsAvailableOnYoutube(String url) async {
    try {
      var uri = Uri.parse("https://www.youtube.com/oembed?url=$url");
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the response to check if the "title" field exists
        if (response.body.contains("title")) {
          return true;
        }
      }

      return false;
    } catch (e) {
      // Handle exceptions, e.g., if the request fails
      return false;
    }
  }

  static String extractYouTubeVideoId(String youtubeUrl) {
    RegExp regExp = RegExp(
      r"(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})",
    );

    var match = regExp.firstMatch(youtubeUrl);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    } else {
      return '';
    }
  }

  static String getYouTubeThumbnail(String videoId,
      {String quality = 'maxresdefault'}) {
    // Construct the YouTube thumbnail URL based on the video ID
    // You can specify quality as 'default', 'mqdefault', 'hqdefault', 'sddefault', 'maxresdefault'
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  static Future<String?> getVideoTitle(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final document = htmlParser.parse(response.body);

        // Extract the video title from the HTML document
        final titleElement =
            document.querySelector('meta[property="og:title"]');
        if (titleElement != null) {
          return titleElement.attributes['content'];
        }
      }
    } catch (e) {
      print('Error fetching video title: $e');
    }

    return null;
  }
}
