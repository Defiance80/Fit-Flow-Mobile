import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_colors.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final WidgetBuilder builder;
  const Rating({super.key, required this.builder});
  factory Rating.bar({
    required int filledStarCount,
    int starCount = 5,
    double starSize = 16,
    double starSpacing = 5,
    RatingStarStyle starStyle = RatingStarStyle.outlined,
    bool showRatingCount = false,
    bool showRatingPercentage = false,
  }) {
    int getPercentage() {
      return ((filledStarCount / starCount) * 100).round();
    }

    return Rating(
      builder: (context) => Row(
        spacing: starSpacing,
        children: [
          ...List.generate(starCount, (index) {
            final bool isFilled = index < filledStarCount;

            // Determine which icon to use based on style
            final String icon;
            final Color iconColor;

            if (starStyle == RatingStarStyle.filled) {
              // Filled style: use filled icon with different colors
              icon = AppIcons.starFilled;
              iconColor = isFilled
                  ? context.color.warning
                  : context.color.outline;
            } else {
              // Outlined style: use different icons
              icon = isFilled ? AppIcons.starFilled : AppIcons.star;
              iconColor = context.color.warning;
            }

            return CustomImage(
              icon,
              height: starSize,
              width: starSize,
              color: iconColor,
            );
          }),
          if (showRatingCount)
            CustomText(
              '(${filledStarCount.toDouble()})',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: context.color.warning),
            ),
          if (showRatingPercentage)
            CustomText(
              '${getPercentage()}%',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: context.color.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
  factory Rating.number({
    required num rating,
    required int ratingCount,
    String Function(int count)? divider,
    Color? ratingCountColor,
    bool showCount = true,
  }) {
    return Rating(
      builder: (context) {
        final String ratingCountString =
            divider?.call(ratingCount) ?? '($ratingCount)';
        return Row(
          spacing: 5,
          children: [
            CustomImage(
              AppIcons.starFilled,
              color: context.color.warning,
              width: 16,
              height: 16,
            ),
            CustomText(
              rating.toString(),
              style: Theme.of(context).textTheme.bodySmall!,
            ),
            if (showCount)
              CustomText(
                ratingCountString,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color:
                      ratingCountColor ??
                      context.color.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
