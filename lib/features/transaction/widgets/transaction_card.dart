import 'dart:async'; 
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/transaction/cubit/fetch_my_refunds_cubit.dart';
import 'package:fitflow/features/transaction/cubits/fetch_transaction_history_cubit.dart';
import 'package:fitflow/features/transaction/repositories/transaction_history_repository.dart';
import 'package:fitflow/features/transaction/models/transaction_history_model.dart';
import 'package:fitflow/features/transaction/widgets/purchase_details_bottom_sheet.dart';
import 'package:fitflow/features/transaction/widgets/transaction_info_tile.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class TransactionCard extends StatefulWidget {
  const TransactionCard({
    super.key,
    required this.orderId,
    required this.title,
    required this.txnId,
    required this.purchaseMode,
    required this.purchaseDate,
    required this.amount,
    required this.status,
    required this.courses,
  });

  final int orderId;
  final String title;
  final String txnId;
  final String purchaseMode;
  final DateTime purchaseDate;
  final double amount;
  final TransactionStatus status;
  final List<TransactionCourseModel> courses;

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isDownloading = false;

  String _getFormattedDate() {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(widget.purchaseDate);
  }

  Future<void> _openPdfFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        UiUtils.showSnackBar('Could not open PDF file', isError: true);
      }
    } catch (e) {
      UiUtils.showSnackBar('Error opening PDF: $e', isError: true);
    }
  }

  Future<void> _onTapDownloadInvoice() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final repository = TransactionHistoryRepository();
      final String filePath = await repository.downloadInvoice(
        orderId: widget.orderId,
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        UiUtils.showSnackBar('Invoice downloaded successfully');
        await _openPdfFile(filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        UiUtils.showSnackBar(e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const .all(10),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: context.color.primary,
                  ),
                  maxLines: 1,
                  ellipsis: true,
                ),
              ),
              _buildStatusChip(context),
            ],
          ),
          const Divider(height: 0),
          TransactionInfoTile(
            title: AppLabels.transactionId.tr,
            value: widget.txnId,
          ),
          TransactionInfoTile(
            title: AppLabels.paymentMode.tr,
            value: widget.purchaseMode,
          ),
          TransactionInfoTile(
            title: AppLabels.purchaseDate.tr,
            value: _getFormattedDate(),
          ),
          const Divider(height: 0),
          _buildAmountRow(context),
        ],
      ),
    );
  }

  Widget _buildAmountRow(BuildContext context) {
    return Row(
      children: [
        CustomText(
          AppLabels.amount.tr,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: .w500),
        ),
        CustomText(
          widget.amount.toString().currency,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: .bold,
            color: context.color.primary,
          ),
        ),
        const SizedBox(width: 7),

        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _buildDetailsAndInvoiceButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsAndInvoiceButton(BuildContext context) {
    final bool isSuccess = widget.status == TransactionStatus.success;
    return Row(
      spacing: 10,
      mainAxisSize: .min,
      children: [
        Flexible(
          child: _buildDetailButton(
            context,
            title: AppLabels.viewDetails.tr,
            onTap: () async {
              final cubit = context.read<FetchTransactionHistoryCubit>();
              final refundCubit = context.read<FetchMyRefundsCubit>();
              final result = await UiUtils.showCustomBottomSheet(
                context,
                child: PurchaseDetailsBottomSheet(courses: widget.courses),
              );
              if (!mounted) return;
              if (result == true) {
                cubit.fetch();
                unawaited(refundCubit.fetch());
              }
            },
            icon: Icons.remove_red_eye_outlined,
          ),
        ),

        if (isSuccess)
          Flexible(
            child: _buildDetailButton(
              context,
              title: AppLabels.invoice.tr,
              icon: _isDownloading
                  ? Icons.download
                  : Icons.download_for_offline_outlined,
              onTap: _isDownloading ? () {} : _onTapDownloadInvoice,
            ),
          ),
      ],
    );
  }

  Widget _buildDetailButton(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return CustomButton(
      height: 24,
      onPressed: onTap,
      backgroundColor: context.color.outline,
      padding: const .symmetric(horizontal: 8, vertical: 4),
      customTitle: Row(
        mainAxisAlignment: .center,
        mainAxisSize: .min,
        children: [
          Icon(icon),
          const SizedBox(width: 4),
          Flexible(
            child: CustomText(
              title,
              style: Theme.of(context).textTheme.bodySmall!,
              ellipsis: true,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return CustomCard(
      color: widget.status.color.withValues(alpha: 0.1),
      borderRadius: 4,
      borderColor: Colors.transparent,
      padding: const .symmetric(vertical: 4, horizontal: 8),
      child: CustomText(
        widget.status.name,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: widget.status.color,
          fontWeight: .w500,
        ),
      ),
    );
  }
}
