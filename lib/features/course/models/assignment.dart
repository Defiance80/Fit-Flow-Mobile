import 'package:fitflow/common/models/blueprints.dart';
import 'package:flutter/material.dart';

class Assignment extends Model {
  final int id;
  final String number;
  final String title;
  final String description;
  final String dueDate;
  final String points;
  final bool isSubmitted;
  final String? submissionStatus;
  final Color? statusColor;
  final String? statusMessage;
  final String? submittedFile;
  final bool showResubmitButton;

  Assignment({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.points,
    required this.isSubmitted,
    this.submissionStatus,
    this.statusColor,
    this.statusMessage,
    this.submittedFile,
    this.showResubmitButton = false,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'points': points, 
      'isSubmitted': isSubmitted,
      'submissionStatus': submissionStatus,
      'statusColor': statusColor,
      'statusMessage': statusMessage,
      'submittedFile': submittedFile,
      'showResubmitButton': showResubmitButton,
    };

  }
}
