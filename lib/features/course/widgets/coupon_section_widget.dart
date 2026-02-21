import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:fitflow/features/coupon/cubits/fetch_coupons_cubit.dart';
import 'package:fitflow/features/coupon/models/promo_code_preview_model.dart';
import 'package:fitflow/features/coupon/screens/coupon_screen.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CouponSelectorWidget extends StatefulWidget {
  final int? courseId;
  final CouponListTarget target;
  final VoidCallback? onViewAllTap;
  final EdgeInsetsGeometry padding;
  final ValueChanged<String>? onApplyCoupon;
  final String? appliedCode;

  const CouponSelectorWidget({
    super.key,
    this.onViewAllTap,
    this.padding = const .all(16),
    this.onApplyCoupon,
    this.courseId,
    required this.target,
    this.appliedCode,
  });

  @override
  State<CouponSelectorWidget> createState() => _CouponSelectorWidgetState();
}

class _CouponSelectorWidgetState extends State<CouponSelectorWidget> {
  final TextEditingController _couponController = TextEditingController();
  late String? _appliedCouponCode = widget.appliedCode;
  num? _discountAmount;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplyCouponCubit, ApplyCouponState>(
      listener: (context, state) {
        if (state is ApplyCouponSuccess) {
          _handleCouponResult(state.previewData);
        } else if (state is RemoveCouponSuccess) {
          _handleCouponRemoved();
        }
      },
      child: CustomCard(
        padding: widget.padding,
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                // Add Coupon with tag icon
                Row(
                  children: [
                    CustomImage(
                      AppIcons.tag,
                      width: 24,
                      height: 24,
                      color: context.color.onSurface,
                      fit: .none,
                    ),
                    const SizedBox(width: 8),
                    CustomText(
                      AppLabels.addCoupon.tr,
                      style: Theme.of(context).textTheme.bodyMedium!,
                      fontWeight: .w500,
                      color: context.color.onSurface,
                    ),
                  ],
                ),

                // View All text
                GestureDetector(
                  onTap: () async {
                    if (widget.onViewAllTap != null) {
                      widget.onViewAllTap!();
                    } else {
                      // Ensure we have a courseId before navigating
                      if (widget.courseId == null) {
                        return;
                      }

                      // Try to get the ApplyCouponCubit from parent context to share state
                      ApplyCouponCubit? applyCouponCubit;
                      try {
                        applyCouponCubit = context.read<ApplyCouponCubit>();
                      } catch (e) {
                        // Cubit not found in context, will create a new one
                        applyCouponCubit = null;
                      }

                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => FetchCouponsCubit(
                                  widget.target,
                                  widget.courseId!,
                                ),
                              ),
                              if (applyCouponCubit != null)
                                BlocProvider.value(value: applyCouponCubit)
                              else
                                BlocProvider(
                                  create: (context) => ApplyCouponCubit(),
                                ),
                            ],
                            child: const CouponScreen(),
                          ),
                        ),
                      );
                      // If a coupon was applied from CouponScreen, update the UI
                      if (result != null && mounted) {
                        _handleCouponResult(result);
                      }
                    }
                  },
                  child: CustomText(
                    AppLabels.viewAll.tr,
                    style: Theme.of(context).textTheme.bodyMedium!,
                    fontWeight: .w500,
                    color: context.color.onSurface,
                  ),
                ),
              ],
            ),

            // Divider with reduced height
            const Divider(height: 10),
            if (_appliedCouponCode != null) _buildCouponApplied(context),
            const SizedBox(height: 8),
            // Input field with Apply button
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _couponController,
                    hintText: AppLabels.enterCouponCode.tr,
                    suffixIcon: Padding(
                      padding: const .symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      child: CustomButton(
                        height: 32,
                        backgroundColor: context.color.primary,
                        onPressed: () {
                          if (widget.onApplyCoupon != null &&
                              _couponController.text.isNotEmpty) {
                            widget.onApplyCoupon!(_couponController.text);
                          }
                        },
                        title: AppLabels.apply.tr,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponApplied(BuildContext context) {
    return Padding(
      padding: const .only(top: 10.0),
      child: Row(
        spacing: 8,
        children: [
          CustomImage(AppIcons.check, color: context.color.success),
          CustomText(
            'Applied: $_appliedCouponCode',
            style: Theme.of(context).textTheme.bodyMedium!,
            color: context.color.success,
          ),
          if (_discountAmount != null)
            CustomText(
              '(-${_discountAmount!.toStringAsFixed(0)})',
              style: Theme.of(context).textTheme.bodyMedium!,
              fontWeight: .w600,
              color: context.color.success,
            ),

          const Spacer(),
          GestureDetector(
            onTap: () {
              _onRemoveCoupon();
            },
            child: CustomImage(
              AppIcons.deleteOutlined,
              width: 24,
              height: 24,
              color: context.color.error,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCouponResult(dynamic result) {
    if (result is PromoCodePreviewModel) {
      setState(() {
        // Get the first course's promo code info
        if (result.courses.isNotEmpty) {
          _appliedCouponCode = result.courses.first.promoCode?.code;
          _discountAmount = result.courses.first.promoDiscount;
          _couponController.text = _appliedCouponCode ?? '';
        }
      });
    }
  }

  void _handleCouponRemoved() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = null;
      _couponController.clear();
    });
  }

  void _onRemoveCoupon() {
    context.read<ApplyCouponCubit>().removeCoupon(target: widget.target);
  }
}
