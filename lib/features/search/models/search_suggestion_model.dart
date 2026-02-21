// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fitflow/common/models/blueprints.dart';

class SearchSuggestionItem extends Model {
  final String type;
  final String text;
  final String slug;
  final String icon;

  SearchSuggestionItem({
    required this.type,
    required this.text,
    required this.slug,
    required this.icon,
  });

  factory SearchSuggestionItem.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionItem(
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'slug': slug,
      'icon': icon,
    };
  }
}

class SearchSuggestionDataModel extends Model {
  final List<SearchSuggestionItem> topCourses;
  final List<SearchSuggestionItem> otherSuggestions;
  final int totalCourses;
  final int totalOther;
  final String query;

  SearchSuggestionDataModel({
    required this.topCourses,
    required this.otherSuggestions,
    required this.totalCourses,
    required this.totalOther,
    required this.query,
  });

  factory SearchSuggestionDataModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionDataModel(
      topCourses: (json['top_courses'] as List<dynamic>?)
              ?.map((item) => SearchSuggestionItem.fromJson(item))
              .toList() ??
          [],
      otherSuggestions: (json['other_suggestions'] as List<dynamic>?)
              ?.map((item) => SearchSuggestionItem.fromJson(item))
              .toList() ??
          [],
      totalCourses: json['total_courses'] ?? 0,
      totalOther: json['total_other'] ?? 0,
      query: json['query'] ?? '',
    );
  }

  List<SearchSuggestionItem> get allSuggestions {
    return [...topCourses, ...otherSuggestions];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'top_courses': topCourses.map((item) => item.toJson()).toList(),
      'other_suggestions':
          otherSuggestions.map((item) => item.toJson()).toList(),
      'total_courses': totalCourses,
      'total_other': totalOther,
      'query': query,
    };
  }
}
