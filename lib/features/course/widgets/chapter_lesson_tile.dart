import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_radio_button.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterLessonTile extends StatelessWidget {
  final String title;
  final String icon;
  final bool isLocked;
  final bool? isCompleted;
  final bool hasPreview;
  final bool isCurrent;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ChapterLessonTile({
    super.key,
    required this.title,
    required this.icon,
    this.isLocked = false,
    this.hasPreview = false,
    this.isCurrent = false,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
    this.padding,
    this.iconSize,
    this.fontSize,
    this.fontWeight,
    this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const .symmetric(vertical: 6, horizontal: 8),
      decoration: isCurrent
          ? BoxDecoration(
              color: context.color.outline,
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: iconSize ?? 24,
              height: iconSize ?? 24,
              child: CustomImage(
                icon,
                width: iconSize ?? 24,
                height: iconSize ?? 24,
                color: context.color.onSurface,
              ),
            ),
            const SizedBox(width: 6),

            // Title
            Expanded(
              child: CustomText(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  color: context.color.onSurface,
                ),
              ),
            ),
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (trailing != null) {
      return trailing!;
    } else if (hasPreview) {
      return Container(
        padding: const .symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: context.color.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomText(
          AppLabels.preview.tr,
          style: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: context.color.primary),
        ),
      );
    } else if (isLocked) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(shape: .circle),
        child: Center(
          child: CustomImage(
            AppIcons.lock,
            width: 18,
            height: 18,
            color: context.color.onSurface.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return CustomRadioButton(isSelected: isCompleted ?? false, freeze: true);
  }
}
