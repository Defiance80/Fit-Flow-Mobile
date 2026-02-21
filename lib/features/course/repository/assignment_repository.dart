import 'dart:io';

import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/features/course/models/assignment_model.dart';

class AssignmentRepository {
  Future<AssignmentGroupModel> fetchAssignmentSubmissionHistory({
    required int courseId,
  }) async {
    try {
      final Map<String, dynamic> parameters = {ApiParams.courseId: courseId};

      final Map<String, dynamic> response = await Api.get(
        Apis.getAssignments,
        data: parameters,
      );

      return AssignmentGroupModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> submitAssignment({
    required int assignmentId,
    required List<String> files,
    required String comment,
  }) async {
    try {
      final Map<String, dynamic> response = await Api.postMultipart(
        Apis.submitAssignment,
        data: {'assignment_id': assignmentId.toString(), 'comment': comment},
        files: files.map((path) => File(path)).toList(),
        fileKey: 'files',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> updateSubmission({
    required int submissionId,
    required List<String> files,
    required String comment,
  }) async {
    try {
      final Map<String, dynamic> response = await Api.putMultipart(
        Apis.updateAssignmentSubmission,
        data: {'submission_id': submissionId.toString(), 'comment': comment},
        files: files.map((path) => File(path)).toList(),
        fileKey: 'files[]',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }


  Future<Map<dynamic, dynamic>> resubmitAssignment({
    required int assignmentId,
    required List<String> files,
    required String comment,
  }) async {
    return await submitAssignment(
      assignmentId: assignmentId,
      files: files,
      comment: comment,
    );
  }
}
