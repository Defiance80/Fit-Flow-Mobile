import 'package:fitflow/common/cubits/paginated_api_cubit.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/core/api/api_lists.dart';

class MyLearningCubit extends PaginatedApiCubit<CourseModel> {
  final String status;
  MyLearningCubit(this.status);
  @override
  String get apiUrl => Apis.myLearning;

  @override
  CourseModel Function(Map<String, dynamic>) get fromJson =>
      CourseModel.fromJson;

  @override
  Map<String, dynamic>? get extraParams => {'progress_status': status};

  @override
  bool get useAuthToken => true;
}
