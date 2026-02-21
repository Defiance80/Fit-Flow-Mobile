import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/features/instructor/models/instructor_details_model.dart';

/// Implementation of InstructorRepository
class InstructorRepository {
  Future<InstructorDetailsModel> fetchInstructorDetails({
    required String id,
  }) async {
    final result = await Api.get(
      Apis.getInstructorDetails,
      data: {ApiParams.id: id},
    );
    return InstructorDetailsModel.fromJson(result['data']);
  }
}
