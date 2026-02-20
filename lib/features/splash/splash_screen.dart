import 'package:elms/core/notification/notification_manager.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/localization/language_cubit.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/settings/cubit/settings_cubit.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static Widget route() => const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    NotificationManager.init();

    // Fetch app settings
    context.read<SettingsCubit>().fetchAppSettings();

    // Fetch language list
    context.read<LanguageCubit>().fetchLanguages();

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Check if maintenance mode is enabled
      final settingsState = context.read<SettingsCubit>().state;
      if (settingsState is SettingsSuccess) {
        final maintenanceMode = settingsState.settings.maintainceMode;
        if (maintenanceMode == '1') {
          await Get.offAllNamed(AppRoutes.maintenanceModeScreen);
          return;
        }
      }

      await context.read<AuthenticationCubit>().waitAuthCheckProcessComplete;
      if (!mounted) return;

      final AuthenticationState authState = context
          .read<AuthenticationCubit>()
          .state;

      if (authState is UnAuthenticated && authState.isFirstTime) {
        await Get.offAllNamed(AppRoutes.onBoardingScreen);
      } else if (authState is UnAuthenticated) {
        await Get.offAllNamed(AppRoutes.loginScreen);
      } else if (authState is Authenticated ||
          authState is AuthenticatedAsGuest) {
        await Get.offAllNamed(AppRoutes.mainActivity);
      } else {
        // Fallback for error states
        await Get.offAllNamed(AppRoutes.loginScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primary,
      body: Center(child: CustomImage(AppIcons.appLogo)),
    );
  }
}
