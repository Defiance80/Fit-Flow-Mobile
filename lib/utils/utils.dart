import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_region/device_region.dart';

class Utils {
  static CountryCode? simCountry;

  static bool isYoutubeVideo(String url) {
    final RegExp regex = RegExp(
        r"(?:https?:\/\/(?:[0-9a-z]+\.)+youtube\.com\/watch\?v=|https?:\/\/youtu\.be\/)([\w]{11})");
    return regex.hasMatch(url);
  }

  static String? extractYoutubeVideoId(String url) {
    final regex = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  static Future<CountryCode?> getSIMCountry() async {
    try {
      final String? code = await DeviceRegion.getSIMCountryCode();
      if (code != null) {
        simCountry = CountryCode.fromCountryCode(code.toUpperCase());
        return simCountry;
      }
    } catch (_) {}
    return null;
  }
}
