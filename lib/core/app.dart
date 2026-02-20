import 'package:country_code_picker/country_code_picker.dart';
import 'package:elms/common/cubits/theme_cubit.dart';
import 'package:elms/core/configs/app_settings.dart';
import 'package:elms/core/constants/app_constant.dart';
import 'package:elms/core/deep_linking/deep_link_manager.dart';
import 'package:elms/core/error_management/exception_handler.dart';
import 'package:elms/core/localization/app_localization.dart';
import 'package:elms/core/localization/get_language.dart';
import 'package:elms/core/localization/language_cubit.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/core/services/refresh_notifier.dart';
import 'package:elms/core/theme/app_theme.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/repository/cart_repository.dart';
import 'package:elms/features/category/cubits/fetch_category_cubit.dart';
import 'package:elms/features/category/repositories/category_repository.dart';
import 'package:elms/features/course/cubits/fetch_course_languages_cubit.dart';
import 'package:elms/features/course/screens/course_content_screen.dart';
import 'package:elms/features/course/services/course_content_notifier.dart';
import 'package:elms/features/wishlist/cubit/wishlist_action_cubit.dart';
import 'package:elms/features/wishlist/repository/wishlist_repository.dart';
import 'package:elms/features/policy/cubit/policy_cubit.dart';
import 'package:elms/features/policy/repository/policy_repository.dart';
import 'package:elms/features/settings/cubit/settings_cubit.dart';
import 'package:elms/features/settings/repository/settings_repository.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // Initialize RefreshNotifier service (doesn't require navigation context)
    Get.put(RefreshNotifier());

    // Delay initialization that requires navigation context until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExceptionHandler.registerErrorSnackbarService();
      DeepLinkManager.instance.initialize();
    });
  }

  @override
  void dispose() {
    DeepLinkManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(
          create: (context) => AuthenticationCubit(AuthRepository()),
        ),
        BlocProvider(
          create: (context) => FetchCategoryCubit(CategoryRepository()),
        ),
        BlocProvider(
          create: (context) => WishlistActionCubit(WishlistRepository()),
        ),
        BlocProvider(create: (context) => CartCubit(CartRepository())),
        BlocProvider(create: (context) => FetchCourseLanguagesCubit()),
        BlocProvider(create: (context) => PolicyCubit(PolicyRepository())),
        BlocProvider(create: (context) => SettingsCubit(SettingsRepository())),
        BlocProvider(create: (context) => LanguageCubit(GetLanguage())),
      ],
      child: Builder(
        builder: (context) {
          final AppTheme currentTheme = context
              .watch<ThemeCubit>()
              .getCurrentTheme(context);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: currentTheme.isDarkMode
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              getPages: AppRoutes.pages,
              title: AppSettings.appName,
              initialRoute: AppRoutes.splashScreen,

              localizationsDelegates: <LocalizationsDelegate>[
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                CountryLocalizations.getDelegate(enableLocalization: false),
              ],
              translationsKeys: AppLocalization.instance.translationKeys,
              locale: AppLocalization.instance.current,
              theme: currentTheme.theme,
              builder: (context, child) {
                final bool isRtl = LocalStorage.getIsRtl();
                return Directionality(
                  textDirection: isRtl
                      ? .rtl
                      : .ltr,
                  child: AppConstant.kEnableExperimentalMiniPlayer
                      ? ListenableBuilder(
                          listenable: CourseContentNotifier.instance,
                          builder: (context, _) {
                            final bool isOverlayVisible =
                                CourseContentNotifier.instance.isVisible;

                            return Stack(
                              children: [
                                child!,
                                if (isOverlayVisible)
                                  _buildCourseContentOverlay(),
                              ],
                            );
                          },
                        )
                      : child!,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseContentOverlay() {
    final course = CourseContentNotifier.instance.currentCourse;
    if (course == null) return const SizedBox.shrink();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Close the overlay when back button is pressed
        CourseContentNotifier.instance.hide();
      },
      child: const CourseContentBaseWidget(),
    );
  }
}
