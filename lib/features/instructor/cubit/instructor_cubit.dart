import 'package:elms/common/cubits/paginated_api_cubit.dart';
import 'package:elms/common/models/instructor_model.dart';
import 'package:elms/core/api/api_lists.dart';

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
