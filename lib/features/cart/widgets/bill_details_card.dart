import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/features/cart/models/cart_summary_model.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillDetailsCard extends StatelessWidget {
  final CartSummaryModel summary;

  const BillDetailsCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Title
          CustomText(
            'bill_details'.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Subtotal
          _buildRow(
            context,
            label: 'subtotal'.tr,
            value: summary.subtotal.toStringAsFixed(2).currency,
          ),
          const SizedBox(height: 10),
          if (summary.discount != 0)
            _buildRow(
              context,
              label: 'discount'.tr,
              value: '-${summary.discount.toStringAsFixed(2).currency}',
            ),

          // Tax (only show if tax type is exclusive)
          if (summary.taxType != null &&
              summary.taxType!.toLowerCase() == 'exclusive' &&
              summary.totalTaxAmount != null &&
              summary.totalTaxAmount! > 0) ...[
            const SizedBox(height: 10),
            _buildRow(
              context,
              label: 'taxes'.tr,
              value: summary.totalTaxAmount!.toStringAsFixed(2).currency,
            ),
          ],

          // Taxes and Charges
          if (summary.appliedCouponCode != null) ...[
            const SizedBox(height: 10),

            // Coupon Discount
            _buildRow(
              context,
              isHighlighted: true,
              highlightColor: context.color.success,

              label: '${'coupon_applied'.tr} | ${summary.appliedCouponCode}',
              value:
                  '-${(summary.couponDiscount?.toStringAsFixed(2) ?? "0.00").currency}',
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Total Pay (after coupon)
            _buildRow(
              context,
              label: 'total_pay'.tr,
              value: summary.totalPay.toString().currency,
              isHighlighted: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlighted = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: isHighlighted ? .w500 : .w400,
            color: isHighlighted
                ? highlightColor ?? context.color.onSurface
                : context.color.onSurface.withValues(alpha: 153),
          ),
        ),
        CustomText(
          value,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: isHighlighted ? .w500 : .w400,
            color: isHighlighted
                ? highlightColor ?? context.color.onSurface
                : context.color.primary,
          ),
        ),
      ],
    );
  }
}
