import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/widgets/course_overview_widget.dart';
import 'package:elms/features/course/widgets/instructor_card_widget.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AboutCourseScreen extends StatefulWidget {
  final CourseModel course;
  final CourseDetailsModel? courseDetails;

  const AboutCourseScreen({
    super.key,
    required this.course,
    this.courseDetails,
  });

  static Widget route([RouteSettings? settings]) {
    final CourseDetailsScreenArguments? args =
        (settings?.arguments ?? Get.arguments) as CourseDetailsScreenArguments?;
    if (args == null) {
      throw Exception(
        'CourseDetailsScreenArguments required for AboutCourseScreen',
      );
    }
    return BlocProvider(
      create: (context) => CourseDetailsCubit(CourseRepository()),
      child: AboutCourseScreen(
        course: args.course,
        courseDetails: args.course is CourseDetailsModel
            ? args.course as CourseDetailsModel
            : null,
      ),
    );
  }

  @override
  State<AboutCourseScreen> createState() => _AboutCourseScreenState();
}

class _AboutCourseScreenState extends State<AboutCourseScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.courseDetails != null) {
      context.read<CourseDetailsCubit>().setInitialData(widget.courseDetails!);
    } else {
      context.read<CourseDetailsCubit>().fetchCourseDetails(widget.course);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: true),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) {
          if (state is CourseDetailsProgress) {
            return _buildContent(
              state.initialData ??
                  CourseDetailsModel.fromCourseModel(widget.course),
              isLoading: true,
            );
          }

          if (state is CourseDetailsSuccess) {
            return _buildContent(state.data);
          }

          if (state is CourseDetailsError) {
            return _buildErrorWidget();
          }

          return _buildContent(
            CourseDetailsModel.fromCourseModel(widget.course),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    CourseDetailsModel courseDetails, {
    bool isLoading = false,
  }) {
    return SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        spacing: 12,
        children: [
          _buildCourseDetails(courseDetails),
          if (courseDetails.instructor != null)
            InstructorCardWidget(
              instructor: courseDetails.instructor!.toInstructorModel(),
            ),
          if (isLoading)
            const Padding(
              padding: .all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 16),
          CustomText(
            AppLabels.somethingWentWrong.tr,
            style: Theme.of(context).textTheme.titleMedium!,
          ),
          const SizedBox(height: 16),
          CustomButton(
            title: AppLabels.retry.tr,
            onPressed: () {
              context.read<CourseDetailsCubit>().fetchCourseDetails(
                widget.course,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetails(CourseDetailsModel courseDetails) {
    final Map<String, String> courseDetailsMap = {
      'duration': courseDetails.totalDurationFormatted,
      'chapters': AppLabels.courseChaptersCount.translateWithTemplate({
        'count': courseDetails.chapterCount.toString(),
      }),
      'lectures': AppLabels.courseLecturesCount.translateWithTemplate({
        'count': courseDetails.lectureCount.toString(),
      }),
      'rating': AppLabels.courseRating.translateWithTemplate({
        'rating': courseDetails.averageRating.toString(),
        'count': courseDetails.ratings.toString(),
      }),
      'language': courseDetails.language.isNotEmpty
          ? courseDetails.language
          : AppLabels.courseLanguage.tr,
      'access': AppLabels.courseAccess.tr,
    };

    final String overview =
        courseDetails.description ?? courseDetails.shortDescription;

    final List<String> learningPoints = courseDetails.learnings
        .map((learning) => learning.title)
        .toList();

    final List<String> requirements = courseDetails.requirements
        .map((requirement) => requirement.requirement)
        .toList();

    return CourseOverviewWidget(
      isFree: courseDetails.isFree,
      level: courseDetails.level.isNotEmpty
          ? courseDetails.level
          : AppLabels.courseLevelAdvanced.tr,
      category: courseDetails.categoryName ?? '',
      currentPrice: courseDetails.discountedPrice ?? courseDetails.price,
      originalPrice: courseDetails.price,
      title: courseDetails.title,
      courseDetails: courseDetailsMap,
      overview: overview,
      learningPoints: learningPoints,
      requirements: requirements,
    );
  }
}
