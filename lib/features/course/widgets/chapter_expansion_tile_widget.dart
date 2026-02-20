import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_expandable_tile.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/course/widgets/chapter_lesson_tile.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterExpansionTileWidget extends StatelessWidget {
  final ChapterModel chapter;
  final bool? isExpanded;
  final VoidCallback onToggle;
  final bool sequentialAccess;
  final bool isEnrolled;
  final int? currentCurriculumId;
  final Function(CurriculumModel)? onLessonTap;

  const ChapterExpansionTileWidget({
    super.key,
    required this.chapter,
    this.isExpanded,
    required this.onToggle,
    this.onLessonTap,
    required this.sequentialAccess,
    this.isEnrolled = false,
    this.currentCurriculumId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpandableTile(
      title: chapter.title,
      subtitle: _buildChapterDetails(),
      isExpanded: isExpanded,
      onToggle: onToggle,
      content: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: chapter.curriculum.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, lessonIndex) {
          final CurriculumModel lesson = chapter.curriculum[lessonIndex];

          ///Only applicable if the sequential access is true
          final int unlockedCurriculumRange = chapter.curriculum.indexWhere(
            (element) => !element.isCompleted,
          );

          // Item is unlocked if: all items are completed OR first incomplete item is at/after this index
          final bool isUnlocked =
              unlockedCurriculumRange == -1 ||
              unlockedCurriculumRange >= lessonIndex;

          ///End///

          // Lock logic:
          // - If NOT enrolled: lock all lessons EXCEPT those with free preview
          // - If enrolled: use sequential access logic
          final bool isLocked = !isEnrolled
              ? !lesson.freePreview
              : (sequentialAccess && !isUnlocked);
          return ChapterLessonTile(
            key: ValueKey('${lesson.id}${lesson.isCompleted}'),
            title: lesson.title,
            isCompleted: lesson.isCompleted,
            icon: _getLessonTypeIcon(lesson.type, lesson.lectureType),
            isLocked: isLocked,
            hasPreview: lesson.freePreview && !isEnrolled,
            isCurrent:
                currentCurriculumId != null && lesson.id == currentCurriculumId,
            onTap: isLocked == true
                ? null
                : (onLessonTap != null ? () => onLessonTap!(lesson) : null),
            iconColor: context.color.onSecondary,
            textColor: context.color.onSecondary,
            iconSize: 16,
          );
        },
      ),
    );
  }

  String? _buildChapterDetails() {
    final List<String> details = [
      if (chapter.lecturesCount != 0)
        AppLabels.lecturesCount.tr.replaceAll(
          '{{count}}',
          chapter.lecturesCount.toString(),
        ),
      if (chapter.assignmentsCount != 0)
        AppLabels.assignmentCount.tr.replaceAll(
          '{{count}}',
          chapter.assignmentsCount.toString(),
        ),
      if (chapter.quizzesCount != 0)
        AppLabels.quizCount.tr.replaceAll(
          '{{count}}',
          chapter.quizzesCount.toString(),
        ),
      if (getTotalMinutes() != 0) _formatDuration(),
    ];
    final String joined = details.join(' | ');
    return joined.isEmpty ? null : joined;
  }

  int getTotalMinutes() {
    int totalMinutes = 0;
    for (var curriculum in chapter.curriculum) {
      totalMinutes += (curriculum.hours ?? 0) * 60;
      totalMinutes += curriculum.minutes ?? 0;
    }
    return totalMinutes;
  }

  String _formatDuration() {
    final int totalMinutes = getTotalMinutes();

    if (totalMinutes == 0) return AppLabels.durationZeroMin.tr;

    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours > 0) {
      return AppLabels.durationHoursMinutes.tr
          .replaceAll('{{hours}}', hours.toString())
          .replaceAll('{{minutes}}', minutes.toString());
    } else {
      return AppLabels.durationMinutes.tr.replaceAll(
        '{{minutes}}',
        minutes.toString(),
      );
    }
  }

  String _getLessonTypeIcon(String? type, String? lectureType) {
    final lowerType = type?.toLowerCase();

    switch (lowerType) {
      case 'video':
        return AppIcons.videoOutline;
      case 'pdf':
      case 'file':
      case 'document':
        return AppIcons.note;
      case 'quiz':
        return AppIcons.game;
      case 'assignment':
        return AppIcons.attachSquare;
      case 'link':
      case 'url':
        return AppIcons.link;
      default:
        return AppIcons.videoOutline;
    }
  }
}
