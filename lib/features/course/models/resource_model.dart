import 'package:fitflow/common/models/blueprints.dart';

class ResourceModel extends Model {
  final String id;
  final String title;
  final String type; // 'link' or 'document'
  final String url;
  final String? lectureId;

   ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    this.lectureId,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'url': url,
      'lectureId': lectureId,
    };
  }
}
