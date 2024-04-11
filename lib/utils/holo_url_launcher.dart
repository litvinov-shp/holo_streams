import 'package:url_launcher/url_launcher.dart';

Future<bool> launchHoloUrl(String url) async {
  final uri = Uri.parse(url);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> watchVideo(String videoId) => launchHoloUrl('https://youtube.com/watch?v=$videoId');
