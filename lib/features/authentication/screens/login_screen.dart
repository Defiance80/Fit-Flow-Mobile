import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/core/login/phone_password_login.dart';
import 'package:fitflow/core/routes/route_params.dart';
import 'package:fitflow/features/authentication/screens/signup/signup_screen.dart';
import 'package:fitflow/features/authentication/screens/verification_screen.dart';
import 'package:fitflow/features/authentication/widgets/terms_privacy_agreement.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/state_extension.dart';
import 'package:fitflow/utils/loader.dart';
import 'package:fitflow/utils/text_formatters.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:fitflow/utils/validator.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/features/authentication/cubit/authentication_cubit.dart';
import 'package:fitflow/features/authentication/cubit/check_user_exists_cubit.dart';
import 'package:fitflow/features/authentication/repository/auth_repository.dart';
import 'package:fitflow/features/authentication/widgets/adaptive_auth_field.dart';
import 'package:fitflow/features/authentication/widgets/divider_with_text.dart';
import 'package:fitflow/features/authentication/widgets/social_login_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget route() => BlocProvider(
    create: (context) => CheckMobileUserExistsCubit(AuthRepository()),
    child: const LoginScreen(),
  );

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///This is mode of screen
  bool isPhoneLogin = false;
  bool showPasswordField = false;
  CountryCode? selectCountryCode;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleLoginMode() {
    setState(() {
      isPhoneLogin = !isPhoneLogin;
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      showPasswordField = false;
    });
  }

  Widget _buildEmailLoginFields() {
    return Column(
      children: [
        CustomTextFormField(
          title: AppLabels.email.tr,
          hintText: AppLabels.emailHint.tr,
          controller: _emailController,
          isRequired: true,
          formatters: [NoSpaceFormatter()],
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          title: AppLabels.password.tr,
          hintText: AppLabels.passwordHint.tr,
          controller: _passwordController,
          isRequired: true,
          formatters: [NoSpaceFormatter()],

          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildPhoneLoginFields() {
    return Column(
      children: [
        AdaptiveAuthField(
          title: AppLabels.enterPhoneNumber.tr,
          isRequired: true,
          hintText: AppLabels.enterPhoneNumber.tr,
          controller: _phoneController,
          fixedFieldType: AdaptiveFieldMode.number,
          onChangedCountryCode: (CountryCode? code) {
            selectCountryCode = code;
            showPasswordField = false;
          },
          onChangedMode: (AdaptiveFieldMode mode) {
            showPasswordField = mode == AdaptiveFieldMode.number;
            setState(() {});
          },
          onChanged: (_) {
            showPasswordField = false;
            setState(() {});
          },
        ),
        showPasswordField
            ? const SizedBox(height: 16)
            : const SizedBox.shrink(),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: showPasswordField
              ? CustomTextFormField(
                  title: AppLabels.password.tr,
                  hintText: AppLabels.passwordHint.tr,
                  controller: _passwordController,
                  isRequired: true,
                  isPassword: true,
                  validator: Validators.validatePassword,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _onPressContinue() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (isPhoneLogin && !showPasswordField) {
        context.read<CheckMobileUserExistsCubit>().checkIfUserExists(
          _phoneController.text,
          countryCode: selectCountryCode!.dialCode!,
        );
      } else if (isPhoneLogin && showPasswordField) {
        context.read<AuthenticationCubit>().signInWithPhonePassword(
          PhonePasswordLoginParameters(
            phoneNumber: PhoneNumber(
              number: _phoneController.text,
              countryCode: selectCountryCode!.dialCode!,
            ),
            password: _passwordController.text,
          ),
        );
      } else if (!isPhoneLogin) {
        context.read<AuthenticationCubit>().signInWithEmail(
          password: _passwordController.text,
          email: _emailController.text,
        );
      }
    }
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
          listener: (BuildContext context, AuthenticationState state) {
            ///This is to show loading overlay on login screen
            if (state is AuthLoading ||
                state is SocialAuthLoading ||
                state is AuthVerifyingOTP ||
                state is SendEmailVerificationLinkInProgress) {
              LoadingOverlay.show();
            } else {
              LoadingOverlay.hide();
            }
            if (state is SignUpAsEmail) {
              ///Close the screen if signup screen
              if (Get.currentRoute == AppRoutes.signupScreen) {
                Get.back();
              }
              UiUtils.showSnackBar(AppLabels.requestEmailVerification.tr);
            } else if (state is Authenticated) {
              Get.offAllNamed(AppRoutes.mainActivity);
            } else if (state is AuthFailed) {
              // Show error message

              if (state.error case final FirebaseAuthException error) {
                UiUtils.showSnackBar(error.message.toString(), isError: true);
              } else {
                UiUtils.showSnackBar(state.error.toString(), isError: true);
              }
            } else if (state is AuthVerificationRequired) {
              // Navigate to verification screen
              Get.toNamed(
                AppRoutes.verificationScreen,
                arguments: VerifyScreenArguments(
                  phoneNumber: state.phoneNumber,
                  verificationId: state.verificationId,
                ),
              );
            } else if (state is VerificationCompleted) {
              ///Finding and comparing route here from, we injected the route from we came to the verification screen.
              if (Get.find<VerificationDestination>().route ==
                  AppRoutes.forgotPasswordScreen) {
                Get.toNamed(AppRoutes.resetPasswordScreen);
              } else {
                Get.toNamed(
                  AppRoutes.signupScreen,
                  arguments: SignupArguments(
                    mode: SignupMode.phone,
                    phoneNumber: state.phoneNumber,
                    firebaseToken: state.firebaseToken,
                  ),
                );
              }
            }
            if (state is SendEmailVerificationLinkSuccess) {
              UiUtils.showSnackBar(AppLabels.sentVerificationEmail.tr);
              Get.offNamedUntil(AppRoutes.loginScreen, (route) => true);
            }
            if (state is SendEmailVerificationLinkFail) {
              if (state.error case final FirebaseAuthException error) {
                UiUtils.showSnackBar(error.message.toString(), isError: true);
              } else {
                UiUtils.showSnackBar(state.error.toString(), isError: true);
              }
            }
          },
          builder: (context, authenticationState) {
            return BlocConsumer<
              CheckMobileUserExistsCubit,
              CheckMobileUserExistsState
            >(
              listener: (context, state) async {
                if (state is MobileUserExists) {
                  setState(() {
                    showPasswordField = true;
                  });
                } else if (state is MobileUserDoesNotExist) {
                  setState(() {
                    showPasswordField = false;
                  });
                  // Send OTP
                  postFrame((Duration _) {
                    context.read<AuthenticationCubit>().sendOTP(
                      phoneNumber: PhoneNumber(
                        number: _phoneController.text,
                        countryCode: selectCountryCode!.dialCode!,
                      ),
                    );
                  });
                } else if (state is CheckMobileUserExistsError) {
                  // Show error message
                  UiUtils.showSnackBar(state.message, isError: true);
                }
              },
              builder: (context, mobileUserState) {
                // Handle both loading states
                final bool isProcessing =
                    authenticationState is AuthLoading ||
                    mobileUserState is CheckMobileUserExistsLoading;

                void handleToggleMode() {
                  if (!isProcessing) {
                    _toggleLoginMode();
                  }
                }

                return SingleChildScrollView(
                  padding: const .all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: CustomButton(
                            type: CustomButtonType.outlined,
                            onPressed: isProcessing
                                ? null
                                : () => Get.offAllNamed(AppRoutes.mainActivity),
                            border: 1,
                            title: AppLabels.skip.tr,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: CustomImage(
                            AppIcons.appLogo,
                            width: 120,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: context.screenWidth,
                          child: Column(
                            crossAxisAlignment: .start,
                            children: <Widget>[
                              Text(
                                AppLabels.signIn.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: .w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isPhoneLogin
                                    ? AppLabels.signInWithRegisteredNumber.tr
                                    : AppLabels.signInWithRegisteredEmail.tr,
                                textAlign: .center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 52),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isPhoneLogin
                              ? _buildPhoneLoginFields()
                              : _buildEmailLoginFields(),
                        ),
                        Padding(
                          padding: const .symmetric(vertical: 10),
                          child: Align(
                            alignment: .centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.forgotPasswordScreen,
                                  arguments: {'isPhoneLogin': isPhoneLogin},
                                );
                              },
                              child: Text(AppLabels.forgotPassword.tr),
                            ),
                          ),
                        ),
                        CustomButton(
                          key: const ValueKey('login-button'),
                          onPressed: isProcessing ? null : _onPressContinue,
                          title: isProcessing
                              ? AppLabels.processing.tr
                              : AppLabels.continueLabel.tr,
                          fullWidth: true,
                          // backgroundColor: context.color.primary,
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: AppLabels.dontHaveAccount.tr,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const WidgetSpan(child: SizedBox(width: 4)),
                              TextSpan(
                                text: AppLabels.signUp.tr,
                                style: TextStyle(
                                  fontWeight: .bold,
                                  color: context.color.onSurface,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed(
                                      AppRoutes.signupScreen,
                                      arguments: SignupArguments(
                                        mode: SignupMode
                                            .email, //Fix email type because user can not create directly account without otp verification
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const .symmetric(vertical: 32),
                          child: DividerWithText(
                            text: AppLabels.orLoginWith.tr,
                          ),
                        ),
                        Column(
                          spacing: 16,
                          children: [
                            SocialLoginButton(
                              onPressed: isProcessing
                                  ? null
                                  : () {
                                      setState(() {
                                        showPasswordField = false;
                                      });
                                      context
                                          .read<AuthenticationCubit>()
                                          .signInWithGoogle();
                                    },
                              iconPath: AppIcons.googleIcon,
                              text: AppLabels.continueWithGoogle.tr,
                            ),
                            if (Platform.isIOS)
                              SocialLoginButton(
                                onPressed: isProcessing
                                    ? null
                                    : () {
                                        setState(() {
                                          showPasswordField = false;
                                        });
                                        context
                                            .read<AuthenticationCubit>()
                                            .signInWithApple();
                                      },
                                iconPath: AppIcons.appleIcon,
                                text: AppLabels.continueWithApple.tr,
                              ),
                            SocialLoginButton(
                              key: const ValueKey('toggle-mode'),
                              iconPath: isPhoneLogin
                                  ? AppIcons.emailLoginIcon
                                  : AppIcons.mobileLoginIcon,
                              onPressed: isProcessing ? null : handleToggleMode,
                              iconColor: context.color.primary,
                              text: isPhoneLogin
                                  ? AppLabels.useEmail.tr
                                  : AppLabels.usePhone.tr,
                            ),
                            const Padding(
                              padding: .only(top: 10),
                              child: TermsAndPrivacyAgreement(
                                align: .center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
