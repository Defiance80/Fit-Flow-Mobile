import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/enums.dart';

import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/cubit/checkout_cubit.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/features/cart/models/cart_summary_model.dart';
import 'package:elms/features/cart/models/checkout_data_model.dart';
import 'package:elms/features/cart/repository/checkout_repository.dart';
import 'package:elms/features/cart/screens/checkout_screen.dart';
import 'package:elms/features/cart/widgets/bill_details_card.dart';
import 'package:elms/features/cart/widgets/cart_course_card.dart';
import 'package:elms/features/cart/widgets/checkout_bar.dart';
import 'package:elms/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:elms/features/course/widgets/coupon_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static Widget route() => BlocProvider(
    create: (context) => ApplyCouponCubit(),
    child: const CartScreen(),
  );

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  CartSuccess? success;

  void _onTapRefresh() {
    context.read<CartCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<CartCubit, CartState>(
          listener: (context, state) {
            // Handle any state changes or errors if needed
          },
        ),
        BlocListener<ApplyCouponCubit, ApplyCouponState>(
          listener: (context, state) {
            if (state is ApplyCouponSuccess) {
              // Refresh cart to get updated prices with coupon applied
              context.read<CartCubit>().fetch();
            } else if (state is ApplyCouponFail) {
              // Show error message
              Get.snackbar(
                AppLabels.error.tr,
                state.error.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
            } else if (state is RemoveCouponSuccess) {
              // Refresh cart to get updated prices after removing coupon
              context.read<CartCubit>().fetch();
            } else if (state is RemoveCouponFail) {
              // Show error message
              Get.snackbar(
                AppLabels.error.tr,
                state.error.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar(title: AppLabels.myCart.tr),
        body: RefreshIndicator(
          onRefresh: () async {
            _onTapRefresh();
          },
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CartFail) {
                return CustomErrorWidget(
                  error: state.error.toString(),
                  onRetry: _onTapRefresh,
                );
              }
              if (state is CartSuccess ||
                  state is UpdateCartInProgress ||
                  state is UpdateCartFail) {
                //
                if (state is CartSuccess) {
                  success = state;
                }
                //
                if (success == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                //
                if (success!.cart.courses.isEmpty) {
                  return const CustomNoDataWidget(
                    titleKey: AppLabels.yourCartIsEmpty,
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const .all(16),
                      sliver: SliverList.separated(
                        itemBuilder: (context, index) => CartCourseCard(
                          course: success!.cart.courses[index],
                          onRemoveFromCart: () {
                            context.read<CartCubit>().removeFromCart(
                              success!.cart.courses[index].id,
                            );
                          },
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemCount: success!.cart.courses.length,
                      ),
                    ),
                    SliverPadding(
                      padding: const .symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            CouponSelectorWidget(
                              target: CouponListTarget.cart,
                              appliedCode: success!.cart.promoCode?.code,
                              courseId: success!.cart.courses.isNotEmpty
                                  ? success!.cart.courses.first.id
                                  : null,
                              onApplyCoupon: _onApplyCoupon,
                            ),
                            const SizedBox(height: 16),
                            BillDetailsCard(
                              summary: _createCartSummary(success!.cart),
                            ),
                            const SizedBox(height: kToolbarHeight + 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Container();
            },
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 6),
          child: _buildBottomBar(context),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is CartSuccess ||
            state is UpdateCartInProgress ||
            state is UpdateCartFail) {
          final CartSuccess? currentState = state is CartSuccess
              ? state
              : success;

          if (currentState == null || currentState.cart.courses.isEmpty) {
            return const SizedBox.shrink();
          }

          // Calculate final total including tax if exclusive
          final finalTotal = _calculateFinalTotal(currentState.cart);

          return CheckoutBar(
            totalAmount: finalTotal,
            onCheckout: _onTapCheckout,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  double _calculateFinalTotal(CartResponseModel cart) {
    // Use final_total from API if available, otherwise fall back to totalPrice
    return cart.finalTotal!.toDouble();
  }

  CartSummaryModel _createCartSummary(CartResponseModel cart) {
    // Calculate taxes/charges as the difference between totalPrice and subtotalPrice minus discounts
    final taxesAndCharges =
        cart.totalPrice - cart.subtotalPrice + cart.discountPrice;

    return CartSummaryModel(
      discount: cart.discountPrice,
      appliedCouponCode: cart.promoCode?.code,
      couponDiscount: cart.promoDiscount.toDouble(),
      displayPrice: cart.displayPrice,
      subtotal: cart.displayPrice.toDouble(),
      grandTotal: cart.totalPrice,
      totalPay: cart.totalPrice,
      taxType: cart.taxType,
      totalTaxAmount: cart.totalTaxAmount,
      finalTotal: cart.finalTotal,
    );
  }

  void _onApplyCoupon(String couponCode) {
    if (success != null &&
        couponCode.isNotEmpty &&
        success!.cart.courses.isNotEmpty) {
      context.read<ApplyCouponCubit>().applyCouponByCode(
        code: couponCode,
        courseId: success!.cart.courses.first.id,
        target: CouponListTarget.cart,
      );
    }
  }

  void _onTapCheckout() {
    if (success == null) return;

    final checkoutData = CheckoutDataModel.fromCart(success!.cart);
    final applyCouponCubit = context.read<ApplyCouponCubit>();
    final cartCubit = context.read<CartCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CheckoutCubit(CheckoutRepository()),
            ),
            BlocProvider.value(value: applyCouponCubit),
            BlocProvider.value(value: cartCubit),
          ],
          child: CheckoutScreen(checkoutData: checkoutData),
        ),
      ),
    );
  }
}
