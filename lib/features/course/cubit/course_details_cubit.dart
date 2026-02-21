import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/course_details_model.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/features/course/repository/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final CourseRepository _repository;

  CourseDetailsCubit(this._repository) : super(CourseDetailsInitial());

  CourseDetailsModel? _courseDetails;
  CourseDetailsModel? get courseDetails => _courseDetails;

  Future<void> fetchCourseDetails(CourseModel initialCourse) async {
    try {
      emit(
        CourseDetailsProgress(
          initialData: CourseDetailsModel.fromCourseModel(initialCourse),
        ),
      );

      final result = await _repository.fetchCourseDetails(initialCourse.id);
      final apiCourseDetails = result;

      final mergedCourseDetails = CourseDetailsModel.fromCourseModel(
        initialCourse,
      ).mergeWithApiData(apiCourseDetails);

      _courseDetails = mergedCourseDetails;
      emit(CourseDetailsSuccess(data: mergedCourseDetails));
    } catch (e) {
      emit(CourseDetailsError(error: e.toString()));
    }
  }

  List<PreviewVideoModel> getPreviews() {
    if (state case final CourseDetailsSuccess success) {
      return success.data.previewVideos;
    }
    return [];
  }

  void reset() {
    _courseDetails = null;
    emit(CourseDetailsInitial());
  }

  void setInitialData(CourseDetailsModel courseDetails) {
    _courseDetails = courseDetails;
    emit(CourseDetailsSuccess(data: courseDetails));
  }
}

abstract base class CourseDetailsState extends BaseState {}

final class CourseDetailsInitial extends CourseDetailsState {}

final class CourseDetailsProgress extends ProgressState
    implements CourseDetailsState {
  final CourseDetailsModel? initialData;

  CourseDetailsProgress({this.initialData});
}

final class CourseDetailsSuccess extends BaseState
    implements CourseDetailsState {
  final CourseDetailsModel data;

  CourseDetailsSuccess({required this.data});
}

final class CourseDetailsError extends ErrorState<String>
    implements CourseDetailsState {
  CourseDetailsError({required super.error});
}
