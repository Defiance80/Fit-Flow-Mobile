
import 'package:collection/collection.dart';
import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/chapter_model.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/models/data_class.dart';
import 'package:fitflow/features/course/repository/course_repository.dart';
import 'package:fitflow/utils/course_navigation_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseChaptersCubit extends Cubit<CourseChaptersState> {
  final CourseRepository _repository;

  CourseChaptersCubit(this._repository) : super(CourseChaptersInitial());

  Future<void> fetchChapters(int courseId, {bool skipProgress = false}) async {
    try {
      if (!skipProgress) {
        emit(CourseChaptersProgress());
      }
      final DataClass<ChapterModel> result = await _repository
          .fetchCourseChapters(courseId: courseId);

      emit(CourseChaptersSuccess(data: result.data));
    } catch (e) {
      emit(CourseChaptersError(error: e.toString()));
    }
  }

  /// Mark a curriculum item as completed and update local state
  Future<void> markCurriculumCompleted({
    required int chapterId,
    required int courseId,
    required CurriculumModel curriculum,
    required bool sequentialAccess,
  }) async {
    final currentState = state;
    if (currentState is! CourseChaptersSuccess) return;

    try {
      // Call API to mark as completed
      await _repository.markCurriculumCompleted(
        chapterId: chapterId,
        modelId: curriculum.id,
        modelType: curriculum.type ?? 'lecture',
      );

      await fetchChapters(courseId, skipProgress: true);
    } catch (e) {
      // Optionally emit error or handle silently
      emit(CourseChaptersError(error: e.toString()));
    }
  }

  void reset() {
    emit(CourseChaptersInitial());
  }

  /// Navigate to appropriate screen based on course enrollment status
  Future<void> navigateToCourse(
    CourseModel course, {
    int? initialChapterIndex,
    int? initialLectureIndex,
  }) async {
    await CourseNavigationHelper.navigateToCourse(
      course,
      initialChapterIndex: initialChapterIndex,
      initialLectureIndex: initialLectureIndex,
    );
  }
}

abstract base class CourseChaptersState extends BaseState {}

final class CourseChaptersInitial extends CourseChaptersState {}

final class CourseChaptersProgress extends ProgressState
    implements CourseChaptersState {}

final class CourseChaptersSuccess extends BaseState
    implements CourseChaptersState {
  final List<ChapterModel> data;
  CourseChaptersSuccess({required this.data});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CourseChaptersSuccess &&
            const DeepCollectionEquality().equals(other.data, data);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(data);
}

final class CourseChaptersError extends ErrorState<String>
    implements CourseChaptersState {
  CourseChaptersError({required super.error});
}
