import 'dart:io';
import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_dialog_box.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/login/apple_login.dart';
import 'package:elms/core/login/google_login.dart';
import 'package:elms/core/login/login.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/authentication/widgets/social_login_button.dart';
import 'package:elms/features/profile/cubit/delete_account_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool isUserAgreed = false;
  final TextEditingController _passwordController = TextEditingController();
  bool _isSocialAuthInProgress = false;
  String? _firebaseToken;
  bool _isVerified = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool _isSocialLogin() {
    final authState = context.read<AuthenticationCubit>().state;

    if (authState is Authenticated && authState.user != null) {
      final userType = authState.user!.type;
      return userType == AuthenticationType.google.name ||
          userType == AuthenticationType.apple.name;
    }
    return false;
  }

  AuthenticationType? _getSocialLoginType() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final userType = authState.user!.type;
      if (userType == AuthenticationType.google.name) {
        return AuthenticationType.google;
      } else if (userType == AuthenticationType.apple.name) {
        return AuthenticationType.apple;
      }
    }
    return null;
  }

  Future<void> _onTapSocialLogin() async {
    try {
      setState(() {
        _isSocialAuthInProgress = true;
      });

      final socialLoginType = _getSocialLoginType();
      if (socialLoginType == null) return;

      if (socialLoginType == AuthenticationType.google) {
        await _handleGoogleLogin();
      } else if (socialLoginType == AuthenticationType.apple) {
        await _handleAppleLogin();
      }
    } catch (e) {
      UiUtils.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSocialAuthInProgress = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final GoogleLogin googleLogin = GoogleLogin();

    final LoginResponse<UserCredential> loginResponse = await googleLogin
        .login();

    if (loginResponse.response.user != null) {
      _firebaseToken = await loginResponse.response.user?.getIdToken();
      if (mounted) {
        setState(() {
          _isVerified = true;
        });
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    final apple = AppleLogin();
    final LoginResponse<UserCredential> loginResponse = await apple.login();

    if (loginResponse.response.user != null) {
      _firebaseToken = await loginResponse.response.user?.getIdToken();
      if (mounted) {
        setState(() {
          _isVerified = true;
        });
      }
    }
  }

  Future<void> _onTapVerifyPassword() async {
    if (_passwordController.text.isEmpty) {
      UiUtils.showSnackBar(AppLabels.pleaseEnterPassword.tr, isError: true);
      return;
    }

    try {
      setState(() {
        _isSocialAuthInProgress = true;
      });

      // Verify password by re-authenticating with Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        if (mounted) {
          setState(() {
            _isVerified = true;
          });
        }
      }
    } catch (e) {
      UiUtils.showSnackBar(AppLabels.incorrectPassword.tr, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSocialAuthInProgress = false;
        });
      }
    }
  }

  void _onTapConfirmDelete() {
    if (!isUserAgreed) return;

    final isSocialLogin = _isSocialLogin();

    context.read<DeleteAccountCubit>().deleteAccount(
      password: isSocialLogin ? null : _passwordController.text,
      confirmPassword: isSocialLogin ? null : _passwordController.text,
      isSocialLogin: isSocialLogin,
      firebaseToken: isSocialLogin ? _firebaseToken : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSocialLogin = _isSocialLogin();

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticatedAsGuest) {
          Get.offAllNamed(AppRoutes.loginScreen);
        }
      },
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state is DeleteAccountSuccess) {
            // Sign out the user after successful account deletion
            context.read<AuthenticationCubit>().signOut();
          } else if (state is DeleteAccountFailed) {
            // Manually show error snackbar
            final error = state.error;
            if (error is CustomException) {
              if (error.toast) {
                UiUtils.showSnackBar(
                  error.message ?? AppLabels.somethingWentWrong.tr,
                  isError: true,
                );
              }
            } else {
              // For non-CustomException errors, show the error message
              UiUtils.showSnackBar(error.toString(), isError: true);
            }
          }
        },
        builder: (context, state) {
          final bool isLoading = state is DeleteAccountInProgress;

          return CustomDialogBox(
            title: AppLabels.deleteAccount.tr,
            actions: [
              DialogButton(
                title: AppLabels.no.tr,
                style: DialogButtonStyle.primary,
                onTap: isLoading ? null : () => Get.back(),
              ),
              if (!_isVerified)
                DialogButton(
                  title: isSocialLogin
                      ? AppLabels.verify.tr
                      : AppLabels.verifyPassword.tr,
                  style: DialogButtonStyle.outlined,
                  onTap:
                      (isUserAgreed && !isLoading && !_isSocialAuthInProgress)
                      ? (isSocialLogin
                            ? _onTapSocialLogin
                            : _onTapVerifyPassword)
                      : null,
                  color:
                      (isUserAgreed && !isLoading && !_isSocialAuthInProgress)
                      ? null
                      : context.color.onSurface.withValues(alpha: 0.4),
                ),
              if (_isVerified)
                DialogButton(
                  title: AppLabels.confirmDeleteAccount.tr,
                  style: DialogButtonStyle.outlined,
                  onTap: !isLoading ? _onTapConfirmDelete : null,
                  color: !isLoading
                      ? Colors.green
                      : context.color.onSurface.withValues(alpha: 0.4),
                ),
            ],
            content: Column(
              spacing: 8,
              mainAxisSize: .min,
              children: [
                CustomImage(AppIcons.deleteIcon),
                CustomText(
                  AppLabels.deleteAccountPermanent.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: .w600),
                ),
                CustomText(
                  AppLabels.deleteAccountConfirmation.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
                ),
                if (!isSocialLogin && !_isVerified)
                  CustomTextFormField(
                    controller: _passwordController,
                    title: AppLabels.password.tr,
                    hintText: '*******',
                    isPassword: true,
                    enabled: !isLoading && !_isSocialAuthInProgress,
                  ),
                if (isSocialLogin && !_isVerified)
                  _buildSocialLoginButton(isLoading),
                if (_isVerified)
                  Row(
                    spacing: 8,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      CustomText(
                        AppLabels.verifiedSuccessfully.tr,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.green,
                          fontWeight: .w600,
                        ),
                      ),
                    ],
                  ),
                _buildDeleteAccountAgreement(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialLoginButton(bool isLoading) {
    final socialLoginType = _getSocialLoginType();
    if (socialLoginType == null) return const SizedBox();

    String buttonText;
    String iconPath;

    if (socialLoginType == AuthenticationType.google) {
      buttonText = AppLabels.continueWithGoogle.tr;
      iconPath = AppIcons.googleIcon;
    } else if (socialLoginType == AuthenticationType.apple) {
      buttonText = AppLabels.continueWithApple.tr;
      iconPath = AppIcons.appleIcon;
    } else {
      return const SizedBox();
    }

    // Only show Apple button on iOS
    if (socialLoginType == AuthenticationType.apple && !Platform.isIOS) {
      return const SizedBox();
    }

    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.verifyIdentity.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: .w600),
        ),
        SocialLoginButton(
          onPressed: (isLoading || _isSocialAuthInProgress)
              ? null
              : _onTapSocialLogin,
          iconPath: iconPath,
          text: buttonText,
        ),
      ],
    );
  }

  Widget _buildDeleteAccountAgreement() {
    return Row(
      crossAxisAlignment: .start,
      spacing: 15,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: isUserAgreed,
            onChanged: (value) {
              isUserAgreed = value ?? false;
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: CustomText(
            AppLabels.deleteAccountAgreement.tr,
            style: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
      ],
    );
  }
}
