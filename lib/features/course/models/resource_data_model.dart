// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fitflow/common/enums.dart';

class CourseResourcesModel {
  final AllResources allResources;
  final List<ResourceModel> currentLectureResources;

  CourseResourcesModel({
    required this.allResources,
    required this.currentLectureResources,
  });

  factory CourseResourcesModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    final allResources = (data['all_resources'] ?? {}) as Map<String, dynamic>;
    final currentLectureResources =
        (data['current_lecture_resources'] as List? ?? [])
            .map((e) => ResourceModel.fromJson(e as Map<String, dynamic>))
            .toList();

    // parse chapters
    final chapters = (allResources['chapters'] as List? ?? [])
        .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // parse lectures and merge into matching chapters
    final lectures = (allResources['lectures'] as List? ?? [])
        .map((e) => LectureModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (var chapter in chapters) {
      final chapterLectures =
          lectures.where((l) => l.chapterId == chapter.chapterId).toList();
      chapter.lectureResources.addAll(chapterLectures);
    }

    return CourseResourcesModel(
      allResources: AllResources(chapters: chapters),
      currentLectureResources: currentLectureResources,
    );
  }
}

class AllResources {
  final List<ChapterModel> chapters;

  AllResources({required this.chapters});
}

class ChapterModel {
  final int chapterId;
  final String chapterTitle;
  final List<ResourceModel> resources;
  final List<LectureModel> lectureResources;

  ChapterModel({
    required this.chapterId,
    required this.chapterTitle,
    required this.resources,
    List<LectureModel>? lectureResources,
  }) : lectureResources = lectureResources ?? [];

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapterId: json['chapter_id'],
      chapterTitle: json['chapter_title'] ?? '',
      resources: (json['resources'] as List? ?? [])
          .map((e) => ResourceModel.fromJson(e))
          .toList(),
      lectureResources: (json['lecture_resources'] as List? ?? [])
          .map((e) => LectureModel.fromJson(e))
          .toList(),
    );
  }
}

class LectureModel {
  final int id;
  final String title;
  final int chapterId;
  final String chapterTitle;
  final int? lectureOrder;
  final List<ResourceModel> resources;

  LectureModel({
    required this.id,
    required this.title,
    required this.chapterId,
    required this.chapterTitle,
    this.lectureOrder,
    required this.resources,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'],
      title: json['title'] ?? '',
      chapterId: json['chapter_id'],
      chapterTitle: json['chapter_title'] ?? '',
      lectureOrder: json['lecture_order'],
      resources: (json['resources'] as List? ?? [])
          .map((e) => ResourceModel.fromJson(e))
          .toList(),
    );
  }
}

class ResourceModel {
  final int? id;
  final String? title;
  final ResourceType type;
  final String? fileUrl;
  final String? externalUrl;
  final String? fileName;
  final String? fileExtension;
  final String? description;
  final String? resourceType;
  final String? createdAt;

  ResourceModel({
    this.id,
    this.title,
    required this.type,
    this.fileUrl,
    this.externalUrl,
    this.fileName,
    this.fileExtension,
    this.description,
    this.resourceType,
    this.createdAt,
  });

  String get getTitle =>
      (type == ResourceType.externalLink ? title : fileName) ?? '';

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] ?? '';
    final resourceType = typeString == 'external_link'
        ? ResourceType.externalLink
        : ResourceType.download;

    return ResourceModel(
      id: json['id'],
      title: json['title'],
      type: resourceType,
      fileUrl: json['file_url'],
      externalUrl: json['external_url'],
      fileName: json['file_name'],
      fileExtension: json['file_extension'],
      description: json['description'],
      resourceType: json['resource_type'],
      createdAt: json['created_at'],
    );
  }

  @override
  String toString() {
    return 'ResourceModel(id: $id, title: $title, type: $type, fileUrl: $fileUrl, externalUrl: $externalUrl, fileName: $fileName, fileExtension: $fileExtension, description: $description, resourceType: $resourceType, createdAt: $createdAt)';
  }
}
