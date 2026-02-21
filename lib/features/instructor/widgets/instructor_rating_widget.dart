import 'package:fitflow/common/models/review_model.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class InstructorRatingWidget extends StatelessWidget {
  final ReviewModel reviewData;

  const InstructorRatingWidget({
    super.key,
    required this.reviewData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.outline),
      ),
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildRatingHeader(context),
          const SizedBox(height: 16),
          _buildRatingDistribution(context),
        ],
      ),
    );
  }

  Widget _buildRatingHeader(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                CustomText(
                  reviewData.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: .bold,
                      ),
                ),
                const SizedBox(width: 4),
                CustomText(
                  '/5',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: context.color.onSurface.withValues(alpha: 150),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            CustomText(
              '${reviewData.totalReviews} reviews',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.color.onSurface.withValues(alpha: 150),
                  ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const .only(left: 2),
              child: CustomImage(
                AppIcons.starFilled,
                width: 16,
                height: 16,
                color: index < reviewData.averageRating.floor()
                    ? context.color.warning
                    : context.color.outline,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(BuildContext context) {
    return Column(
      children: [
        _buildRatingBar(
            context, 5, reviewData.ratingDistribution.fiveStarsPercentage),
        const SizedBox(height: 8),
        _buildRatingBar(
            context, 4, reviewData.ratingDistribution.fourStarsPercentage),
        const SizedBox(height: 8),
        _buildRatingBar(
            context, 3, reviewData.ratingDistribution.threeStarsPercentage),
        const SizedBox(height: 8),
        _buildRatingBar(
            context, 2, reviewData.ratingDistribution.twoStarsPercentage),
        const SizedBox(height: 8),
        _buildRatingBar(
            context, 1, reviewData.ratingDistribution.oneStarPercentage),
      ],
    );
  }

  Widget _buildRatingBar(BuildContext context, int stars, int percentage) {
    return Row(
      children: [
        Row(
          children: [
            CustomText(
              '$stars',
              style: Theme.of(context).textTheme.bodyMedium!,
            ),
            const SizedBox(width: 4),
            CustomImage(
              AppIcons.starFilled,
              width: 16,
              height: 16,
              color: context.color.warning,
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: context.color.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: context.color.outline),
                ),
              ),
              Container(
                height: 8,
                width: (percentage / 100) *
                    (MediaQuery.of(context).size.width - 120),
                decoration: BoxDecoration(
                  color: context.color.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: CustomText(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: context.color.onSurface.withValues(alpha: 150),
                ),
            textAlign: .end,
          ),
        ),
      ],
    );
  }
}
