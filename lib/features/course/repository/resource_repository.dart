import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/features/course/models/resource_data_model.dart';

class ResourceRepository extends Blueprint {
  Future<CourseResourcesModel> fetchResource({required int id}) async {
    try {
      final response = await Api.get(Apis.getResources, data: {"id": id});

      return CourseResourcesModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
