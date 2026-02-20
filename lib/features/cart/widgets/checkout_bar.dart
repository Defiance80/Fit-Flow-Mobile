import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:get/get.dart';

class CheckoutBar extends StatelessWidget {
  final num totalAmount;
  final VoidCallback? onCheckout;
  final String? buttonText;
  final bool isLoading;

  const CheckoutBar({
    super.key,
    required this.totalAmount,
    this.onCheckout,
    this.buttonText,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 4,
      padding: const .all(8),
      child: Row(
        children: [
          // Total amount section
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                CustomText(
                  AppLabels.total.tr,
                  style: Theme.of(context).textTheme.bodyMedium!,
                  fontWeight: .w400,
                  color: context.color.onSurface,
                ),
                const SizedBox(height: 6),
                CustomText(
                  totalAmount.toStringAsFixed(2).currency,
                  style: Theme.of(context).textTheme.titleMedium!,
                  fontWeight: .w600,
                  color: context.color.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Checkout button
          CustomButton(
            onPressed: isLoading ? null : onCheckout,
            backgroundColor: context.color.primary,
            height: 40,
            isLoading: isLoading,
            customTitle: isLoading
                ? null
                : Row(
                    mainAxisSize: .min,
                    spacing: 8,
                    children: [
                      CustomText(
                        buttonText ?? AppLabels.checkout.tr,
                        style: Theme.of(context).textTheme.labelLarge!,
                        color: context.color.surface,
                      ),
                      CustomImage(
                        AppIcons.arrowRight,
                        width: 16,
                        height: 16,
                        color: context.color.surface,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
