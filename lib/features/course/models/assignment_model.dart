import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/models/assignment_submission_model.dart';

class AssignmentGroupModel extends Model {
  final List<AssignmentChapter> chapters;
  final List<AssignmentChapter> currentChapter;
  factory AssignmentGroupModel.fromJson(Map<String, dynamic> json) {
    return AssignmentGroupModel(
      chapters: (json['chapters'] as List)
          .map((e) => AssignmentChapter.fromJson(e))
          .toList(),
      currentChapter: (json['current_chapter_assignments'] as List)
          .map((e) => AssignmentChapter.fromJson(e))
          .toList(),
    );
  }

  AssignmentGroupModel({required this.chapters, required this.currentChapter});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class AssignmentModel extends Model {
  final int id;
  int courseId;
  final String title;
  final String description;
  final String instructions;
  final String points;
  final int dueDays;
  final int? maxFileSize;
  final List<String> allowedFileTypes;
  final bool canSkip;
  final bool isActive;
  final CourseInfo course;
  final String createdAt;
  final String createdAtFormatted;
  final String timeAgo;
  final List<AssignmentSubmissionModel> submissions;
  final SubmissionStats submissionStats;
  final String? media;
  final String? mediaExtension;
  final String? mediaUrl;

  AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.points,
    required this.dueDays,
    this.maxFileSize,
    required this.allowedFileTypes,
    required this.canSkip,
    required this.isActive,
    required this.course,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.timeAgo,
    required this.submissions,
    required this.submissionStats,
    this.media,
    this.mediaExtension,
    this.mediaUrl,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final courseInfo = CourseInfo.fromJson(json['course'] ?? {});
    return AssignmentModel(
      id: json['id'] ?? 0,
      courseId: courseInfo.id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      points: json['points']?.toString() ?? '0',
      dueDays: json['due_days'] ?? 0,
      maxFileSize: json['max_file_size'],
      allowedFileTypes: json['allowed_file_types'] != null
          ? List<String>.from(json['allowed_file_types'])
          : [],
      canSkip: json['can_skip'] ?? false,
      isActive: json['is_active'] ?? false,
      course: courseInfo,
      createdAt: json['created_at'] ?? '',
      createdAtFormatted: json['created_at_formatted'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      submissions: json['submissions'] != null
          ? (json['submissions'] as List)
                .map((s) => AssignmentSubmissionModel.fromJson(s))
                .toList()
          : [],
      submissionStats: SubmissionStats.fromJson(json['submission_stats'] ?? {}),
      media: json['media'],
      mediaExtension: json['media_extension'],
      mediaUrl: json['media_url'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'instructions': instructions,
      'points': points,
      'due_days': dueDays,
      'max_file_size': maxFileSize,
      'allowed_file_types': allowedFileTypes,
      'can_skip': canSkip,
      'is_active': isActive,
      'course': course.toJson(),
      'created_at': createdAt,
      'created_at_formatted': createdAtFormatted,
      'time_ago': timeAgo,
      'submissions': submissions.map((s) => s.toJson()).toList(),
      'submission_stats': submissionStats.toJson(),
      'media': media,
      'media_extension': mediaExtension,
      'media_url': mediaUrl,
    };
  }
}

class AssignmentChapter extends Model {
  final int id;
  final String title;
  final String courseName;
  final String courseImage;
  final int courseId;

  final List<AssignmentModel> assignments;

  AssignmentChapter({
    required this.id,
    required this.title,
    required this.assignments,
    required this.courseImage,
    required this.courseName,
    required this.courseId,
  });

  factory AssignmentChapter.fromJson(Map<String, dynamic> json) {
    return AssignmentChapter(
      id: json['chapter_id'] ?? 0,
      title: json['chapter_title'] ?? '',
      courseImage: json['course_image'] ?? "",
      courseName: json['course_name'] ?? '',
      courseId: json['course_id'],
      assignments: (json['assignments'] as List).map((e) {
        return AssignmentModel.fromJson(e)..courseId = json['course_id'];
      }).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

class CourseInfo extends Model {
  final int id;
  final String title;

  CourseInfo({required this.id, required this.title});

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(id: json['id'] ?? 0, title: json['title'] ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

class SubmissionStats extends Model {
  final int totalSubmissions;
  final int acceptedSubmissions;
  final int rejectedSubmissions;
  final int pendingSubmissions;
  final String? latestStatus;
  final bool hasSubmissions;

  SubmissionStats({
    required this.totalSubmissions,
    required this.acceptedSubmissions,
    required this.rejectedSubmissions,
    required this.pendingSubmissions,
    this.latestStatus,
    required this.hasSubmissions,
  });

  factory SubmissionStats.fromJson(Map<String, dynamic> json) {
    return SubmissionStats(
      totalSubmissions: json['total_submissions'] ?? 0,
      acceptedSubmissions: json['accepted_submissions'] ?? 0,
      rejectedSubmissions: json['rejected_submissions'] ?? 0,
      pendingSubmissions: json['pending_submissions'] ?? 0,
      latestStatus: json['latest_status'],
      hasSubmissions: json['has_submissions'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'total_submissions': totalSubmissions,
      'accepted_submissions': acceptedSubmissions,
      'rejected_submissions': rejectedSubmissions,
      'pending_submissions': pendingSubmissions,
      'latest_status': latestStatus,
      'has_submissions': hasSubmissions,
    };
  }
}




///fail state
/**
 * 
 *  AssignmentSubmissionModel(
          id: 1,
          submittedFile: "https://example.com/uploads/assignment1.pdf",
          fileName: "assignment1.pdf",
          fileSize: "1.2 MB",
          fileType: "pdf",
          status: SubmissionStatus.rejected,
          statusLabel: "Rejected",
          feedback:
              "The submitted file did not meet the required formatting guidelines.",
          grade: "0",
          comment: "Please follow the assignment template and resubmit.",
          submittedAt: "2025-10-10T14:32:00Z",
          submittedAtFormatted: "October 10, 2025 at 2:32 PM",
          timeAgo: "6 days ago",
          updatedAt: "2025-10-11T10:00:00Z",
          canResubmit: true,
          canEdit: true,
          canDelete: false,
        )
 * 
 */