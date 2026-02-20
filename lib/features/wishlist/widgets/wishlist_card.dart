import 'package:elms/common/models/course_model.dart';
import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/widgets/rating_bar_widget.dart';
import 'package:elms/core/constants/app_colors.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/login/guest_checker.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WishlistCard extends StatelessWidget {
  final CourseModel wishlistItem;
  final VoidCallback? onRemoveFromWishlist;

  const WishlistCard({
    super.key,
    required this.wishlistItem,
    this.onRemoveFromWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.courseDetailsScreen,
          arguments: CourseDetailsScreenArguments(course: wishlistItem),
        )?.then((_) {
          if (context.mounted) context.read<FetchWishlistCubit>().fetchData();
        });
      },
      child: CustomCard(
        borderRadius: 6,
        height: 177,
        border: 0,
        padding: const .all(8),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildDetailsContainer(context),
            const SizedBox(height: 8),
            _buildPriceAndCartButton(context),
            const Spacer(),
            Divider(height: 8, color: context.color.outline),
            const Spacer(),
            _buildRemoveFromWishlistButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndCartButton(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          flex: wishlistItem.isFree ? 1 : 3,
          child: _buildPrice(context),
        ),
        if (!wishlistItem.isFree)
          Expanded(flex: 2, child: _buildAddToCartButton(context)),
      ],
    );
  }

  Widget _buildDetailsContainer(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .spaceEvenly,
              children: [
                _buildRatings(context),
                _buildCourseTitle(context),
                _buildInstructor(context),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomImage(
              wishlistItem.image,
              radius: 4,
              height: double.infinity,
              fit: .cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatings(BuildContext context) {
    return Rating.number(
      rating: wishlistItem.ratings.toDouble(),
      ratingCount: wishlistItem.ratings,
    );
  }

  Widget _buildCourseTitle(BuildContext context) {
    return CustomText(
      wishlistItem.title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall!.copyWith(fontWeight: .w600),
      maxLines: 2,
      ellipsis: true,
    );
  }

  Widget _buildInstructor(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'By ',
        children: [
          TextSpan(
            text: wishlistItem.authorName,
            style: TextStyle(
              color: context.color.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: context.color.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        if (wishlistItem.isFree) ...[
          CustomText(
            AppLabels.free.tr,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: .w600,
              color: context.color.success,
            ),
          ),
        ] else ...[
          CustomText(
            wishlistItem.finalPrice.toString().currency,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: .w600),
          ),
          if (wishlistItem.hasDiscount)
            CustomText(
              wishlistItem.price.toString().currency,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 12,
                color: context.color.onSurface.withValues(alpha: 0.6),
                decoration: TextDecoration.lineThrough,
                decorationThickness: 2,
                decorationColor: Colors.grey,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final bool isAddedInCart = context.read<CartCubit>().isAddedInCart(
          wishlistItem.id,
        );
        final bool isLoading =
            state is UpdateCartInProgress && state.id == wishlistItem.id;

        return CustomButton(
          title: isAddedInCart
              ? AppLabels.removeFromCart.tr
              : AppLabels.addToCart.tr,
          onPressed: isLoading ? null : () => _onCartToggle(context),
          height: 36,
          textSize: 16,
          padding: const .symmetric(horizontal: 2),
        );
      },
    );
  }

  void _onCartToggle(BuildContext context) {
    GuestChecker.check(
      onNotGuest: () {
        context.read<CartCubit>().toggleCart(wishlistItem.id);
      },
    );
  }

  Widget _buildRemoveFromWishlistButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: onRemoveFromWishlist,
        child: CustomText(
          AppLabels.removeFromWishlist.tr,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: context.color.error,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }
}
