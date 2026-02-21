import 'dart:async';
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_popscope.dart';
import 'package:fitflow/core/login/phone_password_login.dart';
import 'package:fitflow/core/routes/route_params.dart';
import 'package:fitflow/utils/loader.dart';
import 'package:fitflow/utils/countdown_timer.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/core/configs/app_settings.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/features/authentication/cubit/authentication_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:fitflow/core/constants/app_labels.dart';

extension type VerificationDestination(String route) {}

class VerificationScreen extends StatefulWidget {
  final PhoneNumber phoneNumber;
  final String verificationId;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  static Widget route() {
    final VerifyScreenArguments args = Get.arguments as VerifyScreenArguments;

    return VerificationScreen(
      phoneNumber: args.phoneNumber,
      verificationId: args.verificationId,
    );
  }

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late CountdownTimer _timer;

  @override
  void initState() {
    super.initState();
    Get.put(VerificationDestination(Get.previousRoute));

    _timer = CountdownTimer(
      durationInSeconds: AppSettings.otpTimerDuration,
      onTick: (final int remainingSeconds) {},
    );

    // Start timer
    _timer.start();
  }

  @override
  void dispose() {
    _otpController.dispose();

    super.dispose();
  }

  // Timer callback

  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> _onTapVerifyButton() async {
    // Use the direct verifyOTP method with loading overlay
    await LoadingOverlay.execute(
      () => context.read<AuthenticationCubit>().verifyOTP(
        verificationId: widget.verificationId,
        otp: _otpController.text,
        phoneNumber: widget.phoneNumber,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      preventOverlay: true,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(child: _buildContent(context)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      actions: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: CustomButton(
            onPressed: () => Get.offAllNamed(AppRoutes.loginScreen),
            border: 1,
            type: CustomButtonType.outlined,
            title: AppLabels.skip.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const .all(16),
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 56),
              Text(
                AppLabels.signInWithMobile.tr,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: .w600,
                ),
                textAlign: .center,
              ),
              Padding(
                padding: const .symmetric(vertical: 8),
                child: Text(
                  AppLabels.verificationCodeSent.tr,
                  textAlign: .center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              _buildPhoneNumberRow(context, state, colorScheme),
              const SizedBox(height: 58),
              _buildPinCodeField(context, state, colorScheme, screenSize),
              if (state is AuthFailed) ...[
                Text(
                  state.error.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _buildVerifyButton(context, state, colorScheme),
              SizedBox(height: screenSize.height * 0.03),
              _buildResendSection(context, state, colorScheme, theme),
              const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoneNumberRow(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
  ) {
    return Row(
      spacing: 4,
      mainAxisAlignment: .center,
      children: [
        Text(widget.phoneNumber.formattedNumber),
        GestureDetector(
          onTap: state is VerificationProcessing
              ? null
              : () {
                  Get.back();
                },
          child: Text(
            AppLabels.change.tr,
            style: TextStyle(
              color: state is VerificationProcessing
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeField(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenSize.width * 0.9),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        controller: _otpController,
        keyboardType: TextInputType.number,
        enabled: state is! VerificationProcessing,
        autoDisposeControllers: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8),
          fieldHeight: 53,
          fieldWidth: 53,
          activeFillColor: colorScheme.surface,
          inactiveFillColor: colorScheme.surface,
          selectedFillColor: colorScheme.surface,
          activeColor: colorScheme.onSurface.withAlpha(70),
          inactiveColor: Colors.transparent,
          selectedColor: colorScheme.primary,
          disabledColor: colorScheme.outline.withValues(alpha: 0.5),
        ),
        hintCharacter: '0',
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        // onCompleted: (_) => _onTapVerifyButton(), //Currently disabled as this is not needed
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildVerifyButton(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
  ) {
    return CustomButton(
      onPressed:
          _otpController.text.length == 6 && state is! VerificationProcessing
          ? _onTapVerifyButton
          : null,
      title: state is VerificationProcessing
          ? AppLabels.verifying.tr
          : AppLabels.continueLabel.tr,
      fullWidth: true,
      backgroundColor: colorScheme.primary,
    );
  }

  Widget _buildResendSection(
    BuildContext context,
    AuthenticationState state,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container();
    // return state.remainingSeconds == 0
    //     ? TextButton(
    //         onPressed: !state.isProcessing ? _onTapResendOTP : null,
    //         child: Text(
    //           AppLabels.resendOTP.tr,
    //           style: TextStyle(
    //             color: state.isProcessing
    //                 ? colorScheme.primary.withValues(alpha: 0.4)
    //                 : colorScheme.primary,
    //             fontWeight: .w500,
    //           ),
    //         ),
    //       )
    //     : Text(
    //         '${AppLabels.resendOTPIn.tr} : ${formatTime(state.remainingSeconds)}',
    //         style: theme.textTheme.bodyMedium,
    //       );
  }
}
