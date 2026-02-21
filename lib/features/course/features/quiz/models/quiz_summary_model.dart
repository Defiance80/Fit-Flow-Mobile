import 'package:fitflow/common/models/blueprints.dart';

class QuizSummaryModel extends Model {
  final int quizId;
  final String quizTitle;
  final int attemptId;
  final int totalPoints;
  final int earnedPoints;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeTaken;
  final String attemptedAt;
  final List<QuizSummaryQuestion> questions;

  QuizSummaryModel({
    required this.quizId,
    required this.quizTitle,
    required this.attemptId,
    required this.totalPoints,
    required this.earnedPoints,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTaken,
    required this.attemptedAt,
    required this.questions,
  });

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuizSummaryModel(
      quizId: (json['quiz_id'] as num?)?.toInt() ?? 0,
      quizTitle: json['quiz_title'] as String? ?? '',
      attemptId: (json['attempt_id'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      earnedPoints: (json['earned_points'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (json['wrong_answers'] as num?)?.toInt() ?? 0,
      timeTaken: (json['time_taken'] as num?)?.toInt() ?? 0,
      attemptedAt: json['attempted_at'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizSummaryQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'attempt_id': attemptId,
      'total_points': totalPoints,
      'earned_points': earnedPoints,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'time_taken': timeTaken,
      'attempted_at': attemptedAt,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuizSummaryQuestion extends Model {
  final String questionNumber;
  final int questionId;
  final String question;
  final String? yourAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String points;

  QuizSummaryQuestion({
    required this.questionNumber,
    required this.questionId,
    required this.question,
    this.yourAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.points,
  });

  factory QuizSummaryQuestion.fromJson(Map<String, dynamic> json) {
    return QuizSummaryQuestion(
      questionNumber: json['question_number'] as String? ?? '',
      questionId: (json['question_id'] as num?)?.toInt() ?? 0,
      question: json['question'] as String? ?? '',
      yourAnswer: json['your_answer'] as String?,
      correctAnswer: json['correct_answer'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      points: json['points'] as String? ?? '0',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'question_number': questionNumber,
      'question_id': questionId,
      'question': question,
      'your_answer': yourAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'points': points,
    };
  }
}
