import 'package:fitflow/common/models/blueprints.dart';

class RecentSearchModel extends Model {
  final String searchText;
  final int courseCount;
  final DateTime timestamp;

  RecentSearchModel({
    required this.searchText,
    required this.courseCount,
    required this.timestamp,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      searchText: json['searchText'] as String,
      courseCount: json['courseCount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'searchText': searchText,
      'courseCount': courseCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentSearchModel && other.searchText == searchText;
  }

  @override
  int get hashCode => searchText.hashCode;
}