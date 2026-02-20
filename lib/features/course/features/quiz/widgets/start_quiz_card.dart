import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/course/cubit/course_chapters_cubit.dart';
import 'package:elms/features/course/features/quiz/screens/quiz_screen.dart';
import 'package:elms/utils/course_navigation_helper.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class StartQuizCard extends StatelessWidget {
  final String? courseChapterQuizId;
  final CurriculumModel curriculum;
  final int courseId;
  final int chapterId;

  const StartQuizCard({
    super.key,
    this.courseChapterQuizId,
    required this.curriculum,
    required this.courseId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 211,
      width: double.infinity,
      padding: const .all(10),
      color: context.color.outline,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          CustomImage(AppIcons.quiz),
          CustomText(
            AppLabels.startQuizTitle.tr,
            style: Theme.of(context).textTheme.bodySmall!,
          ),
          CustomText(
            AppLabels.startQuizDescription.tr,
            textAlign: .center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontSize: 10),
          ),
          CustomButton(
            title: AppLabels.startQuiz.tr,
            onPressed: () {
              final cubit = context.read<CourseChaptersCubit?>();
              CourseNavigationHelper.navigateToCourseContentRoute(
                nestedRoute: CourseContentRoute.quiz,
                arguments: QuizScreenArguments(
                  passingMarks: curriculum.passingScore ?? 0,
                  questions: curriculum.questions!,
                  courseChapterQuizId: int.parse(courseChapterQuizId ?? ''),
                  quizTitle: 'Quiz',
                  totalMarks: curriculum.totalPoints!,
                  courseId: courseId,
                  chapterId: chapterId,
                  courseChaptersCubit: cubit,
                ),
              );
            },
            backgroundColor: context.color.primary,
            height: 26,
            width: 160,
            radius: 4,
          ),
        ],
      ),
    );
  }
}
