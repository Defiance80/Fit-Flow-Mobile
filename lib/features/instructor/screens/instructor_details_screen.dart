import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/models/instructor_model.dart';
import 'package:fitflow/common/models/review_model.dart';
import 'package:fitflow/common/repositories/review_repository.dart';
import 'package:fitflow/common/widgets/animated_showmore_container.dart';
import 'package:fitflow/common/widgets/course_card.dart';
import 'package:fitflow/common/widgets/course_review_widget.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_error_widget.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/review_bottom_sheet.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/login/guest_checker.dart';
import 'package:fitflow/features/instructor/cubit/instructor_details_cubit.dart';
import 'package:fitflow/features/instructor/models/instructor_details_model.dart';
import 'package:fitflow/features/instructor/widgets/current_user_review.dart';
import 'package:fitflow/features/instructor/widgets/instructor_social_media.dart';
import 'package:fitflow/features/instructor/widgets/instructor_stats_widget.dart';
import 'package:fitflow/features/video_player/bloc/video_player_bloc.dart';
import 'package:fitflow/features/video_player/video_player.dart';
import 'package:fitflow/utils/course_navigation_helper.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class InstructorDetailsScreen extends StatefulWidget {
  final InstructorModel instructor;
  const InstructorDetailsScreen({super.key, required this.instructor});

  static Widget route() {
    final InstructorModel instructor = (Get.arguments) as InstructorModel;
    return BlocProvider(
      create: (context) => InstructorDetailsCubit(),
      child: InstructorDetailsScreen(instructor: instructor),
    );
  }

  @override
  State<InstructorDetailsScreen> createState() =>
      _InstructorDetailsScreenState();
}

class _InstructorDetailsScreenState extends State<InstructorDetailsScreen> {
  final ReviewRepository _reviewRepository = ReviewRepository();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<InstructorDetailsCubit>().fetchInstructorDetails(
          id: widget.instructor.id.toString(),
        );
      }
    });
    super.initState();
  }

  Future<void> _onTapDeleteReview(int ratingId) async {
    try {
      final cubit = context.read<InstructorDetailsCubit>();
      await _reviewRepository.deleteReview(ratingId: ratingId);
      if (!mounted) return;

      UiUtils.showSnackBar(AppLabels.reviewDeletedSuccessfully.tr);
      // Refresh instructor details to update UI without showing loading
      await cubit.fetchInstructorDetails(
        id: widget.instructor.id.toString(),
        skipProgress: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onTapEditReview({
    required num rating,
    required String review,
  }) async {
    final cubit = context.read<InstructorDetailsCubit>();
    final result = await UiUtils.showCustomBottomSheet(
      context,
      child: ReviewBottomSheet(
        type: ReviewType.instructor,
        id: widget.instructor.id,
        initialRating: rating.toInt(),
        initialReview: review,
      ),
    );

    // If review was updated successfully, refresh instructor details
    if (result == true && mounted) {
      await cubit.fetchInstructorDetails(
        id: widget.instructor.id.toString(),
        skipProgress: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.instructor.tr,
        showBackButton: true,
      ),
      body: BlocBuilder<InstructorDetailsCubit, BaseState>(
        builder: (context, state) {
          if (state is SuccessDataState<InstructorDetailsModel>) {
            return SingleChildScrollView(
              child: Padding(
                padding: const .all(16.0),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 16,
                  children: [
                    _buildPreviewVideo(state.data),
                    _buildInstructorHeader(context),
                    _buildInstructorStats(context),
                    _buildSocialMedia(context),
                    _buildDivider(context),
                    _buildAboutMe(context),

                    if (state.data.reviewCount > 0) ...[
                      _buildDivider(context),
                      _buildReviews(context),
                      _buildLeaveReviewButton(context),
                    ],
                    if (state.data.courses.isNotEmpty) ...[
                      _buildDivider(context),
                      _buildCourses(state.data.courses),
                    ],
                  ],
                ),
              ),
            );
          } else if (state is ErrorState) {
            return Center(
              child: CustomErrorWidget(
                error: state.error.toString().tr,
                onRetry: () {
                  context.read<InstructorDetailsCubit>().fetchInstructorDetails(
                    id: widget.instructor.id.toString(),
                  );
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPreviewVideo(InstructorDetailsModel instructorDetails) {
    final String? previewVideoUrl = instructorDetails.previewVideo;

    // If no preview video available, show thumbnail image
    if (previewVideoUrl == null || previewVideoUrl.isEmpty) {
      return _buildThumbnailImage(instructorDetails);
    }
    // Show video player directly
    return BlocProvider(
      create: (context) => VideoPlayerBloc(),
      child: CustomVideoPlayer(url: previewVideoUrl),
    );
  }

  Widget _buildThumbnailImage(InstructorDetailsModel instructorDetails) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CustomImage(instructorDetails.profile, fit: .cover),
      ),
    );
  }

  Widget _buildInstructorHeader(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Container(
            width: 71,
            height: 71,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: context.color.outline),
            ),
            child: CustomImage(
              widget.instructor.profile,
              fit: .cover,
              radius: 4,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceEvenly,
              children: [
                CustomText(
                  widget.instructor.name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: .w600,
                    fontSize: 20,
                  ),
                ),
                CustomText(
                  widget.instructor.qualification?.stripHtmlTags ?? '',
                  style: Theme.of(context).textTheme.bodyMedium!,
                  maxLines: 2,
                  ellipsis: true,
                  color: context.color.onSurface.withValues(alpha: 150),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveReviewButton(BuildContext context) {
    return CustomButton(
      title: AppLabels.leaveReview.tr,
      onPressed: () async {
        GuestChecker.check(
          onNotGuest: () async {
            final cubit = context.read<InstructorDetailsCubit>();
            final result = await UiUtils.showCustomBottomSheet(
              context,
              child: ReviewBottomSheet(
                type: ReviewType.instructor,
                id: widget.instructor.id,
              ),
            );

            // If review was submitted successfully, refresh instructor details
            if (result == true && mounted) {
              await cubit.fetchInstructorDetails(
                id: widget.instructor.id.toString(),
                skipProgress: true,
              );
            }
          },
        );
      },
      fullWidth: true,
      radius: 4,
    );
  }

  Widget _buildInstructorStats(BuildContext context) {
    return BlocBuilder<InstructorDetailsCubit, BaseState>(
      builder: (context, state) {
        if (state is SuccessDataState<InstructorDetailsModel>) {
          return CustomCard(
            padding: const .symmetric(horizontal: 10, vertical: 8),
            borderColor: Colors.transparent,
            child: InstructorStatsWidget(
              studentsCount: state.data.studentEnrolledCount,
              coursesCount: state.data.activeCoursesCount,
              reviewsCount: state.data.reviewCount,
              rating: state.data.averageRating.toDouble(),
            ),
          );
        }
        return const CustomCard(
          padding: .symmetric(horizontal: 10, vertical: 8),
          borderColor: Colors.transparent,
          child: InstructorStatsWidget(
            studentsCount: 0,
            coursesCount: 0,
            reviewsCount: 0,
            rating: 0,
          ),
        );
      },
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    return BlocBuilder<InstructorDetailsCubit, BaseState>(
      builder: (context, state) {
        if (state is SuccessDataState<InstructorDetailsModel>) {
          return Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  CustomText(
                   AppLabels.followMe.tr,
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InstructorSocialMedia(
                      socialMedias: state.data.socialMedias,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(color: context.color.outline, height: 1);
  }

  Widget _buildAboutMe(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText('About Me', style: Theme.of(context).textTheme.titleMedium!),
        const SizedBox(height: 10),
        AnimatedShowMore(
          content: widget.instructor.aboutMe?.stripHtmlTags,
          maxLines: 4,
          textStyle: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: context.color.onSurface),
          textColor: context.color.primary,
        ),
      ],
    );
  }

  Widget _buildReviews(BuildContext context) {
    final state = context.read<InstructorDetailsCubit>().state;
    if (state is! SuccessDataState<InstructorDetailsModel>) {
      return Container();
    }

    final List<InstructorRatingModel> ratings = state.data.ratings;
    final ReviewModel reviewData = _computeReviewData(state.data);

    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        RatingsWidget(
          reviewData: reviewData,
          ratingTitle: AppLabels.reviews.tr,
        ),
        if (state.data.myReview != null)
          CurrentUserReview(
            myReview: state.data.myReview!,
            onDelete: () => _onTapDeleteReview(state.data.myReview!.id),
            onEdit: () => _onTapEditReview(
              rating: state.data.myReview!.rating,
              review: state.data.myReview!.review,
            ),
          ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ratings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildInstructorReviewCard(ratings[index]);
          },
        ),
      ],
    );
  }

  ReviewModel _computeReviewData(InstructorDetailsModel data) {
    // Count ratings by star level
    int fiveStars = 0;
    int fourStars = 0;
    int threeStars = 0;
    int twoStars = 0;
    int oneStar = 0;

    for (final rating in data.ratings) {
      final ratingValue = rating.rating.round();
      if (ratingValue == 5) {
        fiveStars++;
      } else if (ratingValue == 4) {
        fourStars++;
      } else if (ratingValue == 3) {
        threeStars++;
      } else if (ratingValue == 2) {
        twoStars++;
      } else if (ratingValue == 1) {
        oneStar++;
      }
    }

    final totalRatings = data.ratings.length;

    // Compute percentages
    final int fiveStarsPercentage = totalRatings > 0
        ? ((fiveStars / totalRatings) * 100).round()
        : 0;
    final int fourStarsPercentage = totalRatings > 0
        ? ((fourStars / totalRatings) * 100).round()
        : 0;
    final int threeStarsPercentage = totalRatings > 0
        ? ((threeStars / totalRatings) * 100).round()
        : 0;
    final int twoStarsPercentage = totalRatings > 0
        ? ((twoStars / totalRatings) * 100).round()
        : 0;
    final int oneStarPercentage = totalRatings > 0
        ? ((oneStar / totalRatings) * 100).round()
        : 0;

    return ReviewModel(
      averageRating: data.averageRating.toDouble(),
      totalReviews: data.reviewCount,
      ratingDistribution: RatingDistribution(
        fiveStars: fiveStars,
        fourStars: fourStars,
        threeStars: threeStars,
        twoStars: twoStars,
        oneStar: oneStar,
        fiveStarsPercentage: fiveStarsPercentage,
        fourStarsPercentage: fourStarsPercentage,
        threeStarsPercentage: threeStarsPercentage,
        twoStarsPercentage: twoStarsPercentage,
        oneStarPercentage: oneStarPercentage,
      ),
    );
  }

  Widget _buildInstructorReviewCard(InstructorRatingModel rating) {
    return CustomCard(
      padding: const .all(8),

      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              _buildReviewerAvatar(rating.userProfile),
              const SizedBox(width: 16),
              Expanded(
                child: CustomText(
                  rating.userName,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: .w600,
                    color: context.color.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const .symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.color.warning,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    CustomImage(
                      AppIcons.starFilled,
                      width: 13,
                      height: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      rating.rating.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomText(
            rating.review,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: context.color.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewerAvatar(String avatarUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: context.color.onSurface, width: 0.83),
      ),
      padding: const .all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CustomImage(avatarUrl, fit: .cover),
      ),
    );
  }

  Widget _buildCourses(List<CourseModel> courses) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          AppLabels.myCourses.tr,
          style: Theme.of(context).textTheme.titleMedium!,
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: courses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return CourseCard.horizontal(
              course: courses[index],
              height: 200,
              onTap: () async {
                await CourseNavigationHelper.navigateToCourse(courses[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
