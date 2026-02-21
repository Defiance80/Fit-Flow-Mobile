import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/features/policy/screens/policy_screen.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndPrivacyAgreement extends StatelessWidget {
  final TextAlign? align;
  const TermsAndPrivacyAgreement({
    super.key,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: align ?? .start,
      text: TextSpan(
        text: AppLabels.termsAgreement.tr,
        style: TextStyle(color: context.color.onSurface.withAlpha(153)),
        children: [
          const TextSpan(text: ' '),
          TextSpan(
            text: AppLabels.termsOfService.tr,
            style: TextStyle(
              color: context.color.onSurface,
              fontWeight: .bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  AppRoutes.policyScreen,
                  arguments: {'policyType': PolicyType.termsAndConditions},
                );
              },
          ),
          TextSpan(text: ' ${AppLabels.and.tr} '),
          TextSpan(
            text: AppLabels.privacyPolicy.tr,
            style: TextStyle(
              color: context.color.onSurface,
              fontWeight: .bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  AppRoutes.policyScreen,
                  arguments: {'policyType': PolicyType.privacyPolicy},
                );
              },
          ),
        ],
      ),
    );
  }
}
