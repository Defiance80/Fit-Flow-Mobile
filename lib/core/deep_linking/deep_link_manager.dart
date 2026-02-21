import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:fitflow/core/configs/app_settings.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:get/get.dart';

class DeepLinkManager {
  DeepLinkManager._();

  static final DeepLinkManager instance = DeepLinkManager._();

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  bool _isInitialized = false;

  /// Initialize deep link handling
  /// Call this method in your app's initState or main function
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _appLinks = AppLinks();

    // Handle initial link if app was opened from terminated state
    await _handleInitialLink();

    // Handle links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    }, onError: (err) {});
  }

  String createDeepLink({required String slug}) {
    return '${AppSettings.webLink}/course-details/$slug?share=true';
  }

  Future<void> _handleInitialLink() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _handleDeepLink(initialUri.toString());
    }
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);

      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) {
        return;
      }

      final String route = pathSegments.first;

      switch (route) {
        case 'course-details':
          _handleCourseLink(pathSegments, uri.queryParameters);
          break;
        case 'instructor':
          _handleInstructorLink(pathSegments, uri.queryParameters);
          break;
        case 'category':
          _handleCategoryLink(pathSegments, uri.queryParameters);
          break;
        case 'cart':
          _navigateToRoute(AppRoutes.cartScreen);
          break;
        case 'checkout':
          _navigateToRoute(AppRoutes.checkoutScreen);
          break;
        case 'login':
          _navigateToRoute(AppRoutes.loginScreen);
          break;
        case 'signup':
          _navigateToRoute(AppRoutes.signupScreen);
          break;
        case 'wishlist':
          _navigateToRoute(AppRoutes.wishlistScreen);
          break;
        case 'my-learning':
          _navigateToRoute(AppRoutes.myLearningScreen);
          break;
        case 'notifications':
          _navigateToRoute(AppRoutes.notificationScreen);
          break;
        case 'profile':
          _handleProfileLink(pathSegments);
          break;
        case 'search':
          _handleSearchLink(uri.queryParameters);
          break;
        case 'help':
          _navigateToRoute(AppRoutes.helpSupportScreen);
          break;
        default:
      }
    } catch (e) {
      return;
    }
  }

  void _handleCourseLink(List<String> segments, Map<String, String> params) {
    if (segments.length < 2) {
      return;
    }

    final String courseId = segments[1];
    final String? tab = params['tab'];

    Get.toNamed(
      AppRoutes.courseDetailsScreen,
      arguments: {'courseId': courseId, 'tab': tab},
    );
  }

  void _handleInstructorLink(
    List<String> segments,
    Map<String, String> params,
  ) {
    if (segments.length < 2) {
      return;
    }

    final instructorId = segments[1];

    Get.toNamed(
      AppRoutes.instructorDetailsScreen,
      arguments: {'instructorId': instructorId},
    );
  }

  /// Handle category deep links
  /// Example: yourapp://category/789
  void _handleCategoryLink(List<String> segments, Map<String, String> params) {
    if (segments.length < 2) {
      return;
    }

    final categoryId = segments[1];

    Get.toNamed(
      AppRoutes.courseListScreen,
      arguments: {'categoryId': categoryId},
    );
  }

  void _handleProfileLink(List<String> segments) {
    if (segments.length < 2) {
      // Navigate to main screen with profile tab
      Get.toNamed(AppRoutes.mainActivity);
      return;
    }

    final action = segments[1];

    if (action == 'edit') {
      Get.toNamed(AppRoutes.editProfileScreen);
    }
  }

  void _handleSearchLink(Map<String, String> params) {
    final query = params['query'];

    Get.toNamed(AppRoutes.searchScreen, arguments: {'query': query});
  }

  /// Navigate to a specific route
  void _navigateToRoute(String route, {dynamic arguments}) {
    Get.toNamed(route, arguments: arguments);
  }

  /// Manually handle a deep link (useful for testing)
  void handleLink(String link) {
    _handleDeepLink(link);
  }

  /// Dispose the deep link subscription
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
  }
}
