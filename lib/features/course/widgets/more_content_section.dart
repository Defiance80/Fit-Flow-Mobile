import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/deep_linking/deep_link_manager.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubit/course_chapters_cubit.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class MoreContentSection extends StatelessWidget {
  final CourseModel course;
  const MoreContentSection({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        spacing: 10,
        children: [
          _buildMoreContentTile(
            context,
            name: AppLabels.aboutCourse.tr,
            icon: AppIcons.edit,
            onTap: () {
              CourseNavigationHelper.navigateToCourseContentRoute(
                nestedRoute: CourseContentRoute.aboutCourse,
                arguments: CourseDetailsScreenArguments(course: course),
              );
            },
          ),
          _buildMoreContentTile(
            context,
            name: AppLabels.resources.tr,
            icon: AppIcons.questionMessage,
            onTap: () {
              // Get chapters from the existing cubit state
              final CourseChaptersState chaptersState = context
                  .read<CourseChaptersCubit>()
                  .state;
              if (chaptersState is CourseChaptersSuccess) {
                CourseNavigationHelper.navigateToCourseContentRoute(
                  nestedRoute: CourseContentRoute.courseResources,
                  arguments: {
                    "chapters": chaptersState.data,
                    "course_id": course.id,
                  },
                );
              }
            },
          ),
          _buildMoreContentTile(
            context,
            name: AppLabels.courseCertificate.tr,
            icon: AppIcons.courseCertificate,
            onTap: () {
              CourseNavigationHelper.navigateToCourseContentRoute(
                nestedRoute: CourseContentRoute.courseCertificate,
                arguments: {'courseId': course.id},
              );
            },
          ),
          _buildMoreContentTile(
            context,
            name: AppLabels.assignment.tr,
            icon: AppIcons.ruler,
            onTap: () {
              CourseNavigationHelper.navigateToCourseContentRoute(
                nestedRoute: CourseContentRoute.assignment,
                arguments: course.id,
              );
            },
          ),
          _buildMoreContentTile(
            context,
            name: AppLabels.review.tr,
            icon: AppIcons.star,
            onTap: () {
              CourseNavigationHelper.navigateToCourseContentRoute(
                nestedRoute: CourseContentRoute.reviews,
                arguments: course.id,
              );
            },
          ),
          _buildMoreContentTile(
            context,
            name: AppLabels.shareThisCourse.tr,
            icon: AppIcons.share,
            onTap: () async {
              await Share.shareUri(
                Uri.parse(
                  DeepLinkManager.instance.createDeepLink(slug: course.slug!),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreContentTile(
    BuildContext context, {
    required String name,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const .symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 14,
          children: [
            CustomImage(
              icon,
              width: 20,
              height: 20,
              color: context.color.onSurface,
            ),
            CustomText(
              name,
              style: Theme.of(context).textTheme.bodyMedium!,
              fontWeight: .w500,
            ),
            const Spacer(),
            CustomImage(AppIcons.right, color: context.color.onSurface),
          ],
        ),
      ),
    );
  }
}
