class CourseCompletionData {
  final bool allCurriculumCompleted;
  final bool allAssignmentsSubmitted;
  final String certificate;
  final bool certificateFeePaid;
  final num? certificateFee;

  CourseCompletionData({
    required this.allCurriculumCompleted,
    required this.allAssignmentsSubmitted,
    required this.certificate,
    required this.certificateFeePaid,
    this.certificateFee,
  });

  factory CourseCompletionData.fromJson(Map<String, dynamic> json) {
    return CourseCompletionData(
      allCurriculumCompleted: json['all_curriculum_completed'] ?? false,
      allAssignmentsSubmitted: json['all_assignments_submitted'] ?? false,
      certificate: json['certificate'] ?? '',
      certificateFeePaid: json['certificate_fee_paid'] ?? false,
      certificateFee: json['certificate_fee'] is String
          ? num.parse(json['certificate_fee'])
          : json['certificate_fee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all_curriculum_completed': allCurriculumCompleted,
      'all_assignments_submitted': allAssignmentsSubmitted,
      'certificate': certificate,
      'certificate_fee_paid': certificateFeePaid,
      'certificate_fee': certificateFee,
    };
  }
}
