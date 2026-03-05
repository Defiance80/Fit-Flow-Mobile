import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppHelper {
  ShareAppHelper._();

  static Future<void> shareApp(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    try {
      const String appName = 'Fit Flow';
      const String message =
          'Check out $appName - Your Personal Fitness & Training Platform!\n\n'
          'Download now:\n'
          'Android: [Play Store Link]\n'
          'iOS: [App Store Link]';
      await Share.share(
        message,
        subject: 'Check out $appName',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      // Handle any sharing errors silently
    }
  }

  static Future<void> shareAppWithMessage({
    required String message,
    String? subject,
  }) async {
    try {
      await Share.share(message, subject: subject);
    } catch (e) {
      // Handle any sharing errors silently
    }
  }
}
