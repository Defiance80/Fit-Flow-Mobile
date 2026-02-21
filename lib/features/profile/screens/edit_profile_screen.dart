import 'dart:io';

import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/core/login/phone_password_login.dart';
import 'package:fitflow/features/authentication/cubit/authentication_cubit.dart';
import 'package:fitflow/features/authentication/repository/auth_repository.dart';
import 'package:fitflow/features/authentication/widgets/adaptive_auth_field.dart';
import 'package:fitflow/features/profile/cubits/edit_profile_cubit.dart';
import 'package:fitflow/features/profile/widgets/profile_image_widget.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static Widget route() {
    return BlocProvider(
      create: (context) => EditProfileCubit(AuthRepository()),
      child: const EditProfileScreen(),
    );
  }

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final PhoneNumber phone = PhoneNumber.lazy();
  File? profile;
  String? currentProfileImage;
  bool isEmailDisabled = false;
  bool isPhoneDisabled = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final authState = context.read<AuthenticationCubit>().state;
    if (authState is Authenticated && authState.user != null) {
      final user = authState.user!;

      // Prefill text fields
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';

      // Prefill phone number if available
      if (user.mobile != null && user.mobile!.isNotEmpty) {
        _phoneController.text = user.mobile!;
        phone.setNumber(user.mobile!);
      }

      // Store current profile image
      currentProfileImage = user.profile;

      // Determine which field should be disabled based on login method
      _determineDisabledFields(user.type);
    }
  }

  /// Determines which fields should be disabled based on the user's login type
  void _determineDisabledFields(String? loginType) {
    if (loginType == null) return;

    final String type = loginType.toLowerCase();

    // Disable email field if user logged in with email-based methods
    if (type == 'email' || type == 'google' || type == 'apple') {
      isEmailDisabled = true;
      isPhoneDisabled = false;
    }
    // Disable phone field if user logged in with phone
    else if (type == 'phone' || type == 'mobile') {
      isPhoneDisabled = true;
      isEmailDisabled = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.editProfile.tr,
        showBackButton: true,
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const .all(8),
        height: kBottomNavigationBarHeight,
        child: CustomButton(
          title: AppLabels.saveChanges.tr,
          onPressed: () {
            context.read<EditProfileCubit>().edit(
              email: _emailController.text,
              name: _nameController.text,
              phone: phone,
              profile: profile,
            );
          },
        ),
      ),
      body: BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            context.read<AuthenticationCubit>().changeUserDetails(state.user);
            UiUtils.showSnackBar(AppLabels.updatedSuccessfully.tr);
          }
          if (state is EditProfileFail) {
            // Handle CustomException with toast enabled
            if (state.error is CustomException) {
              final CustomException exception = state.error as CustomException;
              if (exception.toast) {
                UiUtils.showSnackBar(exception.message ?? '', isError: true);
              }
            }
          }
        },
        child: Padding(
          padding: const .all(16.0),
          child: Column(
            children: [
              Center(
                child: ProfileImageWidget(
                  image: currentProfileImage ?? '',
                  onSelected: (file) {
                    profile = file;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 27),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      spacing: 8,
      children: [
        CustomTextFormField(
          title: AppLabels.fullName.tr,
          hintText: AppLabels.enterName.tr,
          controller: _nameController,
        ),
        CustomTextFormField(
          title: AppLabels.email.tr,
          hintText: AppLabels.enterEmail.tr,
          controller: _emailController,
          enabled: !isEmailDisabled,
        ),
        AdaptiveAuthField(
          title: AppLabels.phoneNumber.tr,
          fixedFieldType: AdaptiveFieldMode.number,
          hintText: '123456789',
          controller: _phoneController,
          enabled: !isPhoneDisabled,

          onChangedCountryCode: (code) {
            phone.setCountryCode(code!.dialCode!);
          },
          onChanged: (String number) {
            phone.setNumber(number);
          },
        ),
      ],
    );
  }
}
