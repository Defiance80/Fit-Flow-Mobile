import 'package:fitflow/common/widgets/custom_popscope.dart';
import 'package:fitflow/core/login/guest_checker.dart';
import 'package:fitflow/features/cart/cubit/cart_cubit.dart';
import 'package:fitflow/features/course/cubits/fetch_course_languages_cubit.dart';
import 'package:fitflow/features/course/repository/course_repository.dart';
import 'package:fitflow/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:fitflow/features/course/services/course_content_notifier.dart';
import 'package:fitflow/features/home/cubits/fetch_featured_sections_cubit.dart';
import 'package:fitflow/features/home/cubits/fetch_slider_cubit.dart';
import 'package:fitflow/features/home/repositories/slider_repository.dart';
import 'package:fitflow/features/home/screens/home_screen.dart';
import 'package:fitflow/features/main/widgets/custom_bottom_nav_bar.dart';
import 'package:fitflow/features/health/screens/health_dashboard_screen.dart';
import 'package:fitflow/features/profile/screens/profile_screen.dart';
import 'package:fitflow/features/my_learning/screens/my_learning_screen.dart';
import 'package:fitflow/features/cart/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static Widget route() => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => FetchSliderCubit(SliderRepository())),
      BlocProvider(
        create: (context) => FetchFeaturedSectionsCubit(CourseRepository()),
      ),
    ],
    child: const MainScreen(),
  );
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Controllers

  final PageController pageController = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  void _pageControllerListener() {
    if (pageController.page != null) {
      _currentIndex.value = pageController.page!.toInt();
    }
  }

  // State
  @override
  void initState() {
    super.initState();

    if (!GuestChecker.value) {
      context.read<CartCubit>().fetch();
    }

    context.read<FetchCourseLanguagesCubit>().fetch();
    _setupPageController();
  }

  void _setupPageController() {
    // Remove listener if it was already added to avoid duplicates
    pageController.removeListener(_pageControllerListener);
    pageController.addListener(_pageControllerListener);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    pageController.removeListener(_pageControllerListener);
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    _currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      shouldPop: () async {
        if (Get.nestedKey(1)?.currentState
            case final NavigatorState? navigatorState
            when navigatorState != null && navigatorState.canPop()) {
          navigatorState.pop();
        } else if (CourseContentNotifier.instance.isVisible) {
          CourseContentNotifier.instance.hide();
        } else if (_currentIndex.value != 0) {
          // If not on home tab, navigate to home tab
          _onNavItemTapped(0);
        } else {
          return true;
        }

        return false;
      },
      child: _buildMainScaffold(),
    );
  }

  Widget _buildMainScaffold() {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const HomeScreen(),
          const MyLearningScreen(),
          BlocProvider(
            create: (context) => ApplyCouponCubit(),
            child: const CartScreen(),
          ),
          HealthDashboardScreen.route(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _currentIndex,
        builder: (BuildContext context, int value, Widget? child) {
          return CustomBottomNavBar(
            onTabSelected: _onNavItemTapped,
            selectedTabIndex: value,
          );
        },
      ),
    );
  }
}
