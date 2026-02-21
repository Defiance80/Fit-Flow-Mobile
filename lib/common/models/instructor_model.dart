import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';

class InstructorModel extends Model {
  final int id;
  final int userId;
  final String type;
  final String status;
  final String name;
  final String email;
  final String slug;
  final String profile;
  final String? qualification;
  final int? yearsOfExperience;
  final String? skills;
  final String? aboutMe;
  final String? previewVideo;
  final String? teamName;
  final String? teamLogo;
  final num averageRating;
  final int totalRatings;
  final int reviewCount;
  final int studentEnrolledCount;
  final int activeCoursesCount;
  final int publishedCoursesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  InstructorModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.name,
    required this.email,
    required this.slug,
    required this.profile,
    this.qualification,
    this.yearsOfExperience,
    this.skills,
    this.aboutMe,
    this.previewVideo,
    this.teamName,
    this.teamLogo,
    required this.averageRating,
    required this.totalRatings,
    required this.reviewCount,
    required this.studentEnrolledCount,
    required this.activeCoursesCount,
    required this.publishedCoursesCount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory InstructorModel.fromMap(Map<String, dynamic> json) {
    return InstructorModel(
      id: json.require<int>('id'),
      userId: json.require<int>('user_id'),
      type: json.require<String>('type'),
      status: json.require<String>('status'),
      name: json.require<String>('name'),
      email: json.require<String>('email'),
      slug: json.require<String>('slug'),
      profile: json.require<String>('profile'),
      qualification: json.optional<String?>('qualification'),
      yearsOfExperience: json.optional<int?>('years_of_experience'),
      skills: json.optional<String?>('skills'),
      aboutMe: json.optional<String?>('about_me'),
      previewVideo: json.optional<String?>('preview_video'),
      teamName: json.optional<String?>('team_name'),
      teamLogo: json.optional<String?>('team_logo'),
      averageRating: json.require<num>('average_rating').toDouble(),
      totalRatings: json.require<int>('total_ratings'),
      reviewCount: json.require<int>('review_count'),
      studentEnrolledCount: json.require<int>('student_enrolled_count'),
      activeCoursesCount: json.require<int>('active_courses_count'),
      publishedCoursesCount: json.require<int>('published_courses_count'),
      createdAt: json.optional<String?>('created_at') != null
          ? DateTime.tryParse(json.optional<String>('created_at')!)
          : null,
      updatedAt: json.optional<String?>('updated_at') != null
          ? DateTime.tryParse(json.optional<String>('updated_at')!)
          : null,
      deletedAt: json.optional<String?>('deleted_at') != null
          ? DateTime.tryParse(json.optional<String>('deleted_at')!)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class InstructorRatingModel extends Model {
  final int id;
  final num rating;
  final String review;
  final String userName;
  final String userProfile;
  final String createdAt;

  InstructorRatingModel({
    required this.id,
    required this.rating,
    required this.review,
    required this.userName,
    required this.userProfile,
    required this.createdAt,
  });

  factory InstructorRatingModel.fromMap(Map<String, dynamic> json) {
    return InstructorRatingModel(
      id: json.require<int>('id'),
      rating: json.require<num>('rating'),
      review: json.require<String>('review'),
      userName: json.require<String>('user_name'),
      userProfile: json.require<String>('user_profile'),
      createdAt: json.require<String>('created_at'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'review': review,
      'user_name': userName,
      'user_profile': userProfile,
      'created_at': createdAt,
    };
  }
}
