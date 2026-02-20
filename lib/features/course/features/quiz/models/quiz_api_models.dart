import 'package:elms/common/models/blueprints.dart';

/// Model for quiz attempt when starting a quiz
class QuizAttemptModel extends Model {
  final int id;
  final int userId;
  final String courseChapterQuizId;
  final int totalTime;
  final int timeTaken;
  final String score;
  final String createdAt;
  final String updatedAt;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.courseChapterQuizId,
    required this.totalTime,
    required this.timeTaken,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      courseChapterQuizId: json['course_chapter_quiz_id']?.toString() ?? '',
      totalTime: (json['total_time'] as num?)?.toInt() ?? 0,
      timeTaken: (json['time_taken'] as num?)?.toInt() ?? 0,
      score: json['score']?.toString() ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_chapter_quiz_id': courseChapterQuizId,
      'total_time': totalTime,
      'time_taken': timeTaken,
      'score': score,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for quiz answer submission response
class QuizAnswerModel extends Model {
  final int id;
  final int userId;
  final String quizQuestionId;
  final String userQuizAttemptId;
  final String quizOptionId;
  final String createdAt;
  final String updatedAt;

  QuizAnswerModel({
    required this.id,
    required this.userId,
    required this.quizQuestionId,
    required this.userQuizAttemptId,
    required this.quizOptionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      quizQuestionId: json['quiz_question_id']?.toString() ?? '',
      userQuizAttemptId: json['user_quiz_attempt_id']?.toString() ?? '',
      quizOptionId: json['quiz_option_id']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_question_id': quizQuestionId,
      'user_quiz_attempt_id': userQuizAttemptId,
      'quiz_option_id': quizOptionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for quiz questions
class QuizQuestionModel extends Model {
  final int id;
  final String question;
  final String? description;
  final String questionType;
  final int marks;
  final List<QuizOptionModel> options;
  final String? selectedOptionId;

  QuizQuestionModel({
    required this.id,
    required this.question,
    this.description,
    required this.questionType,
    required this.marks,
    required this.options,
    this.selectedOptionId,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      question: json['question'] ?? '',
      description: json['description'],
      questionType: json['question_type'] ?? 'single_choice',
      marks: (json['marks'] as num?)?.toInt() ?? 0,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => QuizOptionModel.fromJson(option))
              .toList()
          : [],
      selectedOptionId: json['selected_option_id']?.toString(),
    );
  }

  QuizQuestionModel copyWith({String? selectedOptionId}) {
    return QuizQuestionModel(
      id: id,
      question: question,
      description: description,
      questionType: questionType,
      marks: marks,
      options: options,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'description': description,
      'question_type': questionType,
      'marks': marks,
      'options': options.map((option) => option.toJson()).toList(),
      'selected_option_id': selectedOptionId,
    };
  }
}

/// Model for quiz options
class QuizOptionModel extends Model {
  final int id;
  final String option;
  final bool isCorrect;

  QuizOptionModel({
    required this.id,
    required this.option,
    required this.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      option: json['option'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option': option,
      'is_correct': isCorrect,
    };
  }
}

/// Model for finish quiz response
class QuizFinishResponseModel extends Model {
  final int score;
  final int totalQuestions;
  final int correctAnswers;

  QuizFinishResponseModel({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory QuizFinishResponseModel.fromJson(Map<String, dynamic> json) {
    return QuizFinishResponseModel(
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
    };
  }
}

/// Model for quiz summary
class QuizSummaryModel extends Model {
  final int attemptId;
  final String score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int timeTaken;
  final String percentage;
  final bool isPassed;

  QuizSummaryModel({
    required this.attemptId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.timeTaken,
    required this.percentage,
    required this.isPassed,
  });

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuizSummaryModel(
      attemptId: json['attempt_id'] ?? 0,
      score: json['score']?.toString() ?? '0',
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      incorrectAnswers: json['incorrect_answers'] ?? 0,
      timeTaken: json['time_taken'] ?? 0,
      percentage: json['percentage']?.toString() ?? '0',
      isPassed: json['is_passed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'time_taken': timeTaken,
      'percentage': percentage,
      'is_passed': isPassed,
    };
  }
}

/// Model for quiz info (metadata about the quiz)
class QuizInfoModel extends Model {
  final int id;
  final String title;
  final String? description;
  final int duration; // in minutes
  final int totalQuestions;
  final int totalMarks;
  final int passingMarks;
  final List<QuizQuestionModel> questions;

  QuizInfoModel({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.totalQuestions,
    required this.totalMarks,
    required this.passingMarks,
    required this.questions,
  });

  factory QuizInfoModel.fromJson(Map<String, dynamic> json) {
    return QuizInfoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      totalMarks: (json['total_marks'] as num?)?.toInt() ?? 0,
      passingMarks: (json['passing_marks'] as num?)?.toInt() ?? 0,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((question) => QuizQuestionModel.fromJson(question))
              .toList()
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'total_questions': totalQuestions,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
