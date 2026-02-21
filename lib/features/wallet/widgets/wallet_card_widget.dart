import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/authentication/cubit/authentication_cubit.dart';
import 'package:fitflow/features/wallet/widgets/blended_color_image.dart';
import 'package:fitflow/features/wallet/widgets/withdraw_money_bottom_sheet.dart';
import 'package:fitflow/utils/extensions/color_extension.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WalletCardWidget extends StatefulWidget {
  final bool shouldDisableWithdrawButton;
  final VoidCallback? onWithdrawalSuccess;
  const WalletCardWidget({
    super.key,
    this.shouldDisableWithdrawButton = false,
    this.onWithdrawalSuccess,
  });

  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  @override
  void initState() {
    context.read<AuthenticationCubit>().refreshUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final num balance = context.watch<AuthenticationCubit>().walletBalance ?? 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 143,
        child: Stack(
          children: [
            BlendedColorImage(
              imagePath: AppIcons.walletBG,
              height: 143,
              width: double.maxFinite,
              fit: .fitWidth,
              intensity: 0.88,
              color: AppColors.primaryColor.darken(0.08),
            ),
            SizedBox(
              width: context.screenWidth,
              child: Column(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  Column(
                    children: [
                      CustomText(
                        AppLabels.currentBalance.tr,
                        style: TextTheme.of(context).bodyMedium!,
                        color: context.color.darkColor,
                      ),
                      CustomText(
                        balance.toString().currency,
                        style: TextTheme.of(
                          context,
                        ).titleLarge!.copyWith(fontWeight: .bold),
                        color: context.color.darkColor,
                      ),
                    ],
                  ),
                  CustomButton(
                    title: AppLabels.withdrawMoney.tr,
                    onPressed:
                        (balance <= 0 || widget.shouldDisableWithdrawButton)
                        ? null
                        : () {
                            UiUtils.showCustomBottomSheet(
                              context,
                              child: WithdrawMoneyBottomSheet.create(
                                onWithdrawalSuccess: widget.onWithdrawalSuccess,
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
