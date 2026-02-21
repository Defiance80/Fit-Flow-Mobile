import 'package:fitflow/common/models/instructor_model.dart';
import 'package:fitflow/common/widgets/animated_showmore_container.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstructorCardWidget extends StatelessWidget {
  final InstructorModel instructor;
  final bool showHeader;
  final EdgeInsetsGeometry padding;

  const InstructorCardWidget({
    super.key,
    required this.instructor,
    this.showHeader = true,
    this.padding = const .all(8),
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: .start,
        spacing: 10,
        children: [
          // Header (optional)
          if (showHeader) ...[
            CustomText(
              AppLabels.instructor.tr,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: .w500,
                    color: context.color.onSurface,
                  ),
            ),
          ],
          // Instructor profile row
          Row(
            children: [
              // Profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: instructor.profile.isNotEmpty
                      ? CustomImage(instructor.profile, fit: .cover)
                      : CustomImage(
                          AppIcons.profilePlaceholder,
                          fit: .cover,
                          color: context.color.onSurface.withValues(alpha: 0.3),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Instructor info
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Rating row
                    Row(
                      children: [
                        CustomImage(
                          AppIcons.starFilled,
                          width: 16,
                          height: 16,
                          color: context.color.warning,
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          '${instructor.averageRating}',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: context.color.onSurface.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          AppLabels.review.tr,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: context.color.onSurface.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Instructor name
                    CustomText(
                      instructor.name,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: .w500,
                            color: context.color.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Instructor specialization
                    CustomText(
                      instructor.qualification ?? '',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                context.color.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Instructor description
          if (instructor.aboutMe != null) ...[
            AnimatedShowMore(
              content: instructor.aboutMe?.stripHtmlTags,
              maxLines: 7,
              textStyle: TextStyle(
                fontSize: 16,
                color: context.color.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
