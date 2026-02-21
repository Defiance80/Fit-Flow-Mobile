import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/features/transaction/models/my_refund_model.dart';
import 'package:fitflow/features/transaction/widgets/transaction_info_tile.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class RefundRequestCard extends StatelessWidget {
  final MyRefundModel refund;
  const RefundRequestCard({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const .all(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 12,
            children: [
              CustomImage(
                refund.course.thumbnail,
                width: 45,
                height: 45,
                fit: .cover,
                radius: 4,
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    refund.course.title,
                    style: TextTheme.of(context).titleSmall!,
                  ),
                  CustomText(
                    'By ${refund.course.creatorName}',
                    style: TextTheme.of(context).bodySmall!,
                  ),
                ],
              ),
            ],
          ),

          const Divider(),
          if (refund.adminNotes != null &&
              refund.status == RefundStatus.rejected) ...{
            TransactionInfoTile(
              title: 'Rejection Reason',
              value: refund.adminNotes!,
            ),
            const Divider(),
          },
          if (refund.userMediaUrl != null) ...{
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(refund.userMediaUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: TransactionInfoTile(
                title: 'Attached Media',
                value: refund.userMediaUrl!.split('/').last,
              ),
            ),

            const Divider(),
          },
          Row(
            children: [
              CustomText('Amount', style: TextTheme.of(context).titleSmall!),
              const SizedBox(width: 4),
              CustomText(
                refund.refundAmount.toString().currency,
                style: TextTheme.of(context).titleMedium!.copyWith(
                  color: context.color.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildStatusChip(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return CustomCard(
      color: refund.status.color.withValues(alpha: 0.1),
      borderRadius: 4,
      borderColor: Colors.transparent,
      padding: const .symmetric(vertical: 4, horizontal: 8),
      child: CustomText(
        refund.status.name.capitalize.toString(),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: refund.status.color,
          fontWeight: .w500,
        ),
      ),
    );
  }
}
