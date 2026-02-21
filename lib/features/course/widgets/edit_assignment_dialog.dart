import 'package:dotted_border/dotted_border.dart';
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_dialog_box.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/course/cubit/assignment_cubit.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EditAssignmentDialog extends StatefulWidget {
  final int submissionId;
  final int courseId;
  final String? existingComment;
  final String? existingFileName;

  const EditAssignmentDialog({
    super.key,
    required this.submissionId,
    required this.courseId,
    this.existingComment,
    this.existingFileName,
  });

  @override
  State<EditAssignmentDialog> createState() => _EditAssignmentDialogState();
}

class _EditAssignmentDialogState extends State<EditAssignmentDialog> {
  final TextEditingController _commentController = TextEditingController();
  List<PlatformFile>? _selectedFiles;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingComment != null) {
      _commentController.text = widget.existingComment!;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _onTapChooseFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      UiUtils.showSnackBar('Error picking files: $e', isError: true);
    }
  }

  void _onTapUpdate() {
    if (_commentController.text.trim().isEmpty) {
      UiUtils.showSnackBar('Please enter a comment', isError: true);
      return;
    }

    final List<String> filePaths = _selectedFiles != null
        ? _selectedFiles!
              .map((file) => file.path ?? '')
              .where((path) => path.isNotEmpty)
              .toList()
        : [];

    if (filePaths.isEmpty && widget.existingFileName == null) {
      UiUtils.showSnackBar('Please select at least one file', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    context.read<AssignmentCubit>().updateAssignment(
      submissionId: widget.submissionId,
      files: filePaths,
      comment: _commentController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignmentCubit, AssignmentState>(
      listener: (context, state) {
        if (state is AssignmentSubmissionSuccess) {
          setState(() {
            _isUploading = false;
          });
          UiUtils.showSnackBar(state.message);
          Navigator.of(context).pop();
          context.read<AssignmentCubit>().fetchAssignments(widget.courseId);
        } else if (state is AssignmentSubmissionError) {
          setState(() {
            _isUploading = false;
          });
          UiUtils.showSnackBar(state.error, isError: true);
        }
      },
      child: CustomDialogBox(
        actions: [
          DialogButton(
            title: _isUploading ? AppLabels.updating.tr : AppLabels.update.tr,
            style: DialogButtonStyle.primary,
            onTap: _isUploading ? () {} : _onTapUpdate,
          ),
        ],
        title: AppLabels.editAssignment.tr,
        content: Column(
          spacing: 20,
          mainAxisSize: .min,
          children: [
            CustomTextFormField(
              controller: _commentController,
              title: AppLabels.assignmentTitle.tr,
              hintText: AppLabels.text.tr,
              fillColor: context.color.outline.withValues(alpha: 0.17),
            ),
            GestureDetector(
              onTap: _onTapChooseFile,
              child: DottedBorder(
                strokeWidth: 2,
                borderType: BorderType.RRect,
                dashPattern: const [6, 5],
                color: context.color.outline,
                child: SizedBox(
                  width: context.screenWidth,
                  child: Padding(
                    padding: const .symmetric(vertical: 32, horizontal: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        CustomCard(
                          color: context.color.outline.withValues(alpha: 0.17),
                          border: 0,
                          padding: const .all(8),
                          child: CustomImage(
                            AppIcons.documentUpload,
                            color: context.color.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        if (_selectedFiles == null || _selectedFiles!.isEmpty)
                          Column(
                            spacing: 4,
                            children: [
                              CustomText(
                                AppLabels.chooseFileToUpload.tr,
                                style: Theme.of(context).textTheme.bodyLarge!,
                              ),
                              if (widget.existingFileName != null)
                                CustomText(
                                  AppLabels.currentFile.tr.replaceAll(
                                    '{{filename}}',
                                    widget.existingFileName!,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: context.color.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                  maxLines: 1,
                                ),
                            ],
                          )
                        else
                          Column(
                            spacing: 8,
                            children: [
                              CustomText(
                                AppLabels.filesSelected.tr
                                    .replaceAll(
                                      '{{count}}',
                                      _selectedFiles!.length.toString(),
                                    )
                                    .replaceAll(
                                      '{{plural}}',
                                      _selectedFiles!.length == 1
                                          ? AppLabels.file.tr
                                          : AppLabels.files.tr,
                                    ),
                                style: Theme.of(context).textTheme.bodyLarge!,
                              ),
                              ..._selectedFiles!.map(
                                (file) => CustomText(
                                  file.name,
                                  style: Theme.of(context).textTheme.bodySmall!,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
