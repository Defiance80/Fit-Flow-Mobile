import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitflow/common/models/category_model.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isFullCard;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isFullCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomCard(
        child: Container(
          width: isFullCard ? double.infinity : null,
          padding: const .all(8),
          child: Row(
            mainAxisSize: .min,
            children: [
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsetsDirectional.only(end: 16),
                child: CustomImage(
                  category.image,
                  width: 52,
                  height: 52,
                  radius: 6,
                ),
              ),
              Expanded(
                flex: isFullCard ? 1 : 0,
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    CustomText(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: .w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      category.courseCount == 0
                          ? AppLabels.noCourses.tr
                          : '${category.courseCount}+ ${AppLabels.courses.tr}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: context.color.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isFullCard)
                CustomImage(AppIcons.right, color: context.color.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
