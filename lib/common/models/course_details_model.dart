import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/models/instructor_model.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';

class CourseInstructorModel {
  final int id;
  final int? instructorId;
  final String name;
  final String slug;
  final String email;
  final String? avatar;
  final String? aboutMe;
  final String? qualification;
  final String? skills;
  final String? previewVideo;
  final dynamic socialMedia;
  final dynamic reviews;

  CourseInstructorModel({
    required this.id,
    this.instructorId,
    required this.name,
    required this.slug,
    required this.email,
    this.avatar,
    this.aboutMe,
    this.qualification,
    this.skills,
    this.previewVideo,
    this.socialMedia,
    this.reviews,
  });

  factory CourseInstructorModel.fromJson(Map<String, dynamic> json) {
    return CourseInstructorModel(
      id: json.require<int>('id'),
      instructorId: json.optional<int?>('instructor_id'),
      name: json.require<String>('name'),
      slug: json.require<String>('slug'),
      email: json.require<String>('email'),
      avatar: json.optional<String?>('avatar'),
      aboutMe: json.optional<String?>('about_me'),
      qualification: json.optional<String?>('qualification'),
      skills: json.optional<String?>('skills'),
      previewVideo: json.optional<String?>('preview_video'),
      socialMedia: json.optional('social_media'),
      reviews: json.optional('reviews'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'email': email,
    'avatar': avatar,
    'about_me': aboutMe,
    'qualification': qualification,
    'skills': skills,
    'preview_video': previewVideo,
    'social_media': socialMedia,
    'reviews': reviews,
  };

  // Helper method to convert to InstructorModel for widgets that need it
  // Note: This creates a simplified InstructorModel with default values for fields
  // that are not available in CourseInstructorModel
  InstructorModel toInstructorModel() {
    return InstructorModel(
      id: id,
      userId: 0, // Not available in CourseInstructorModel
      type: 'individual', // Default value
      status: 'active', // Default value
      name: name,
      email: email,
      slug: slug,
      profile: avatar ?? '',
      qualification: qualification,
      skills: skills,
      aboutMe: aboutMe,
      previewVideo: previewVideo,
      averageRating: 0.0, // Not available in CourseInstructorModel
      totalRatings: 0, // Not available in CourseInstructorModel
      reviewCount: 0, // Not available in CourseInstructorModel
      studentEnrolledCount: 0, // Not available in CourseInstructorModel
      activeCoursesCount: 0, // Not available in CourseInstructorModel
      publishedCoursesCount: 0, // Not available in CourseInstructorModel
    );
  }
}

class CourseDetailsModel extends CourseModel {
  final String? description;
  final bool isPurchased;
  final List<CourseLearning> learnings;
  final List<CourseRequirement> requirements;
  final List<CourseReview> reviews;
  final List<CourseTag> tags;
  final String language;
  final CourseInstructorModel? instructor;
  final List<dynamic> chapters;
  final int chapterCount;
  final int lectureCount;
  final int totalDuration;
  final String totalDurationFormatted;
  final bool sequentialAccess;
  final CurrentCurriculumModel? currentCurriculum;
  final List<PreviewVideoModel> previewVideos;

  CourseDetailsModel({
    required super.id,
    super.slug,
    required super.image,
    required super.categoryId,
    required super.categoryName,
    required super.ratings,
    required super.averageRating,
    required super.title,
    required super.shortDescription,
    required super.authorName,
    required super.price,
    super.discountedPrice,
    required super.discountPercentage,
    required super.isWishlisted,
    required super.isEnrolled,
    required super.level,
    super.totalChapters,
    super.completedChapters,
    super.totalCurriculumItems,
    super.completedCurriculumItems,
    super.progressPercentage,
    super.progressStatus,
    required super.courseType,
    this.description,
    required this.isPurchased,
    required this.learnings,
    required this.requirements,
    required this.reviews,
    required this.tags,
    required this.language,
    this.instructor,
    required this.chapters,
    required this.chapterCount,
    required this.lectureCount,
    required this.totalDuration,
    required this.totalDurationFormatted,
    required this.currentCurriculum,
    required this.sequentialAccess,
    required this.previewVideos,
  });

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailsModel(
      id: json.require<int>('id'),
      slug: json.optional<String?>('slug'),
      image: json.require<String?>('image') ?? '',
      categoryId: json.require<int>('category_id'),
      categoryName: json.require<String>('category_name'),
      ratings: json.require<int>('ratings'),
      averageRating: json.require<num>('average_rating').toDouble(),
      title: json.require<String>('title'),
      shortDescription: json.require<String?>('short_description') ?? "",
      authorName: json.require<String>('author_name'),
      price: json.require<num>('price').toDouble(),
      discountedPrice: json.optional<num>('discounted_price')?.toDouble(),
      discountPercentage: json.optional<num>('discount_percentage') ?? 0,
      isWishlisted: json.optional<bool>('is_wishlisted') ?? false,
      isEnrolled: json.optional<bool>('is_enrolled') ?? false,
      level: json.optional<String>('level') ?? '',
      totalChapters: json.optional<int>('total_chapters'),
      completedChapters: json.optional<int>('completed_chapters'),
      totalCurriculumItems: json.optional<int>('total_curriculum_items'),
      completedCurriculumItems: json.optional<int>(
        'completed_curriculum_items',
      ),
      progressPercentage: json.optional<num>('progress_percentage')?.toDouble(),
      progressStatus: json.optional<String>('progress_status'),
      courseType: json.require<String>('course_type'),
      description: json.optional<String?>('description'),
      isPurchased: json.require<bool>('is_purchased'),
      learnings: (json.optional<List>('learnings') ?? [])
          .map((e) => CourseLearning.fromJson(e))
          .toList(),
      requirements: (json.optional<List>('requirements') ?? [])
          .map((e) => CourseRequirement.fromJson(e))
          .toList(),
      reviews: (json.optional<List>('reviews') ?? [])
          .map((e) => CourseReview.fromJson(e))
          .toList(),
      tags: (json.optional<List>('tags') ?? [])
          .map((e) => CourseTag.fromJson(e))
          .toList(),
      language: json.optional<String>('language') ?? 'fsq',
      instructor: json.optional<Map<String, dynamic>?>('instructor') != null
          ? CourseInstructorModel.fromJson(
              json.require<Map<String, dynamic>>('instructor'),
            )
          : null,
      chapters: json.optional<List>('chapters') ?? [],
      chapterCount: json.optional<int>('chapter_count') ?? 0,
      lectureCount: json.optional<int>('lecture_count') ?? 0,
      totalDuration: json.optional<int>('total_duration') ?? 0,
      totalDurationFormatted:
          json.optional<String>('total_duration_formatted') ?? '0s',
      sequentialAccess: json.require<bool>('sequential_access'),
      currentCurriculum:
          json.optional<Map<String, dynamic>?>('current_curriculum') != null
          ? CurrentCurriculumModel.fromJson(
              json.require<Map<String, dynamic>>('current_curriculum'),
            )
          : null,
      previewVideos: (json.optional<List>('preview_videos') ?? [])
          .map((e) => PreviewVideoModel.fromJson(e))
          .toList(),
    );
  }

  factory CourseDetailsModel.fromCourseModel(CourseModel course) {
    return CourseDetailsModel(
      id: course.id,
      slug: course.slug,
      image: course.image,
      categoryId: course.categoryId,
      categoryName: course.categoryName,
      ratings: course.ratings,
      averageRating: course.averageRating,
      title: course.title,
      shortDescription: course.shortDescription,
      authorName: course.authorName,
      price: course.price,
      discountedPrice: course.discountedPrice,
      discountPercentage: course.discountPercentage,
      isWishlisted: course.isWishlisted,
      isEnrolled: course.isEnrolled,
      level: course.level,
      totalChapters: course.totalChapters,
      completedChapters: course.completedChapters,
      totalCurriculumItems: course.totalCurriculumItems,
      completedCurriculumItems: course.completedCurriculumItems,
      progressPercentage: course.progressPercentage,
      progressStatus: course.progressStatus,
      courseType: course.courseType,
      isPurchased: course.isEnrolled,
      learnings: const [],
      requirements: const [],
      reviews: const [],
      tags: const [],
      language: 'English',
      chapters: const [],
      chapterCount: 0,
      lectureCount: 0,
      totalDuration: 0,
      totalDurationFormatted: '0s',
      sequentialAccess: true,
      currentCurriculum: null,
      previewVideos: const [],
    );
  }

  CourseDetailsModel mergeWithApiData(CourseDetailsModel apiData) {
    return CourseDetailsModel(
      id: id,
      slug: slug,
      image: image,
      categoryId: categoryId,
      categoryName: categoryName,
      ratings: ratings,
      averageRating: averageRating,
      title: title,
      shortDescription: shortDescription,
      authorName: authorName,
      price: price,
      discountedPrice: discountedPrice,
      discountPercentage: discountPercentage,
      isWishlisted: isWishlisted,
      isEnrolled: isEnrolled,
      level: level,
      courseType: courseType,
      totalChapters: apiData.totalChapters,
      completedChapters: apiData.completedChapters,
      totalCurriculumItems: apiData.totalCurriculumItems,
      completedCurriculumItems: apiData.completedCurriculumItems,
      progressPercentage: apiData.progressPercentage,
      progressStatus: apiData.progressStatus,
      description: apiData.description,
      isPurchased: apiData.isPurchased,
      learnings: apiData.learnings,
      requirements: apiData.requirements,
      reviews: apiData.reviews,
      tags: apiData.tags,
      language: apiData.language,
      instructor: apiData.instructor,
      chapters: apiData.chapters,
      chapterCount: apiData.chapterCount,
      lectureCount: apiData.lectureCount,
      totalDuration: apiData.totalDuration,
      totalDurationFormatted: apiData.totalDurationFormatted,
      sequentialAccess: apiData.sequentialAccess,
      currentCurriculum: apiData.currentCurriculum,
      previewVideos: apiData.previewVideos,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> baseJson = super.toJson();
    baseJson.addAll({
      'description': description,
      'is_purchased': isPurchased,
      'learnings': learnings.map((e) => e.toJson()).toList(),
      'requirements': requirements.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'language': language,
      'instructor': instructor?.toJson(),
      'chapters': chapters,
      'chapter_count': chapterCount,
      'lecture_count': lectureCount,
      'total_duration': totalDuration,
      'total_duration_formatted': totalDurationFormatted,
      'preview_videos': previewVideos.map((e) => e.toJson()).toList(),
    });
    return baseJson;
  }
}

class CourseLearning {
  final int id;
  final int courseId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CourseLearning({
    required this.id,
    required this.courseId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CourseLearning.fromJson(Map<String, dynamic> json) {
    return CourseLearning(
      id: json.require<int>('id'),
      courseId: json.require<int>('course_id'),
      title: json.require<String>('title'),
      createdAt: DateTime.parse(json.require<String>('created_at')),
      updatedAt: DateTime.parse(json.require<String>('updated_at')),
      deletedAt: json.optional<String?>('deleted_at') != null
          ? DateTime.parse(json.require<String>('deleted_at'))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}

class CourseRequirement {
  final int id;
  final int courseId;
  final String requirement;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CourseRequirement({
    required this.id,
    required this.courseId,
    required this.requirement,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CourseRequirement.fromJson(Map<String, dynamic> json) {
    return CourseRequirement(
      id: json.require<int>('id'),
      courseId: json.require<int>('course_id'),
      requirement: json.require<String>('requirement'),
      createdAt: DateTime.parse(json.require<String>('created_at')),
      updatedAt: DateTime.parse(json.require<String>('updated_at')),
      deletedAt: json.optional<String?>('deleted_at') != null
          ? DateTime.parse(json.require<String>('deleted_at'))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'requirement': requirement,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}

class CourseReview {
  final Map<String, dynamic> data;

  CourseReview({required this.data});

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(data: json);
  }

  Map<String, dynamic> toJson() => data;
}

class CourseTag {
  final int id;
  final String tag;
  final String slug;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final CourseTagPivot pivot;

  CourseTag({
    required this.id,
    required this.tag,
    required this.slug,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pivot,
  });

  factory CourseTag.fromJson(Map<String, dynamic> json) {
    return CourseTag(
      id: json.require<int>('id'),
      tag: json.require<String>('tag'),
      slug: json.require<String>('slug'),
      isActive: json.require<int>('is_active'),
      createdAt: DateTime.parse(json.require<String>('created_at')),
      updatedAt: DateTime.parse(json.require<String>('updated_at')),
      deletedAt: json.optional<String?>('deleted_at') != null
          ? DateTime.parse(json.require<String>('deleted_at'))
          : null,
      pivot: CourseTagPivot.fromJson(
        json.require<Map<String, dynamic>>('pivot'),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tag': tag,
    'slug': slug,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'pivot': pivot.toJson(),
  };
}

class CourseTagPivot {
  final int courseId;
  final int tagId;

  CourseTagPivot({required this.courseId, required this.tagId});

  factory CourseTagPivot.fromJson(Map<String, dynamic> json) {
    return CourseTagPivot(
      courseId: json.require<int>('course_id'),
      tagId: json.require<int>('tag_id'),
    );
  }

  Map<String, dynamic> toJson() => {'course_id': courseId, 'tag_id': tagId};
}

class CurrentCurriculumModel {
  final int id;
  final String curriculumName;
  final int modelId;
  final String modelType;
  final int chapterId;
  final DateTime? completedAt;
  final String? completedAtHuman;

  CurrentCurriculumModel({
    required this.id,
    required this.curriculumName,
    required this.modelId,
    required this.modelType,
    required this.chapterId,
    this.completedAt,
    this.completedAtHuman,
  });

  factory CurrentCurriculumModel.fromJson(Map<String, dynamic> json) {
    return CurrentCurriculumModel(
      id: json.require<int>('id'),
      curriculumName: json.require<String>('curriculum_name'),
      modelId: json.require<int>('model_id'),
      modelType: json.require<String>('model_type'),
      chapterId: json.require<int>('chapter_id'),
      completedAt: json.optional<String?>('completed_at') != null
          ? DateTime.parse(json.require<String>('completed_at'))
          : null,
      completedAtHuman: json.optional<String?>('completed_at_human'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'curriculum_name': curriculumName,
    'model_id': modelId,
    'model_type': modelType,
    'chapter_id': chapterId,
    'completed_at': completedAt?.toIso8601String(),
    'completed_at_human': completedAtHuman,
  };
}

class PreviewVideoModel {
  final String title;
  final String thumbnail;
  final String video;
  final String type;

  PreviewVideoModel({
    required this.title,
    required this.thumbnail,
    required this.video,
    required this.type,
  });

  factory PreviewVideoModel.fromJson(Map<String, dynamic> json) {
    return PreviewVideoModel(
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      video: json['video'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'video': video,
      'type': type,
    };
  }
}
