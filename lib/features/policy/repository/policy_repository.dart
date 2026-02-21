import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/features/policy/models/policy_settings_model.dart';

class PolicyRepository {
  Future<PolicySettingsModel> fetchPolicySettings({required String type}) async {
    final Map<String, dynamic> response = await Api.get(
      Apis.pages,
      data: {
        ApiParams.type: type,
      },
    );

    final List<dynamic> dataList = response[ApiParams.data] as List<dynamic>;
    if (dataList.isEmpty) {
      throw Exception('No data found');
    }

    return PolicySettingsModel.fromJson(
        dataList.first as Map<String, dynamic>);
  }
}
