import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/course_review_widget.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_shimmer.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/review_bottom_sheet.dart';
import 'package:fitflow/common/widgets/review_shimmer.dart';
import 'package:fitflow/common/widgets/user_review_widget.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/course/cubit/course_reviews_cubit.dart';
import 'package:fitflow/utils/extensions/scroll_extension.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ReviewsScreen extends StatefulWidget {
  final int courseId;

  const ReviewsScreen({super.key, required this.courseId});

  static Widget route([RouteSettings? settings]) {
    final int? courseId = (settings?.arguments ?? Get.arguments) as int?;
    if (courseId == null) {
      throw Exception('ReviewsScreen requires courseId as argument');
    }
    return BlocProvider(
      create: (context) =>
          CourseReviewsCubit(courseId: courseId)..fetchReviews(),
      child: ReviewsScreen(courseId: courseId),
    );
  }

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.isEndReached) {
      context.read<CourseReviewsCubit>().fetchMoreReviews();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.review.tr, showBackButton: true),
      bottomNavigationBar: BottomAppBar(
        padding: const .all(8),
        height: kBottomNavigationBarHeight,
        child: CustomButton(
          title: AppLabels.addReview.tr,
          onPressed: () async {
            final result = await UiUtils.showCustomBottomSheet(
              context,
              child: ReviewBottomSheet(
                type: ReviewType.course,
                id: widget.courseId,
              ),
            );
            if (result == true) {
              if (context.mounted) {
                await context.read<CourseReviewsCubit>().fetchReviews();
              }
            }
          },
        ),
      ),
      body: BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
        builder: (context, state) {
          if (state is CourseReviewsLoading) {
            return _buildLoadingState();
          }

          if (state is CourseReviewsSuccess) {
            return _buildSuccessState(state);
          }

          if (state is CourseReviewsError) {
            return _buildErrorState(state.error);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SingleChildScrollView(
      padding: .all(16),
      child: Column(
        spacing: 16,
        children: [
          CustomShimmer(height: 120, width: double.infinity, borderRadius: 8),
          ReviewsListShimmer(itemCount: 5),
        ],
      ),
    );
  }

  Widget _buildSuccessState(CourseReviewsSuccess state) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const .all(16),
      child: Column(
        spacing: 16,
        children: [
          RatingsWidget(
            reviewData: state.statistics,
            ratingTitle: AppLabels.courseReviews.tr,
          ),
          if (state.reviews.isNotEmpty)
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return UserReviewWidget(review: state.reviews[index]);
              },
            )
          else
            Padding(
              padding: const .all(32),
              child: CustomText(
                AppLabels.noReviewsYet.tr,
                textAlign: .center,
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
            ),
          if (state.isLoadingMore)
            const Padding(
              padding: .all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const .all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            CustomText(
              error,
              textAlign: .center,
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: AppLabels.retry.tr,
              onPressed: () {
                context.read<CourseReviewsCubit>().fetchReviews();
              },
            ),
          ],
        ),
      ),
    );
  }
}
