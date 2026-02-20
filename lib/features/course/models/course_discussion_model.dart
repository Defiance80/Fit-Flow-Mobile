import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

/// Simplified user model for discussion feature
class DiscussionUser extends Model {
  final int id;
  final String name;
  final String slug;
  final String email;
  final String? mobile;
  final String? countryCode;
  final String? emailVerifiedAt;
  final String? profile;
  final int isActive;
  final String walletBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DiscussionUser({
    required this.id,
    required this.name,
    required this.slug,
    required this.email,
    this.mobile,
    this.countryCode,
    this.emailVerifiedAt,
    this.profile,
    required this.isActive,
    required this.walletBalance,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory DiscussionUser.fromJson(Map<String, dynamic> json) {
    try {
      return DiscussionUser(
        id: json.require<int>('id'),
        name: json.require<String>('name'),
        slug: json.require<String>('slug'),
        email: json.require<String>('email'),
        mobile: json.optional<String>('mobile'),
        countryCode: json.optional<String>('country_code'),
        emailVerifiedAt: json.optional<String>('email_verified_at'),
        profile: json.optional<String>('profile'),
        isActive: json.require<int>('is_active'),
        walletBalance: json.require<String>('wallet_balance'),
        createdAt: DateTime.parse(json.require<String>('created_at')),
        updatedAt: DateTime.parse(json.require<String>('updated_at')),
        deletedAt: json.optional<String>('deleted_at') != null
            ? DateTime.parse(json.require<String>('deleted_at'))
            : null,
      );
    } catch (e, st) {
      throw Exception('Failed to parse DiscussionUser: $e, $st');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'email': email,
      'mobile': mobile,
      'country_code': countryCode,
      'email_verified_at': emailVerifiedAt,
      'profile': profile,
      'is_active': isActive,
      'wallet_balance': walletBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

/// Model for course discussion with nested replies from API
class CourseDiscussionModel extends Model {
  final int id;
  final int userId;
  final int courseId;
  final String message;
  final int? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String timeAgo;
  final int? replyCount;
  final List<CourseDiscussionModel> replies;
  final DiscussionUser user;

  CourseDiscussionModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.message,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
    this.replyCount,
    required this.replies,
    required this.user,
  });

  factory CourseDiscussionModel.fromJson(Map<String, dynamic> json) {
    try {
      return CourseDiscussionModel(
        id: json.require<int>('id'),
        userId: json.require<int>('user_id'),
        courseId: json.require<int>('course_id'),
        message: json.require<String>('message'),
        parentId: json.optional<int>('parent_id'),
        createdAt: DateTime.parse(json.require<String>('created_at')),
        updatedAt: DateTime.parse(json.require<String>('updated_at')),
        timeAgo: json.require<String>('time_ago'),
        replyCount: json.optional<int>('reply_count'),
        replies: json.optional<List>('replies')?.map((reply) {
              return CourseDiscussionModel.fromJson(reply as Map<String, dynamic>);
            }).toList() ??
            [],
        user: DiscussionUser.fromJson(json.require<Map<String, dynamic>>('user')),
      );
    } catch (e, st) {
      throw Exception('Failed to parse CourseDiscussionModel: $e, $st');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'message': message,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'time_ago': timeAgo,
      'reply_count': replyCount,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'user': user.toJson(),
    };
  }
}
