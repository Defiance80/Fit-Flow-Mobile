import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';

class NotificationManager {
  static bool initialized = false;

  static AwesomeNotifications instance = AwesomeNotifications();
  static List<NotificationChannel> channels = [
    NotificationChannel(
      channelKey: 'default',
      channelName: 'Default',
      channelDescription: 'Notification tests as alerts',
      playSound: true,
      onlyAlertOnce: true,
      groupAlertBehavior: GroupAlertBehavior.All,
      importance: NotificationImportance.High,
      defaultPrivacy: NotificationPrivacy.Public,
      defaultColor: Colors.deepPurple,
      ledColor: Colors.deepPurple,
    ),
  ];

  static void init() async {
    await FirebaseMessaging.instance.requestPermission();
    if (!initialized) {
      ///Initialize awesome notification
      await instance.initialize(null, channels, debug: kDebugMode);

      FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
        
        await instance.createNotification(
          content: NotificationContent(
            id: Random().nextInt(5000),
            channelKey: 'default',
            title: event.data['title'],
            body: event.data['body']?.toString() ?? '',
            payload: event.data.cast<String, String>(),
          ),
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        onTap(event.data);
      });

      // Check for initial message (app opened from terminated state)
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
      
        await onTap(initialMessage.data);
      }

      await instance.setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
      );

      initialized = true;
    }
  }

  static Future<void> onTap(Map<String, dynamic> data) async {
    final String? type = data['type']?.toString();

    if (type == null) {
      return;
    }

    switch (type) {
      case 'course':
        await _handleCourseNotification(data);
        break;
      case 'url':
        await _handleUrlNotification(data);
        break;
      default:
        break;
    }
  }

  /// Handle course type notifications
  /// Navigate to course content screen if user is enrolled, otherwise to details screen
  static Future<void> _handleCourseNotification(
    Map<String, dynamic> data,
  ) async {
    final int? courseId = int.tryParse(data['id']?.toString() ?? '');

    if (courseId == null) {
      return;
    }

    // Fetch course details to check enrollment status
    final repository = CourseRepository();
    final courseDetails = await repository.fetchCourseDetails(courseId);

    // Navigate based on enrollment status
    if (courseDetails.isPurchased) {
      if (AppConstant.kEnableExperimentalMiniPlayer) {
        // User is enrolled - show course content in stack with mini player support
        CourseContentNotifier.instance.showCourse(courseDetails);
      } else {
        // User is enrolled - navigate to course content screen using push
        await Get.toNamed(
          AppRoutes.courseContentScreen,
          arguments: CourseContentScreenArguments(course: courseDetails),
        );
      }
    } else {
      // User is not enrolled - navigate to course details screen
      await Get.toNamed(
        AppRoutes.courseDetailsScreen,
        arguments: CourseDetailsScreenArguments(course: courseDetails),
      );
    }
  }

  /// Handle URL type notifications
  /// Open the link in external browser
  static Future<void> _handleUrlNotification(Map<String, dynamic> data) async {
    final String? urlString = data['link']?.toString();

    if (urlString == null || urlString.isEmpty) {
      return;
    }

    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    if (action.payload != null) {
      // Convert Map<String, String?> to Map<String, dynamic>
      final Map<String, dynamic> payload = Map<String, dynamic>.from(
        action.payload!,
      );
      await onTap(payload);
    }
  }
}

@pragma("vm:entry-point")
Future<void> backgroundHandler(RemoteMessage message) async {}
