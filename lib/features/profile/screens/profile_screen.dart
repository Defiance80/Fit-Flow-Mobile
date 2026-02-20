import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';

import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_inkwell.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/profile_card.dart';
import 'package:elms/core/configs/app_settings.dart';

import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/common/cubits/theme_cubit.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/policy/screens/policy_screen.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/profile/cubit/delete_account_cubit.dart';
import 'package:elms/features/profile/widgets/account_security_bottomsheet.dart';
import 'package:elms/features/profile/widgets/delete_account_dialog.dart';
import 'package:elms/features/profile/widgets/logout_dialog.dart';
import 'package:elms/features/settings/cubit/settings_cubit.dart';
import 'package:elms/utils/extensions/color_extension.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/share_app_helper.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  void _onTapShareApp() {
    ShareAppHelper.shareApp(context);
  }

  Future<void> _onTapRating() async {
    final InAppReview inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing(
          appStoreId: AppSettings.appStoreAppId,
        );
      }
    } catch (e) {
      // Fallback to opening store listing if native review fails
      await inAppReview.openStoreListing(appStoreId: AppSettings.appStoreAppId);
    }
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        String profileURL = '';
        String userName = '';
        String? userEmail = '';

        if (state is Authenticated) {
          profileURL = state.user?.profile ?? '';
          userName = state.user?.name ?? '';
          userEmail = state.user?.email;
        } else {
          profileURL = AppIcons.profilePlaceholder;
          userName = AppLabels.helloGuest.tr;
          userEmail = AppLabels.loginSignup.tr;
        }

        return GestureDetector(
          onTap: () {
            if (state is Authenticated) {
              Get.toNamed(AppRoutes.editProfileScreen);
            } else {
              Get.toNamed(AppRoutes.loginScreen);
            }
          },
          child: Container(
            padding: const .symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: context.color.primary),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                ProfileCard(
                  iconSize: 78,
                  verticalSpace: 10,
                  space: 10,
                  titleStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: .w400,
                    color: context.color.primary.getAdaptiveTextColor(),
                  ),
                  subtitleStyle: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(
                        color: context.color.primary.getAdaptiveTextColor(),
                      ),
                  profileDefaultIconColor: context.color.primary.brighten(0.5),
                ),
                CustomImage(
                  AppIcons.right,
                  color: context.color.primary.getAdaptiveTextColor(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchToInstructor(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        // Only show switch to instructor for authenticated users
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            final webUrl =
                context.read<SettingsCubit>().settings?.websiteURL ??
                AppSettings.webLink;
            launchUrl(Uri.parse('$webUrl/become-instructor'));
          },
          child: Container(
            margin: const .symmetric(horizontal: 16),
            padding: const .all(16),
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.color.primary),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomImage(
                    AppIcons.switchInstructor,
                    width: 30,
                    height: 30,
                    color: context.color.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    AppLabels.switchToInstructor.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(fontWeight: .w400),
                  ),
                ),
                CustomImage(AppIcons.right, color: context.color.onSurface),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? iconBackgroundColor,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return CustomInkWell(
      onTap: onTap,
      color: Colors.transparent,
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 16),
        child: SizedBox(
          height: 46,
          child: Row(
            children: [
              Container(
                padding: const .all(7),
                decoration: BoxDecoration(
                  color:
                      iconBackgroundColor ??
                      context.color.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomImage(
                  icon,
                  width: 16,
                  height: 16,
                  color: iconColor ?? context.color.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomText(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: .w400,
                    color: textColor ?? context.color.onSurface,
                  ),
                ),
              ),
              trailing ??
                  CustomImage(
                    AppIcons.right,
                    color: iconColor ?? context.color.onSurface,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        final bool isAuthenticated = authState is Authenticated;
        final String? userType = isAuthenticated ? authState.user?.type : null;

        return CustomCard(
          margin: const .symmetric(horizontal: 16),
          padding: const .symmetric(vertical: 7),
          borderColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (isAuthenticated) ...{
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.wishlist,
                  title: AppLabels.wishlist.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.wishlistScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.transaction,
                  title: AppLabels.purchaseHistory.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.purchaseHistoryScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.wallet,
                  title: AppLabels.wallet.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.walletScreen);
                  },
                ),
                _buildSettingItem(
                  context: context,
                  icon: AppIcons.notificationFilled,
                  title: AppLabels.notification.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.notificationScreen);
                  },
                ),
                // Only show Account Security if login type is not social media
                if (userType != 'google' && userType != 'apple')
                  _buildSettingItem(
                    context: context,
                    icon: AppIcons.security,
                    title: AppLabels.accountSecurity.tr,
                    onTap: () {
                      UiUtils.showCustomBottomSheet(
                        context,
                        child: const AccountSecurityBottomSheet(),
                      );
                    },
                  ),
              },
              _buildSettingItem(
                context: context,
                icon: AppIcons.language,
                title: AppLabels.language.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.languageScreen);
                },
              ),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  final bool isDark = state is DarkTheme;
                  return _buildSettingItem(
                    context: context,
                    icon: AppIcons.theme,
                    title: AppLabels.darkMode.tr,
                    onTap: () {
                      context.read<ThemeCubit>().changeTheme(
                        context
                                .read<ThemeCubit>()
                                .getCurrentTheme(context)
                                .isDarkMode
                            ? LightTheme()
                            : DarkTheme(),
                      );
                    },
                    trailing: Transform.scale(
                      alignment: AlignmentDirectional.centerEnd,
                      scale: 0.7,
                      child: Switch(
                        value: isDark,
                        onChanged: (value) {
                          context.read<ThemeCubit>().changeTheme(
                            value ? DarkTheme() : LightTheme(),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: CustomText(
            AppLabels.moreSetting.tr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: const .symmetric(vertical: 7),
          margin: const .symmetric(horizontal: 16),
          borderColor: Colors.transparent,
          child: Column(
            children: [
              _buildSettingItem(
                context: context,
                icon: AppIcons.help,
                title: AppLabels.helpCenter.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.helpSupportScreen);
                },
              ),

              _buildSettingItem(
                context: context,
                icon: AppIcons.terms,
                title: AppLabels.termAndCondition.tr,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.policyScreen,
                    arguments: {'policyType': PolicyType.termsAndConditions},
                  );
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.privacy,
                title: AppLabels.privacyPolicy.tr,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.policyScreen,
                    arguments: {'policyType': PolicyType.privacyPolicy},
                  );
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.contact,
                title: AppLabels.contactUs.tr,
                onTap: () {
                  Get.toNamed(AppRoutes.contactUsScreen);
                },
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.shareSolid,
                title: AppLabels.shareApp.tr,
                onTap: _onTapShareApp,
              ),
              _buildSettingItem(
                context: context,
                icon: AppIcons.rating,
                title: AppLabels.rating.tr,
                onTap: _onTapRating,
              ),
              BlocBuilder<AuthenticationCubit, AuthenticationState>(
                builder: (context, authState) {
                  if (authState is! Authenticated) {
                    return const SizedBox.shrink();
                  }

                  return _buildSettingItem(
                    context: context,
                    icon: AppIcons.delete,
                    title: AppLabels.deleteAccount.tr,
                    onTap: () {
                      UiUtils.showDialog(
                        context,
                        child: BlocProvider(
                          create: (context) =>
                              DeleteAccountCubit(AuthRepository()),
                          child: const DeleteAccountDialog(),
                        ),
                      );
                    },
                    iconBackgroundColor: context.color.error.withValues(
                      alpha: 0.1,
                    ),
                    iconColor: context.color.error,
                    textColor: context.color.error,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.profile.tr,
        actions: [
          BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, authState) {
              if (authState is! Authenticated) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  UiUtils.showDialog(context, child: const LogoutDialog());
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.color.outline),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomImage(
                    AppIcons.logout,
                    color: context.color.onSurface,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.only(bottom: 7),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 20,
              children: [
                _buildProfileHeader(context),
                if (state is Authenticated) _buildSwitchToInstructor(context),
                _buildSettingsSection(context),
                _buildMoreSettingsSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
