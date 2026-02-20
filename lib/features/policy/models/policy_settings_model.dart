import 'package:elms/common/models/blueprints.dart';

class PolicySettingsModel extends Model {
  final String pageContent;

  PolicySettingsModel({
    required this.pageContent,
  });

  factory PolicySettingsModel.fromJson(Map<String, dynamic> json) {
    return PolicySettingsModel(
      pageContent: json['page_content'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'page_content': pageContent,
    };
  }
}
