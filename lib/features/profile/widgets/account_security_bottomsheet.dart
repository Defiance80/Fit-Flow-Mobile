import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_text_form_field.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:elms/features/profile/cubits/change_password_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AccountSecurityBottomSheet extends StatefulWidget {
  const AccountSecurityBottomSheet({super.key});

  @override
  State<AccountSecurityBottomSheet> createState() =>
      _AccountSecurityBottomSheetState();
}

class _AccountSecurityBottomSheetState
    extends State<AccountSecurityBottomSheet> {
  ///
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newConfirmPasswordController =
      TextEditingController();

  ///
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(AuthRepository()),
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const .all(16),
            child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
              listener: (context, state) {
                if (state is ChangePasswordFail) {
                  final CustomException exception =
                      state.error as CustomException;
                  if (exception.toast) {
                    UiUtils.showSnackBar(
                      exception.message ?? '',
                      isError: true,
                    );
                  }
                } else if (state is ChangePasswordSuccess) {
                  Navigator.pop(context);
                  UiUtils.showSnackBar(
                    AppLabels.passwordChangedSuccessfully.tr,
                  );
                }
              },
              child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                builder: (context, state) { 
                  final bool isLoading = state is ChangePasswordInProgress;
                  return Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .stretch,
                    spacing: 15,
                    children: <Widget>[
                      ...[
                        CustomText(
                          AppLabels.accountSecurity.tr,
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontWeight: .w500),
                        ),
                        CustomText(
                          AppLabels.accountSecurityDescription.tr,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(fontWeight: .w400),
                        ),
                      ],
                      CustomTextFormField(
                        controller: _currentPasswordController,
                        title: AppLabels.currentPassword.tr,
                        hintText: '********',
                        isPassword: true,
                        fillColor: context.color.outline.withValues(
                          alpha: 0.17,
                        ),
                      ),
                      CustomTextFormField(
                        controller: _newPasswordController,
                        title: AppLabels.newPassword.tr,
                        hintText: '********',
                        isPassword: true,
                        isRequired: true,
                        fillColor: context.color.outline.withValues(
                          alpha: 0.17,
                        ),
                      ),
                      CustomTextFormField(
                        controller: _newConfirmPasswordController,
                        title: AppLabels.confirmNewPassword.tr,
                        hintText: '********',
                        isPassword: true,
                        isRequired: true,
                        fillColor: context.color.outline.withValues(
                          alpha: 0.17,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        title: AppLabels.changePassword.tr,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                context
                                    .read<ChangePasswordCubit>()
                                    .changePassword(
                                      currentPassword:
                                          _currentPasswordController.text,
                                      newPassword: _newPasswordController.text,
                                      confirmPassword:
                                          _newConfirmPasswordController.text,
                                    );
                              },
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
