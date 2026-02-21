import 'package:fitflow/features/cart/models/cart_response_model.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_inkwell.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/cart/cubit/cart_cubit.dart';
import 'package:fitflow/features/wishlist/cubit/wishlist_action_cubit.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartCourseCard extends StatelessWidget {
  final CartCourseModel course;
  final VoidCallback? onRemoveFromCart;

  const CartCourseCard({
    super.key,
    required this.course,
    this.onRemoveFromCart,
  });

  void _onToggleWishlist(BuildContext context) {
    context.read<WishlistActionCubit>().toggleWishlist(
      courseId: course.id,
      currentWishlistState: course.isWishlisted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishlistActionCubit, WishlistActionState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess && state.courseId == course.id) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.color.success,
            ),
          );
        } else if (state is WishlistActionError &&
            state.courseId == course.id) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: context.color.error,
            ),
          );
        }
      },
      child: CustomCard(
        borderColor: context.color.outline,
        padding: const .all(10),
        child: Column(
          spacing: 8,
          children: [
            _buildCourseInfo(context),
            Divider(height: 1, color: context.color.outline),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        // Course Image
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: CustomImage(
            course.thumbnail,
            width: 87,
            height: 87,
            fit: .cover,
          ),
        ),

        // Course Details
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Rating (static - not available in API)
              _buildRatings(context),
              const SizedBox(height: 7),
              _buildCourseTitleAndInstructor(context),
              // Price
              _buildPriceSection(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatings(BuildContext context) {
    return Row(
      children: [
        CustomImage(AppIcons.cartStar, width: 16, height: 16),
        const SizedBox(width: 2),
        CustomText(
          '${course.averageRating.toStringAsFixed(1)} (${course.ratings})',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: context.color.onSurface),
        ),
      ],
    );
  }

  Widget _buildCourseTitleAndInstructor(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          course.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: .w400,
            color: context.color.onSurface,
            height: 1.1,
          ),
          maxLines: 2,
          ellipsis: true,
        ),
        CustomText(
          course.instructor,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: context.color.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Row(
      spacing: 2,
      children: [
        if (course.effectivePrice == 0) ...[
          CustomText(
            'free'.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w600,
              color: context.color.success,
            ),
          ),
        ] else ...[
          CustomText(
            course.effectivePrice.toStringAsFixed(2).currency,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w600,
              color: context.color.onSurface,
            ),
          ),
        ],
        if (course.displayDiscountPrice > 0 &&
            course.displayDiscountPrice != course.displayPrice)
          CustomText(
            course.displayPrice.toStringAsFixed(2).currency,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              decorationColor: Colors.grey,
              color: context.color.onSurface.withValues(alpha: 127),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 8),
      child: Row(
        children: [
          // Remove Button
          Expanded(child: _buildRemoveButton(context)),
          // Divider
          Container(height: 16, width: 1, color: context.color.outline),
          // Wishlist Toggle Button
          Expanded(child: _buildWishlistToggleButton(context)),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final bool isLoading =
            state is UpdateCartInProgress && state.id == course.id;

        return CustomInkWell(
          color: context.color.surface,
          onTap: isLoading ? null : onRemoveFromCart,
          child: Row(
            mainAxisAlignment: .center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CustomImage(
                      AppIcons.deleteOutlined,
                      width: 24,
                      height: 24,
                      color: context.color.primary,
                    ),
              const SizedBox(width: 6),
              CustomText(
                AppLabels.remove.tr,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.color.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistToggleButton(BuildContext context) {
    return BlocBuilder<WishlistActionCubit, WishlistActionState>(
      builder: (context, state) {
        final isLoading = state is WishlistActionInProgress;

        // Check if this specific course had a successful state change
        bool currentWishlistState = course.isWishlisted;
        if (state is WishlistActionSuccess && state.courseId == course.id) {
          currentWishlistState = state.isWishlisted;
        }

        return CustomInkWell(
          color: context.color.surface,
          onTap: isLoading ? null : () => _onToggleWishlist(context),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CustomImage(
                      currentWishlistState
                          ? AppIcons.wishlist
                          : AppIcons.wishlistIcon,
                      width: 16,
                      height: 16,
                      color: context.color.primary,
                    ),
              const SizedBox(width: 6),
              Expanded(
                child: CustomText(
                  currentWishlistState
                      ? AppLabels.removeFromWishlist.tr
                      : AppLabels.addToWishlist.tr,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.color.onSurface,
                  ),
                  maxLines: 1,
                  ellipsis: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
