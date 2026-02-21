import 'package:fitflow/common/models/course_language_model.dart';
import 'package:fitflow/common/models/data_class.dart';
import 'package:fitflow/core/api/api_client.dart';

class CourseLanguageRepository {
  Future<DataClass<CourseLanguageModel>> fetchCourseLanguages() async {
    final Map<String, dynamic> response = await Api.get(
      Apis.getCourseLanguages,
    );

    return DataClass.fromResponse(CourseLanguageModel.fromJson, response);
  }
}
