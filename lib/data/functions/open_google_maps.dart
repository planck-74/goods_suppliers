import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double latitude, double longitude) async {
  final Uri googleMapsUrl =
      Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $googleMapsUrl';
  }
}
