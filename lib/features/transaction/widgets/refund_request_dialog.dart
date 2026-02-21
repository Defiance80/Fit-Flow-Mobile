import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_dialog_box.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/transaction/cubit/refund_cubit.dart';
import 'package:fitflow/features/transaction/models/transaction_history_model.dart';
import 'package:fitflow/features/transaction/repository/refund_repository.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RefundRequestDialog extends StatefulWidget {
  final TransactionCourseModel? course;

  const RefundRequestDialog({super.key, this.course});

  static Widget create({TransactionCourseModel? course}) {
    return BlocProvider(
      create: (context) => RefundCubit(RefundRepository()),
      child: RefundRequestDialog(course: course),
    );
  }

  @override
  State<RefundRequestDialog> createState() => _RefundRequestDialogState();
}

class _RefundRequestDialogState extends State<RefundRequestDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  XFile? _selectedFile;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _onTapChooseFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _onTapSendRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.course == null) {
      return;
    }

    await context.read<RefundCubit>().submitRefundRequest(
      courseId: widget.course!.courseId,
      reason: _reasonController.text.trim(),
      userMedia: _selectedFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RefundCubit, RefundState>(
      listener: (context, state) {
        if (state is RefundSuccess) {
          Navigator.pop(context, true);

          UiUtils.showSnackBar(AppLabels.refundRequestSubmitted.tr);
        } else if (state is RefundFail) {
          UiUtils.showSnackBar(state.error.toString(), isError: true);
        }
      },
      child: BlocBuilder<RefundCubit, RefundState>(
        builder: (context, state) {
          final isLoading = state is RefundInProgress;

          return CustomDialogBox(
            title: AppLabels.submitRefundRequest.tr,
            actionSpacing: 0,
            subtitle: AppLabels.refundRequestSubtitle.tr,

            actions: [
              DialogButton(
                title: AppLabels.sendRequest.tr,
                onTap: isLoading ? null : _onTapSendRequest,
                color: const Color(0xFF5A5BB5),
                style: DialogButtonStyle.primary,
              ),
            ],
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: .start,
                 
                  children: [
                    _buildInfoBanner(context),
                    const SizedBox(height: 16),
                    _buildCourseCard(context),
                    const SizedBox(height: 16),
                    _buildReasonField(context),
                    const SizedBox(height: 16),
                    _buildAttachMediaSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return CustomCard(
      color: const Color(0xFF0186D8).withValues(alpha: 0.1),
      borderColor: Colors.transparent,
      padding: const .all(4),
      child: Row(
        children: [
          Container(
            padding: const .all(2),
            child: const Icon(
              Icons.info_outline,
              size: 20,
              color: Color(0xFF0186D8),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              AppLabels.refundWalletInfo.tr,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context) {
    if (widget.course == null) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      padding: const .all(8),
      child: Row(
        children: [
          CustomImage(
            widget.course!.image,
            width: 45,
            height: 45,
            fit: .cover,
            radius: 4,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  widget.course!.title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                CustomText(
                  '${AppLabels.by.tr} ${widget.course!.creatorName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CustomText(
            widget.course!.price.toString().currency,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: .w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonField(BuildContext context) {
    return CustomTextFormField(
      controller: _reasonController,
      title: AppLabels.reason.tr,
      hintText: AppLabels.enterYourReason.tr,
      isRequired: true,
      isMultiline: true,
      maxLines: 5,
      minLines: 3,
    );
  }

  Widget _buildAttachMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.attachMedia.tr,
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(fontWeight: .w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DottedBorder(
          color: context.color.outline,
          dashPattern: const [4, 4],
          borderType: .RRect,
          radius: const .circular(4),
          child: Container(
            width: .infinity,
            padding: const .symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: context.color.surface,
              borderRadius: .circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedFile != null) ...[
                  Padding(
                    padding: const .only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: .circular(4),
                      child: Image.file(
                        File(_selectedFile!.path),
                        height: 100,
                        fit: .cover,
                      ),
                    ),
                  ),
                ] else ...[
                  CustomImage(
                    AppIcons.documentUpload,
                    width: 24,
                    height: 24,
                    color: context.color.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 10),
                ],
                Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: CustomButton(
                    title: AppLabels.chooseFileToUpload.tr,
                    onPressed: _onTapChooseFile,
                    type: CustomButtonType.outlined,
                    height: 40,
                    radius: 4,
                    borderColor: context.color.onSurface,
                    textColor: context.color.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
