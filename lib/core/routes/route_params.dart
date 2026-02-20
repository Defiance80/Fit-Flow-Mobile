import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/chapter_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/features/authentication/screens/signup/signup_screen.dart';
import 'package:elms/features/course/cubit/course_chapters_cubit.dart';

final class QuizResultParams extends RouteArguments {
  final QuizResult result;
  final int passingMarks;
  final int courseChapterQuizId;
  final String quizTitle;
  final int totalMarks;
  final List<Question> questions;
  final int courseId;
  final int chapterId;
  final CourseChaptersCubit? courseChaptersCubit;

  QuizResultParams({
    required this.result,
    required this.passingMarks,
    required this.courseChapterQuizId,
    required this.quizTitle,
    required this.totalMarks,
    required this.questions,
    required this.courseId,
    required this.chapterId,
    this.courseChaptersCubit,
  });
}

final class SignupArguments extends RouteArguments {
  final SignupMode mode;
  final String? email;
  final PhoneNumber? phoneNumber;
  final String? firebaseToken;
  SignupArguments({
    required this.mode,
    this.email,
    this.phoneNumber,
    this.firebaseToken,
  });
}

final class VerifyScreenArguments extends RouteArguments {
  final PhoneNumber phoneNumber;
  final String verificationId;

  VerifyScreenArguments({
    required this.phoneNumber,
    required this.verificationId,
  });
}

final class CourseDetailsScreenArguments extends RouteArguments {
  final CourseModel course;

  CourseDetailsScreenArguments({required this.course});
}

final class CourseContentScreenArguments extends RouteArguments {
  final CourseModel course;
  final int? initialChapterIndex;
  final int? initialLectureIndex;

  CourseContentScreenArguments({
    required this.course,
    this.initialChapterIndex,
    this.initialLectureIndex,
  });
}
