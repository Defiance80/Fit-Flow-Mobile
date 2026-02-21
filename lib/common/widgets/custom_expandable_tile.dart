import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomExpandableTile extends StatefulWidget {
  final String? title;
  final Widget? customTitle;
  final String? subtitle;
  final Widget content;
  final bool? isExpanded;
  final VoidCallback onToggle;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final FontWeight? titleFontWeight;
  final FontWeight? subtitleFontWeight;
  final Widget? customIcon;
  final Color? dividerColor;
  final bool? isIconTop;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomExpandableTile({
    super.key,
    this.title,
    this.backgroundColor,
    this.customTitle,
    required this.content,
    this.isExpanded,
    required this.onToggle,
    this.subtitle,
    this.padding,
    this.titleColor,
    this.subtitleColor,
    this.titleFontSize,
    this.subtitleFontSize,
    this.titleFontWeight,
    this.subtitleFontWeight,
    this.customIcon,
    this.dividerColor,
    this.isIconTop,
    this.borderColor,
  });

  @override
  State<CustomExpandableTile> createState() => _CustomExpandableTileState();
}

class _CustomExpandableTileState extends State<CustomExpandableTile> {
  late bool isExpanded = widget.isExpanded ?? false;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: widget.backgroundColor,
      borderColor: widget.borderColor,
      padding: widget.padding ?? const .all(10),
      child: Column(
        children: [
          // Header with expand/collapse button
          GestureDetector(
            behavior: .opaque,
            onTap: () {
              isExpanded = !isExpanded;
              setState(() {});
              widget.onToggle.call();
            },
            child: Row(
              crossAxisAlignment: widget.isIconTop == true
                  ? .start
                  : .center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      if (widget.customTitle != null) ...[
                        widget.customTitle!,
                      ] else ...[
                        // Title
                        CustomText(
                          widget.title ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                fontSize: widget.titleFontSize,
                                fontWeight:
                                    widget.titleFontWeight ?? .w500,
                                color: widget.titleColor ??
                                    context.color.onSurface,
                              ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          // Subtitle
                          CustomText(
                            widget.subtitle!,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontSize: widget.subtitleFontSize,
                                      color: widget.subtitleColor ??
                                          context.color.onSurface
                                              .withValues(alpha: 0.76),
                                    ),
                          ),
                        ]
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: .circle,
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: widget.customIcon ??
                          CustomImage(
                            AppIcons.arrowDown,
                            width: 20,
                            height: 20,
                            color: context.color.onSurface,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content (shown only when expanded)
          if (isExpanded) ...[
            Divider(
              height: 12,
              thickness: 1,
              color: widget.dividerColor ??
                  context.color.onSurface.withValues(alpha: 0.1),
            ),
            widget.content,
          ],
        ],
      ),
    );
  }
}
