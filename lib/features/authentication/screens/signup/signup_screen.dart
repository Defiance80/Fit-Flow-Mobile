import 'package:fitflow/core/login/phone_password_login.dart';
import 'package:fitflow/core/routes/route_params.dart';
import 'package:fitflow/features/authentication/widgets/terms_privacy_agreement.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/text_formatters.dart';
import 'package:fitflow/utils/validator.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/authentication/cubit/authentication_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

enum SignupMode { email, phone }

class SignupScreen extends StatefulWidget {
  final SignupMode mode;
  final String? email;
  final PhoneNumber? phoneNumber;
  final String? firebaseToken;
  const SignupScreen({
    super.key,
    required this.mode,
    this.email,
    this.phoneNumber,
    this.firebaseToken,
  });

  static Widget route() {
    final SignupArguments arguments = Get.arguments as SignupArguments;

    return SignupScreen(
      mode: arguments.mode,
      email: arguments.email,
      phoneNumber: arguments.phoneNumber,
      firebaseToken: arguments.firebaseToken,
    );
  }

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isChecked = false;

  @override
  void initState() {
    if (widget.mode == SignupMode.phone) {
      _phoneController.text = widget.phoneNumber!.formattedNumber;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onTapSignupButton() async {
    if (_formKey.currentState!.validate() && _isChecked) {
      if (widget.mode == SignupMode.email) {
        context.read<AuthenticationCubit>().register(
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          email: _emailController.text,
          name: _nameController.text,
        );
      } else {
        assert(widget.firebaseToken != null, 'Firebase token must be provided');
        context.read<AuthenticationCubit>().registerPhone(
          name: _nameController.text,
          confirmPassword: _confirmPasswordController.text,
          password: _passwordController.text,
          phoneNumber: widget.phoneNumber!,
          firebaseToken: widget.firebaseToken!,
        );
      }
    } else if (!_isChecked && _formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLabels.agreeToTerms.tr),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onTapSignIn() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.mode == SignupMode.phone ? false : true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }

        ///exit the app because we have kept the login screen our stack for listeners
        if (widget.mode == SignupMode.phone) {
          Future.delayed(Duration.zero, () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const .symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: 40),
                  // Header
                  Center(
                    child: CustomText(
                      AppLabels.signupTitle.tr,
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(fontWeight: .bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subheader
                  Center(
                    child: CustomText(
                      AppLabels.signupSubtitle.tr,
                      textAlign: .center,
                      color: context.color.onSurface.withAlpha(153),
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSignupForm(),

                  // Sign Up button
                  CustomButton(
                    onPressed: _onTapSignupButton,
                    title: AppLabels.signUp.tr,
                    backgroundColor: context.color.primary,
                    textColor: context.color.onPrimary,
                    fullWidth: true,
                    height: 40,
                  ),
                  const SizedBox(height: 20),
                  // Already have account
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: AppLabels.alreadyHaveAccount.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.color.onSurface.withAlpha(153),
                        ),
                        children: [
                          const WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(
                            text: AppLabels.login.tr,
                            style: const TextStyle(fontWeight: .w900),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _onTapSignIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        activeColor: context.color.primary,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(top: 8),
                          child: TermsAndPrivacyAgreement(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Column(
      spacing: 16,
      crossAxisAlignment: .start,
      children: [
        CustomTextFormField(
          title: AppLabels.name.tr,
          hintText: AppLabels.enterName.tr,
          isRequired: true,
          controller: _nameController,
          validator: Validators.validateName,
        ),
        if (widget.mode == SignupMode.email)
          CustomTextFormField(
            title: AppLabels.email.tr,
            hintText: AppLabels.emailHint.tr,
            isRequired: true,
            controller: _emailController,
            validator: Validators.validateEmail,
            formatters: [NoSpaceFormatter()],
          ),
        if (widget.mode == SignupMode.phone)
          CustomTextFormField(
            title: AppLabels.phoneNumber.tr,
            hintText: AppLabels.enterPhoneNumber.tr,
            isRequired: true,
            enabled: false,
            controller: _phoneController,
            inputType: TextInputType.phone,
          ),
        CustomTextFormField(
          title: AppLabels.password.tr,
          hintText: AppLabels.passwordHint.tr,
          isRequired: true,
          controller: _passwordController,
          formatters: [NoSpaceFormatter()],

          validator: Validators.validatePassword,
          isPassword: true,
        ),
        CustomTextFormField(
          title: AppLabels.confirmPassword.tr,
          hintText: AppLabels.confirmPasswordHint.tr,
          isRequired: true,
          controller: _confirmPasswordController,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
          formatters: [NoSpaceFormatter()],
          isPassword: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
