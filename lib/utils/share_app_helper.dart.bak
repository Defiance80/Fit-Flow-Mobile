import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Helper class to handle app sharing functionality
class ShareAppHelper {
  /// Private constructor to prevent instantiation
  ShareAppHelper._();

  /// Shares the app with a default message
  ///
  /// You can customize the message and include app store links
  static Future<void> shareApp(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    try {
      const String appName = 'ELMS';
      const String message =
          'Check out $appName - Your complete E-Learning Management System!\n\n'
          'Download now:\n'
          'Android: [Play Store Link]\n'
          'iOS: [App Store Link]';
      await Share.share(
        message,
        subject: 'Check out $appName',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      //
    } catch (e) {
      // Handle any sharing errors silently
      // You can add error logging here if needed
    }
  }

  /// Shares the app with a custom message
  ///
  /// [message] - Custom message to share
  /// [subject] - Optional subject for the share dialog
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
