import 'package:fitflow/common/models/data_class.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/features/home/models/slider_model.dart';

class SliderRepository {
  Future<DataClass<SliderModel>> fetchSliders() async {
    return DataClass<SliderModel>.fromResponse(
      SliderModel.fromJson,
      await Api.get(Apis.slider),
    );
  }
}
