import 'package:elms/common/enums.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/common/widgets/wishlist_button.dart';
import 'package:elms/core/constants/app_colors.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseCard extends StatelessWidget {
  final Widget Function(BuildContext context, CourseCardStyle style) builder;
  final CourseCardStyle style;
  final CourseModel course;

  const CourseCard._({
    required this.builder,
    required this.style,
    required this.course,
  });

  ///Styles of card
  factory CourseCard.vertical({
    required CourseModel course,
    VoidCallback? onTap,
  }) {
    return CourseCard._(
      style: CourseCardStyle.vertical,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return GestureDetector(
          onTap: onTap,
          child: CustomCard(
            width: 302,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                _buildImage(
                  course,
                  height: 152,
                  fitWidth: true,
                  positioned: Positioned(
                    top: 10,
                    right: 10,
                    child: _buildBookmarkButton(course),
                  ),
                ),
                Padding(
                  padding: const .all(12),
                  child: Column(
                    crossAxisAlignment: .start,
                    spacing: 6,
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          _buildChip(
                            context,
                            course.level.capitalizeFirst ?? '',
                            radius: 4,
                          ),
                          if (course.ratings != 0) _buildRatings(course),
                        ],
                      ),
                      _buildTitle(
                        context,
                        course,
                        style: Theme.of(context).textTheme.titleMedium!,
                      ),
                      _buildDescription(context, course),
                      ...[
                        _buildInstructor(context, course),
                        _buildDivider(),
                        _buildPrice(context, course, style, fontSize: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  factory CourseCard.horizontal({
    required CourseModel course,
    double? width,
    double? height,
    double? radius,
    VoidCallback? onTap,
  }) {
    return CourseCard._(
      style: CourseCardStyle.horizontal,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return GestureDetector(
          onTap: onTap,
          child: CustomCard(
            width: width,
            height: height,
            borderRadius: radius ?? 8,
            padding: const .all(12),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      if (course.level.isNotEmpty) ...[
                        _buildChip(
                          context,
                          course.level.capitalizeFirst!,
                          radius: 20,
                          fontSize: 11,
                        ),
                        const SizedBox(height: 6),
                      ],
                      _buildTitle(
                        context,
                        course,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(fontWeight: .w700),

                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      _buildDescription(context, course),
                      const SizedBox(height: 6),
                      _buildInstructor(context, course, fontSize: 12),
                      _buildDivider(),
                      _buildPrice(
                        context,
                        course,
                        style,
                        showDiscountPriceBottom: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _buildImage(
                    course,
                    fitHeight: true,
                    radius: 8,
                    positioned: course.ratings != 0
                        ? Positioned(
                            bottom: 4,
                            right: 4,
                            child: CustomCard(
                              borderRadius: 4,
                              padding: const EdgeInsetsDirectional.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              child: _buildRatings(course),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  factory CourseCard.learning({
    required CourseModel course,
    VoidCallback? onTap,
    bool otherOptions = false,
  }) {
    return CourseCard._(
      style: CourseCardStyle.learning,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return GestureDetector(
          onTap: onTap,
          behavior: .opaque,
          child: CustomCard(
            width: context.screenWidth,
            padding: const .all(8),
            borderRadius: 10,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        _buildChip(
                          context,
                          course.level.capitalizeFirst!,
                          fontSize: 11,
                          radius: 4,
                        ),
                        const SizedBox(height: 6),
                        _buildCourseName(context, course),
                        const SizedBox(height: 2),
                        _buildTitle(
                          context,
                          course,
                          style: Theme.of(context).textTheme.titleMedium!,
                          maxLines: 1,
                        ),
                        const Spacer(),
                        _buildCourseProgress(course),
                      ],
                    ),
                  ),
                ),
                _buildImage(
                  course,
                  width: 108,
                  height: 111,
                  radius: 6,
                  positioned: otherOptions
                      ? Positioned(
                          top: 6,
                          right: 6,
                          child: _buildOtherOptionsMenu(context, course),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  factory CourseCard.withCourseDetails({
    required CourseModel course,
    double? width,
    double? height,
    double? radius,
    VoidCallback? onTap,
  }) {
    Widget buildDetail(
      BuildContext context, {
      required String title,
      required String icon,
      MainAxisAlignment alignment = .center,
    }) {
      return Row(
        spacing: 6,
        mainAxisAlignment: alignment,
        children: [
          CustomImage(
            icon,
            height: 16,
            width: 16,
            color: context.color.primary,
            radius: 4,
          ),
          CustomText(title, style: Theme.of(context).textTheme.bodyMedium!),
        ],
      );
    }

    Widget buildVerticalDivider() {
      return const VerticalDivider(indent: 6, endIndent: 6, width: 1);
    }

    return CourseCard._(
      style: CourseCardStyle.withCourseDetails,
      course: course,
      builder: (BuildContext context, CourseCardStyle style) {
        return CustomCard(
          padding: const .all(8),
          child: Column(
            mainAxisSize: .min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const .symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Rating.number(
                            rating: course.averageRating,
                            ratingCount: course.ratings,
                          ),
                          _buildTitle(
                            context,
                            course,
                            style: Theme.of(context).textTheme.titleMedium!,
                            maxLines: 1,
                          ),
                          _buildInstructor(context, course, fontSize: 14),
                          _buildPrice(
                            context,
                            course,
                            style,
                            showDiscountPercentage: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CustomImage(course.imageUrl),
                  // if (false)
                  Expanded(
                    flex: 3,
                    child: _buildImage(
                      course,
                      radius: 6,
                      height: 100,
                      width: 150,
                      positioned: Positioned.directional(
                        end: 6,
                        top: 6,
                        textDirection: Directionality.of(context),
                        child: _buildBookmarkButton(course),
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: .symmetric(vertical: 8),
                child: Divider(height: 1),
              ),

              ///Details here
              Container(
                height: 25,
                padding: const .symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: buildDetail(
                        context,
                        title: AppLabels.time.tr,
                        icon: AppIcons.clock,
                        alignment: .start,
                      ),
                    ),
                    buildVerticalDivider(),
                    Expanded(
                      child: buildDetail(
                        context,
                        title: AppLabels.chapter.tr,
                        icon: AppIcons.chapter,
                      ),
                    ),
                    buildVerticalDivider(),
                    Expanded(
                      child: buildDetail(
                        context,
                        title: AppLabels.students.tr,
                        icon: AppIcons.hat,
                        alignment: .end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, style);
  }

  static Widget _buildTitle(
    BuildContext context,
    CourseModel course, {
    required TextStyle style,
    int? maxLines,
  }) {
    return CustomText(
      course.title,
      style: style,
      maxLines: maxLines ?? 2,
      ellipsis: true,
    );
  }

  static Widget _buildDescription(BuildContext context, CourseModel course) {
    return CustomText(
      course.shortDescription,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
      ),
      maxLines: 1,
      ellipsis: true,
    );
  }

  static Widget _buildInstructor(
    BuildContext context,
    CourseModel course, {
    double? fontSize,
  }) {
    return CustomText(
      '${AppLabels.by.tr} : ${course.authorName}',
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        fontSize: fontSize,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
      ),
    );
  }

  static Widget _buildCourseName(BuildContext context, CourseModel course) {
    return CustomText(
      course.currentChapter.toString(),
      maxLines: 2,
      ellipsis: true,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
      ),
    );
  }

  static Widget _buildChip(
    BuildContext context,
    String text, {
    double? fontSize,
    double? radius,
  }) {
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(radius ?? 4),
      ),
      child: CustomText(
        text,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  static Widget _buildOtherOptionsMenu(
    BuildContext context,
    CourseModel course,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'review') {
          Get.toNamed(AppRoutes.reviewsScreen, arguments: course.id);
        } else if (value == 'assignments') {
          Get.toNamed(AppRoutes.assignmentScreen, arguments: course.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'review', child: Text(AppLabels.review.tr)),
        PopupMenuItem(
          value: 'assignments',
          child: Text(AppLabels.assignments.tr),
        ),
      ],
      surfaceTintColor: context.color.primary,
      child: CustomCard(
        width: 24,
        height: 24,
        borderColor: context.color.onSurface.withValues(alpha: 0.2),
        borderRadius: 100,
        child: CustomImage(
          AppIcons.hamburgerMenu,
          fit: .none,
          color: context.color.onSurface,
        ),
      ),
    );
  }

  static Widget _buildCourseProgress(CourseModel course) {
    final num progressPercentage = course.progressPercentage!;
    final bool isCompleted = course.progressStatus == 'completed';
    final context = Get.context!;

    return Column(
      spacing: 5,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            CustomText(
              isCompleted
                  ? AppLabels.completed.tr
                  : '${progressPercentage.ceil()}%',
              style: Theme.of(context).textTheme.bodySmall!,
            ),
            if (isCompleted)
              CustomImage(AppIcons.correct)
            else
              CustomText(
                '${course.completedChapters}/${course.totalChapters} ${AppLabels.chapters.tr}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: context.color.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        LinearProgressIndicator(
          value: course.progressPercentage! / 100,
          color: Colors.green,
          minHeight: 9,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  static Widget _buildImage(
    CourseModel course, {
    Positioned? positioned,
    bool fitWidth = false,
    bool fitHeight = false,
    double? width,
    double? height,
    double? radius,
  }) {
    return Stack(
      clipBehavior: .antiAlias,
      children: [
        CustomImage(
          course.image,
          radius: radius,
          width: fitWidth ? double.infinity : width,
          height: fitHeight ? double.infinity : height,
          fit: .cover,
        ),
        positioned ?? const SizedBox.shrink(),
      ],
    );
  }

  static Widget _buildBookmarkButton(CourseModel course) {
    return WishlistButton(
      courseId: course.id,
      isWishlisted: course.isWishlisted,
    );
  }

  static Widget _buildRatings(CourseModel course) {
    final BuildContext context = Get.context!;
    return Rating.number(
      rating: course.ratings.toDouble(),
      ratingCount: course.ratings,
      divider: (count) {
        return '| $count';
      },
    );
  }

  static Widget _buildDivider() => const Divider();

  static Widget _buildPrice(
    BuildContext context,
    CourseModel course,
    CourseCardStyle style, {
    double? fontSize,
    bool showDiscountPercentage = true,
    bool showDiscountPriceBottom = false,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      crossAxisAlignment: style == CourseCardStyle.vertical ? .center : .start,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            if (course.isFree) ...[
              CustomText(
                'Free',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: context.color.success,
                  fontSize: fontSize,
                  fontWeight: .w600,
                ),
              ),
            ] else ...[
              CustomText(
                course.finalPrice.toString().currency,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: fontSize,
                  fontWeight: .w600,
                ),
              ),
            ],

            ///This will show when the card is horizontal because we need below the price in horizontal UI
            if (course.hasDiscount && showDiscountPriceBottom)
              CustomText(
                course.price.toString().currency,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 12,
                  color: context.color.onSurface.withValues(alpha: 0.6),
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 2,
                  decorationColor: Colors
                      .grey, //Added hardcoded color here because it will always be same
                ),
              ),
          ],
        ),
        if (!showDiscountPriceBottom && course.hasDiscount)
          Padding(
            padding: const .symmetric(horizontal: 10),
            child: CustomText(
              course.price.toString().currency,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 14,
                color: context.color.onSurface.withValues(alpha: 0.6),
                decoration: TextDecoration.lineThrough,
                decorationThickness: 2,
                decorationColor: Colors
                    .grey, //Added hardcoded color here because it will always be same
              ),
            ),
          ),
        const Spacer(),
        if (showDiscountPercentage && course.hasDiscount)
          _buildDiscount(context, course, style),
      ],
    );
  }

  static Widget _buildDiscount(
    BuildContext context,
    CourseModel course,
    CourseCardStyle style,
  ) {
    final ColorScheme scheme = Get.theme.colorScheme;
    final bool isVertical = style == CourseCardStyle.vertical;
    final Color backgroundColor = isVertical ? scheme.error : scheme.surface;
    final Color foregroundColor = isVertical ? scheme.onError : scheme.error;

    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomImage(
            AppIcons.discount,
            width: 14,
            height: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 2),
          CustomText(
            '${course.discountPercentage}% ${AppLabels.off.tr}',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12,
              fontWeight: .w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
