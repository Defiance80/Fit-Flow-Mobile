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

class CourseOverviewWidget extends StatelessWidget {
  final String level;
  final String category;
  final num currentPrice;
  final num? originalPrice;
  final String title;
  final Map<String, String> courseDetails;
  final String overview;
  final List<String> learningPoints;
  final List<String> requirements;
  final bool isFree;

  final EdgeInsetsGeometry padding;

  const CourseOverviewWidget({
    super.key,
    required this.level,
    required this.category,
    required this.currentPrice,
    required this.title,
    required this.courseDetails,
    required this.overview,
    required this.learningPoints,
    required this.requirements,
    this.originalPrice,
    this.isFree = false,
    this.padding = const .all(12),
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          _buildLevelIndicator(context),
          _buildPrice(context),
          CustomText(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final MapEntry<String, String> entry
                        in courseDetails.entries.take(3))
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 10),
                        child: _buildInfoItem(
                          context: context,
                          icon: _getIconKeyForDetail(entry.key),
                          text: entry.value,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    for (final entry in courseDetails.entries.skip(3).take(3))
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 10),
                        child: _buildInfoItem(
                          context: context,
                          icon: _getIconKeyForDetail(entry.key),
                          text: entry.value,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Divider
          _buildCustomDivider(context),
          AnimatedShowMore(
            content: overview,
            textStyle: TextStyle(
              fontSize: 14,
              color: context.color.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          _buildCustomDivider(context),

          CustomText(
            AppLabels.whatYouWillLearn.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          AnimatedShowMore<List>(
            content: List.generate(learningPoints.length, (i) {
              return _buildBulletPoint(context, learningPoints[i]);
            }),
          ),

          // Divider
          _buildCustomDivider(context),

          CustomText(
            AppLabels.requirements.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),

          AnimatedShowMore(
            content: List.generate(requirements.length, (i) {
              return _buildBulletPoint(context, requirements[i]);
            }),
          ),

          _buildCustomDivider(context),
          _buildCategoryChip(context),
        ],
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Row(
      children: [
        CustomText(
          isFree
              ? AppLabels.free.tr
              : ((currentPrice == 0 ? originalPrice : currentPrice)!
                    .toStringAsFixed(2)
                    .currency),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: .w600,
            color: isFree ? context.color.success : context.color.onSurface,
          ),
        ),
        if (!isFree &&
            originalPrice != null &&
            originalPrice! > currentPrice &&
            currentPrice != 0) ...[
          const SizedBox(width: 10),
          CustomText(
            originalPrice!.toStringAsFixed(2).currency,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: context.color.onSurface.withValues(alpha: 0.5),
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              decorationColor: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLevelIndicator(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.color.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText(
        level,
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: context.color.primary),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.color.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        category,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          fontWeight: .w500,
          color: context.color.primary,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String icon,
    required String text,
    FontWeight? fontWeight,
  }) {
    return Row(
      children: [
        CustomImage(
          _getIconForType(icon),
          width: 20,
          height: 20,
          color: context.color.onSurface,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: CustomText(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: fontWeight ?? .w400,
              color: context.color.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  String _getIconKeyForDetail(String detailKey) {
    switch (detailKey.toLowerCase()) {
      case 'duration':
        return 'clock';
      case 'chapters':
        return 'chapter';
      case 'lectures':
        return 'video';
      case 'rating':
        return 'star';
      case 'language':
        return 'language';
      case 'access':
        return 'medal';
      default:
        return detailKey;
    }
  }

  String _getIconForType(String icon) {
    switch (icon) {
      case 'book':
        return AppIcons.book;
      case 'clock':
        return AppIcons.clockFilled;
      case 'video':
        return AppIcons.video;
      case 'star':
        return AppIcons.star;
      case 'language':
        return AppIcons.language;
      case 'chapter':
        return AppIcons.chapterFilled;
      case 'medal':
        return AppIcons.medal;
      default:
        return '';
    }
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        CustomImage(
          AppIcons.check,
          width: 20,
          height: 20,
          color: context.color.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomText(
            text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: context.color.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDivider(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 1,
      color: context.color.outline,
    );
  }
}
