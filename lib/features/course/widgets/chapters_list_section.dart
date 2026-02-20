import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/widgets/chapter_expansion_tile_widget.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChaptersListSection extends StatefulWidget {
  final List<ChapterModel> chapters;
  final String? title;
  final EdgeInsetsGeometry padding;
  final bool sequentialAccess;
  final bool isEnrolled;
  final int? currentCurriculumId;
  final Function(int chapterId, CurriculumModel curriculum)? onCurriculumTap;

  const ChaptersListSection({
    super.key,
    required this.chapters,
    this.title,
    this.padding = .zero,
    required this.sequentialAccess,
    this.isEnrolled = false,
    this.currentCurriculumId,
    this.onCurriculumTap,
  });

  @override
  State<ChaptersListSection> createState() => _ChaptersListSectionState();
}

class _ChaptersListSectionState extends State<ChaptersListSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (widget.title != null) ...[
            CustomText(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: .w500,
                color: context.color.onSurface,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.chapters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final ChapterModel chapter = widget.chapters[index];
              return ChapterExpansionTileWidget(
                chapter: chapter,
                sequentialAccess: widget.sequentialAccess,
                isEnrolled: widget.isEnrolled,
                currentCurriculumId: widget.currentCurriculumId,
                isExpanded: true,
                onToggle: () {},
                onLessonTap: (CurriculumModel lesson) {
                  // Handle curriculum tap for completion tracking
                  if (widget.onCurriculumTap != null) {
                    widget.onCurriculumTap!(chapter.id, lesson);
                  }
                  // Navigate to preview if available and not enrolled
                  if (lesson.freePreview && !widget.isEnrolled) {
                    final List<PreviewVideoModel> previews = context
                        .read<CourseDetailsCubit>()
                        .getPreviews();

                    final String? currentLectureUrl =
                        lesson.url ?? lesson.youtubeUrl;

                    Get.toNamed(
                      AppRoutes.videoPreviewScreen,
                      arguments: {
                        'previewVideos': previews,
                        'currentVideo': previews
                            .where(
                              (element) => element.video == currentLectureUrl,
                            )
                            .firstOrNull,
                      },
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
