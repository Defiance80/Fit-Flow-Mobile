import 'dart:async';

import 'package:elms/common/enums.dart';
import 'package:elms/common/models/course_details_model.dart';
import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/cubit/checkout_cubit.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/features/cart/models/cart_summary_model.dart';
import 'package:elms/features/cart/models/checkout_data_model.dart';
import 'package:elms/features/cart/repository/checkout_repository.dart';
import 'package:elms/features/cart/screens/checkout_screen.dart';
import 'package:elms/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:elms/features/coupon/models/promo_code_preview_model.dart';
import 'package:elms/features/course/cubit/course_details_cubit.dart';
import 'package:elms/features/course/cubit/course_chapters_cubit.dart';
import 'package:elms/features/course/cubit/course_reviews_cubit.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:elms/features/course/widgets/course_details_appbar.dart';
import 'package:elms/features/instructor/models/instructor_details_model.dart';
import 'package:elms/features/instructor/repository/instructor_repository.dart';
import 'package:elms/features/video_player/bloc/video_player_bloc.dart';
import 'package:elms/features/video_player/video_player.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:elms/features/course/widgets/certificate_widget.dart';
import 'package:elms/features/course/widgets/chapters_list_section.dart';
import 'package:elms/features/course/widgets/coupon_section_widget.dart';
import 'package:elms/features/course/widgets/course_overview_widget.dart';
import 'package:elms/common/widgets/reviews_widget.dart';
import 'package:elms/common/widgets/review_shimmer.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/features/course/widgets/instructor_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;
  final CourseDetailsModel? courseDetails;
  const CourseDetailsScreen({
    super.key,
    required this.course,
    this.courseDetails,
  });

  static Widget route() {
    final CourseDetailsScreenArguments args =
        Get.arguments as CourseDetailsScreenArguments;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourseDetailsCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) => CourseChaptersCubit(CourseRepository()),
        ),
        BlocProvider(
          create: (context) =>
              CourseReviewsCubit(courseId: args.course.id)..fetchReviews(),
        ),
        BlocProvider(create: (context) => ApplyCouponCubit()),
      ],
      child: CourseDetailsScreen(
        course: args.course,
        courseDetails: args.course is CourseDetailsModel
            ? args.course as CourseDetailsModel
            : null,
      ),
    );
  }

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.courseDetails != null) {
      context.read<CourseDetailsCubit>().setInitialData(widget.courseDetails!);
    } else {
      context.read<CourseDetailsCubit>().fetchCourseDetails(widget.course);
    }

    context.read<CourseChaptersCubit>().fetchChapters(widget.course.id);
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CourseDetailsAppBar(course: widget.course),
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
            return _buildErrorWidget(state);
          }

          return _buildContent(
            CourseDetailsModel.fromCourseModel(widget.course),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent(
    CourseDetailsModel courseDetails, {
    bool isLoading = false,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: .start,
          spacing: 16,
          children: [
            _buildVideoPlayer(courseDetails),
            _buildCourseDetails(courseDetails),
            if (courseDetails.instructor != null)
              GestureDetector(
                onTap: () {
                  LoadingOverlay.execute(() async {
                    final InstructorDetailsModel instructor =
                        await InstructorRepository().fetchInstructorDetails(
                          id: courseDetails.instructor!.instructorId.toString(),
                        );
                    unawaited(
                      Get.toNamed(
                        AppRoutes.instructorDetailsScreen,
                        arguments: instructor,
                      ),
                    );
                  });
                },
                child: InstructorCardWidget(
                  instructor: courseDetails.instructor!.toInstructorModel(),
                ),
              ),
            if (!courseDetails.isFree)
              CouponSelectorWidget(
                target: CouponListTarget.course,
                courseId: courseDetails.id,
                onApplyCoupon: _onApplyCoupon,
              ),
            _buildCertificateWidget(),
            _buildChaptersSection(),
            _buildReviewsSection(),
            if (isLoading)
              const Padding(
                padding: .all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(CourseDetailsError state) {
    return CustomErrorWidget.fromErrorState(
      errorState: state,
      onRetry: () {
        context.read<CourseDetailsCubit>().fetchCourseDetails(widget.course);
      },
    );
  }

  Widget _buildVideoPlayer(CourseDetailsModel courseDetails) {
    // Find the intro preview video
    final introVideo = courseDetails.previewVideos
        .where((video) => video.type.toLowerCase() == 'intro')
        .firstOrNull;

    // If no intro video is found, show thumbnail image
    if (introVideo == null || introVideo.video.isEmpty) {
      return _buildThumbnailImage(courseDetails, introVideo);
    }

    return BlocProvider(
      create: (context) => VideoPlayerBloc(),
      child: CustomVideoPlayer(url: introVideo.video),
    );
  }

  Widget _buildThumbnailImage(
    CourseDetailsModel courseDetails,
    PreviewVideoModel? introVideo,
  ) {
    // Use intro video thumbnail if available, otherwise use course image
    final String thumbnailUrl = introVideo?.thumbnail.isNotEmpty == true
        ? introVideo!.thumbnail
        : courseDetails.image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CustomImage(thumbnailUrl, fit: .cover),
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
      level: courseDetails.level.isNotEmpty
          ? courseDetails.level
          : AppLabels.courseLevelAdvanced.tr,
      isFree: courseDetails.isFree,
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

  Widget _buildBottomBar() {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, courseState) {
        final CourseDetailsModel courseDetails;

        if (courseState is CourseDetailsSuccess) {
          courseDetails = courseState.data;
        } else {
          courseDetails = CourseDetailsModel.fromCourseModel(widget.course);
        }

        final bool isFree = courseDetails.isFree;

        return ColoredBox(
          color: context.color.surface,
          child: Padding(
            padding: const .all(16),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: CustomButton(
                    title: AppLabels.enrollNow.tr,
                    onPressed: _onEnrollTap,
                  ),
                ),
                if (!isFree)
                  Expanded(
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        final bool isAddedInCart = context
                            .read<CartCubit>()
                            .isAddedInCart(widget.course.id);
                        return CustomButton(
                          title: isAddedInCart
                              ? AppLabels.removeFromCart.tr
                              : AppLabels.addToCart.tr,
                          onPressed: state is UpdateCartInProgress
                              ? null
                              : _onCartToggle,
                          isLoading: state is UpdateCartInProgress,
                          type: CustomButtonType.outlined,
                          borderColor: context.color.primary,
                          textColor: context.color.primary,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onApplyCoupon(String couponCode) {
    GuestChecker.check(
      onNotGuest: () {
        if (couponCode.isNotEmpty) {
          context.read<ApplyCouponCubit>().applyCouponByCode(
            code: couponCode,
            courseId: widget.course.id,
          );
        }
      },
    );
  }

  void _onViewAllReviewsTap() {
    Get.toNamed(AppRoutes.reviewsScreen, arguments: widget.course.id);
  }

  Widget _buildReviewsSection() {
    return BlocBuilder<CourseReviewsCubit, CourseReviewsState>(
      builder: (context, state) {
        if (state is CourseReviewsLoading) {
          return const Column(
            spacing: 16,
            children: [
              CustomShimmer(
                height: 120,
                width: double.infinity,
                borderRadius: 8,
              ),
              ReviewsListShimmer(itemCount: 2),
            ],
          );
        }

        if (state is CourseReviewsSuccess) {
          return ReviewsWidget(
            reviewData: state.statistics,
            userReviews: state.reviews.take(3).toList(),
            onViewAllReviewsTap: _onViewAllReviewsTap,
          );
        }

        return const SizedBox();
      },
    );
  }

  void _onEnrollTap() {
    final currentCourse = context.read<CourseDetailsCubit>().state;
    CourseDetailsModel courseDetails;

    if (currentCourse is CourseDetailsSuccess) {
      courseDetails = currentCourse.data;
    } else {
      courseDetails = CourseDetailsModel.fromCourseModel(widget.course);
    }

    // Get applied coupon data from ApplyCouponCubit
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    PromoCodePreviewModel? promoData;
    if (applyCouponState is ApplyCouponSuccess) {
      promoData = applyCouponState.previewData;
    }

    final CartCourseModel cartCourse = CartCourseModel(
      id: courseDetails.id,
      title: courseDetails.title,
      slug: courseDetails.slug ?? '',
      thumbnail: courseDetails.image,
      displayPrice: courseDetails.price,
      displayDiscountPrice: courseDetails.discountedPrice ?? 0.0,
      originalPrice: courseDetails.discountedPrice ?? courseDetails.price,
      promoDiscount: 0.0,
      finalPrice: courseDetails.discountedPrice ?? courseDetails.price,
      taxAmount: 0.0,
      totalTaxPercentage: '0.00',
      instructor: courseDetails.instructor?.name ?? '',
      isWishlisted: courseDetails.isWishlisted,
      ratings: courseDetails.ratings,
      averageRating: courseDetails.averageRating,
    );

    // Use values from PromoCodePreviewModel if coupon is applied
    final CartSummaryModel summary;
    if (promoData != null) {
      // Use the values from coupon preview API response
      final coursePromo = promoData.courses.first;
      summary = CartSummaryModel(
        discount: promoData.discount.toDouble(),
        displayPrice: promoData.totalDisplayPrice,
        subtotal: promoData.subtotalPrice.toDouble(),
        grandTotal: promoData.totalDisplayPrice.toDouble(),
        totalPay: promoData.totalPrice.toDouble(),
        couponDiscount: promoData.promoDiscount.toDouble(),
        appliedCouponCode: coursePromo.promoCode?.code,
      );
    } else {
      // No coupon applied - use default calculation
      final num effectivePrice = cartCourse.effectivePrice;
      summary = CartSummaryModel(
        discount: 0,
        displayPrice: effectivePrice,
        subtotal: effectivePrice,
        grandTotal: effectivePrice,
        totalPay: effectivePrice,
      );
    }

    final CheckoutDataModel checkoutData = CheckoutDataModel(
      courses: [cartCourse],
      summary: summary,
      promoCodeId: promoData?.courses.first.promoCode?.id,
      promoPreview: promoData,
    );

    // Pass the ApplyCouponCubit to checkout so it can read the promo data
    final applyCouponCubit = context.read<ApplyCouponCubit>();

    GuestChecker.check(
      onNotGuest: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => CheckoutCubit(CheckoutRepository()),
                ),
                BlocProvider.value(value: applyCouponCubit),
              ],
              child: CheckoutScreen(
                checkoutData: checkoutData,
                checkoutType: CheckoutType.directEnroll,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCartToggle() {
    GuestChecker.check(
      onNotGuest: () {
        context.read<CartCubit>().toggleCart(widget.course.id);
      },
    );
  }

  Widget _buildCertificateWidget() {
    return CustomCard(
      padding: const .all(8),
      child: Column(
        spacing: 8,
        children: [
          CustomText(
            AppLabels.enterOrPurchaseCertificate.tr,
            style: Theme.of(context).textTheme.titleMedium!,
            fontWeight: .w500,
          ),
          CustomText(
            AppLabels.certificateSectionDescription.tr,
            style: Theme.of(context).textTheme.bodyMedium!,
            fontWeight: .w400,
            textAlign: .center,
          ),
          const CertificateWidget(
            height: 234,
            certificateImage: 'assets/images/certificate_bg.png',
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersSection() {
    return BlocBuilder<CourseChaptersCubit, CourseChaptersState>(
      builder: (context, state) {
        if (state is CourseChaptersProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CourseChaptersSuccess) {
          return ChaptersListSection(
            chapters: state.data,
            title: AppLabels.courseContent.tr,
            sequentialAccess: widget.courseDetails?.sequentialAccess ?? false,
            isEnrolled: widget.course.isEnrolled,
            currentCurriculumId:
                widget.courseDetails?.currentCurriculum?.modelId,
          );
        }

        if (state is CourseChaptersError) {
          return Center(
            child: CustomText(
              'Error loading chapters: ${state.error}',
              style: Theme.of(context).textTheme.bodyMedium!,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
