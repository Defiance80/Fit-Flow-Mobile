import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/blueprints.dart';

class AssignmentSubmissionModel extends Model {
  final int id;
  final String? submittedFile;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final SubmissionStatus status;
  final String statusLabel;
  final String? feedback;
  final String? grade;
  final String? comment;
  final String submittedAt;
  final String submittedAtFormatted;
  final String timeAgo;
  final String updatedAt;
  final bool canResubmit;
  final bool canEdit;
  final bool canDelete;

  AssignmentSubmissionModel({
    required this.id,
    this.submittedFile,
    this.fileName,
    this.fileSize,
    this.fileType,
    required this.status,
    required this.statusLabel,
    this.feedback,
    this.grade,
    this.comment,
    required this.submittedAt,
    required this.submittedAtFormatted,
    required this.timeAgo,
    required this.updatedAt,
    required this.canResubmit,
    required this.canEdit,
    required this.canDelete,
  });

  AssignmentSubmissionModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      submittedFile = json['submitted_file'],
      fileName = json['file_name'],
      fileSize = json['file_size'],
      fileType = json['file_type'],
      status = _parseStatus(json['status']),
      statusLabel = json['status_label'],
      feedback = json['feedback'],
      grade = json['grade'],
      comment = json['comment'],
      submittedAt = json['submitted_at'],
      submittedAtFormatted = json['submitted_at_formatted'],
      timeAgo = json['time_ago'],
      updatedAt = json['updated_at'],
      canResubmit = json['can_resubmit'] ?? false,
      canEdit = json['can_edit'] ?? false,
      canDelete = json['can_delete'] ?? false;

  static SubmissionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return SubmissionStatus.submitted;
      case 'accepted':
        return SubmissionStatus.accepted;
      case 'rejected':
        return SubmissionStatus.rejected;
      default:
        return SubmissionStatus.submitted;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submitted_file': submittedFile,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'status': status.name,
      'status_label': statusLabel,
      'feedback': feedback,
      'grade': grade,
      'comment': comment,
      'submitted_at': submittedAt,
      'submitted_at_formatted': submittedAtFormatted,
      'time_ago': timeAgo,
      'updated_at': updatedAt,
      'can_resubmit': canResubmit,
      'can_edit': canEdit,
      'can_delete': canDelete,
    };
  }
}
