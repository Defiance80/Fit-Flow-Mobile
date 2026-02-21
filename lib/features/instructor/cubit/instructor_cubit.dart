import 'package:fitflow/common/cubits/paginated_api_cubit.dart';
import 'package:fitflow/common/models/instructor_model.dart';
import 'package:fitflow/core/api/api_lists.dart';

class InstructorCubit extends PaginatedApiCubit<InstructorModel> {
  final int? featureSectionId;

  InstructorCubit({this.featureSectionId});

  @override
  String get apiUrl => Apis.getInstructors;

  @override
  InstructorModel Function(Map<String, dynamic>) get fromJson =>
      InstructorModel.fromMap;

  @override
  bool get useAuthToken => false;

  @override
  Map<String, dynamic>? get extraParams => featureSectionId != null
      ? {'feature_section_id': featureSectionId}
      : null;
}
