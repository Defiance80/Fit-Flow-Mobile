import 'dart:io';
import 'package:fitflow/core/app.dart';
import 'package:fitflow/core/localization/app_localization.dart';
import 'package:fitflow/core/notification/notification_manager.dart';
import 'package:fitflow/utils/local_storage.dart';
import 'package:fitflow/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitflow/firebase_options.dart';

///V-1.0.1
Future<void> main() async {
  ///This line is to enable api logging in dev tools
  HttpClient.enableTimelineLogging = true;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([.portraitUp]);
  await LocalStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AppLocalization.instance.init();

  await Utils.getSIMCountry();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  // Override default error widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const .all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              details.exception.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: .bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              textAlign: .center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  };

  runApp(const App());
}
