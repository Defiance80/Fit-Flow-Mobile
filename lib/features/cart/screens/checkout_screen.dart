import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/common/enums.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/cart/cubit/cart_cubit.dart';
import 'package:elms/features/cart/models/cart_response_model.dart';
import 'package:elms/features/cart/models/checkout_data_model.dart';
import 'package:elms/features/cart/models/place_order_response_model.dart';
import 'package:elms/features/cart/cubit/checkout_cubit.dart';
import 'package:elms/features/cart/repository/checkout_repository.dart';
import 'package:elms/features/cart/screens/payment_webview_screen.dart';
import 'package:elms/features/coupon/cubits/apply_coupon_cubit.dart';
import 'package:elms/features/cart/widgets/checkout_bar.dart';
import 'package:elms/features/cart/widgets/checkout_result_bottom_sheet.dart';
import 'package:elms/features/settings/cubit/settings_cubit.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:elms/features/settings/models/system_setting_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:elms/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  final CheckoutDataModel? checkoutData;
  final CheckoutType checkoutType;

  const CheckoutScreen({
    super.key,
    this.checkoutData,
    this.checkoutType = CheckoutType.cart,
  });

  static Widget route() {
    final args = Get.arguments;
    CheckoutDataModel? checkoutData;
    CheckoutType checkoutType = CheckoutType.cart;

    if (args is Map<String, dynamic>) {
      checkoutData = args['checkoutData'];
      checkoutType = args['checkoutType'] ?? CheckoutType.cart;
    } else if (args is CheckoutDataModel) {
      // Backward compatibility
      checkoutData = args;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CheckoutCubit(CheckoutRepository())),
        BlocProvider(create: (context) => ApplyCouponCubit()),
      ],
      child: CheckoutScreen(
        checkoutData: checkoutData,
        checkoutType: checkoutType,
      ),
    );
  }

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedPaymentMethod;
  CheckoutDataModel? data;

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().refreshUserDetails();
    data = widget.checkoutData;
    _initializePaymentMethod();
  }

  void _initializePaymentMethod() {
    // Check if wallet has sufficient balance and set it as default
    final walletBalance =
        context.read<AuthenticationCubit>().walletBalance ?? 0;
    final totalPay = _getTotalPay();

    if (walletBalance >= totalPay) {
      selectedPaymentMethod = 'wallet';
      return;
    }

    // Otherwise, use the first active payment method
    final settingsState = context.read<SettingsCubit>().state;
    if (settingsState is SettingsSuccess) {
      final activePayments = settingsState.settings.activePaymentSettings;
      if (activePayments != null && activePayments.isNotEmpty) {
        selectedPaymentMethod = activePayments.first.paymentGateway;
      }
    }
  }

  List<PaymentSettingModel> _getActivePaymentMethods() {
    final settingsState = context.read<SettingsCubit>().state;
    if (settingsState is SettingsSuccess) {
      return settingsState.settings.activePaymentSettings ?? [];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          ///This will be called when checkout api success because successful response means record is registered in panel
          _handlePayment(state.orderResponse);
        } else if (state is CheckoutFail) {}
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppLabels.checkout.tr,
          showBackButton: true,
        ),
        body: data?.courses.isEmpty != false
            ? Center(
                child: CustomText(
                  AppLabels.yourCartIsEmpty.tr,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
              )
            : BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  if (state is CheckoutInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        if (_getTotalPay() > 0) ...[
                          _buildPaymentMethodsSection(),
                          const SizedBox(height: 16),
                        ],
                        if (data != null) ...[
                          _buildOrderDetailsSection(),
                          const SizedBox(height: 16),
                          _buildBillDetailsSection(),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
        bottomNavigationBar: data?.courses.isNotEmpty == true
            ? Padding(
                padding: const .all(16),
                child: BlocBuilder<CheckoutCubit, CheckoutState>(
                  builder: (context, state) {
                    return CheckoutBar(
                      totalAmount: _getTotalPay(),
                      buttonText: AppLabels.proceedToCheckout.tr,
                      onCheckout: _onTapProceedToCheckout,
                      isLoading: state is CheckoutInProgress,
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    final activePaymentMethods = _getActivePaymentMethods();

    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            AppLabels.paymentDetails.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          // Wallet payment option (always at index 0)
          _buildWalletPaymentOption(),
          // Other payment methods
          ...activePaymentMethods.asMap().entries.map((entry) {
            final PaymentSettingModel paymentMethod = entry.value;
            final String gatewayName = paymentMethod.paymentGateway ?? '';
            final String displayName = _getPaymentGatewayDisplayName(
              gatewayName,
            );
            return Column(
              children: [
                const SizedBox(height: 8),
                _buildPaymentMethodOption(gatewayName, displayName),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _getPaymentGatewayDisplayName(String gateway) {
    switch (gateway.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'Paypal';
      case 'razorpay':
        return 'Razorpay';
      default:
        // Capitalize first letter of gateway name
        if (gateway.isEmpty) return gateway;
        return gateway[0].toUpperCase() + gateway.substring(1).toLowerCase();
    }
  }

  Widget _buildPaymentMethodOption(String value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: CustomCard(
        borderRadius: 4,
        padding: const .symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: .circle,
                    border: Border.all(
                      color: context.color.primary,
                      width: 1.5,
                    ),
                  ),
                  child: selectedPaymentMethod == value
                      ? Container(
                          margin: const .all(4),
                          decoration: BoxDecoration(
                            shape: .circle,
                            color: context.color.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                CustomText(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: .w500,
                    color: context.color.onSurface,
                  ),
                ),
              ],
            ),
            _buildPaymentLogo(value),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLogo(String method) {
    return Container(
      padding: const .all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: CustomText(
        method.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: .bold,
          color: context.color.primary,
        ),
      ),
    );
  }

  Widget _buildWalletPaymentOption() {
    final walletBalance =
        context.read<AuthenticationCubit>().walletBalance ?? 0;
    final totalPay = _getTotalPay();
    final isEnabled = walletBalance >= totalPay;
    const String walletValue = 'wallet';

    return GestureDetector(
      onTap: isEnabled
          ? () {
              setState(() {
                selectedPaymentMethod = walletValue;
              });
            }
          : null,
      child: CustomCard(
        borderRadius: 4,
        padding: const .symmetric(horizontal: 16, vertical: 8),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: .circle,
                      border: Border.all(
                        color: isEnabled
                            ? context.color.primary
                            : context.color.onSurface.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: selectedPaymentMethod == walletValue && isEnabled
                        ? Container(
                            margin: const .all(4),
                            decoration: BoxDecoration(
                              shape: .circle,
                              color: context.color.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    '${AppLabels.wallet.tr} (${walletBalance.toStringAsFixed(2).currency})',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: .w500,
                      color: isEnabled
                          ? context.color.onSurface
                          : context.color.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              _buildPaymentLogo(AppLabels.wallet.tr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            AppLabels.orderDetails.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...data!.courses.map((course) => _buildCourseItem(course)),
        ],
      ),
    );
  }

  Widget _buildCourseItem(CartCourseModel course) {
    return Padding(
      padding: const .only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImage(
              course.thumbnail,
              width: 60,
              height: 45,
              fit: .cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  course.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: .w500,
                    color: context.color.onSurface,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                CustomText(
                  course.instructor,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: context.color.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          CustomText(
            course.effectivePrice.toStringAsFixed(2).currency,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: .bold,
              color: context.color.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetailsSection() {
    return CustomCard(
      borderRadius: 4,
      padding: const .all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            AppLabels.billDetails.tr,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: .w500,
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow(
            AppLabels.subtotal.tr,
            _getSubtotal().toStringAsFixed(2).currency,
          ),
          const SizedBox(height: 8),
          if (_getTaxType() != null &&
              _getTaxType()!.toLowerCase() == 'exclusive' &&
              _getTotalTaxAmount() != null &&
              _getTotalTaxAmount()! > 0) ...[
            _buildBillRow(
              AppLabels.taxes.tr,
              _getTotalTaxAmount()!.toStringAsFixed(2).currency,
            ),
            const SizedBox(height: 8),
          ],
          if (_getCouponDiscount() != null && _getCouponDiscount()! > 0) ...[
            _buildBillRow(
              '${AppLabels.coupon.tr} Discount',
              '-${_getCouponDiscount()!.toStringAsFixed(2).currency}',
              isDiscount: true,
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildBillRow(
            AppLabels.totalPay.tr,
            _getTotalPay().toStringAsFixed(2).currency,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  // Helper methods to get values from ApplyCouponCubit or CartSummaryModel
  num _getSubtotal() {
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    if (applyCouponState is ApplyCouponSuccess) {
      return applyCouponState.previewData.subtotalPrice;
    }
    return data!.summary.subtotal;
  }

  num? _getCouponDiscount() {
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    if (applyCouponState is ApplyCouponSuccess) {
      return applyCouponState.previewData.promoDiscount;
    }
    return data!.summary.couponDiscount;
  }

  num _getTotalPay() {
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    if (applyCouponState is ApplyCouponSuccess) {
      return applyCouponState.previewData.totalPrice;
    }
    // Use finalTotal if available, otherwise fall back to totalPay
    return data?.summary.finalTotal ?? data!.summary.totalPay;
  }

  String? _getTaxType() {
    return data?.summary.taxType;
  }

  num? _getTotalTaxAmount() {
    return data?.summary.totalTaxAmount;
  }

  Widget _buildBillRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: isTotal ? .bold : .normal,
            color: context.color.onSurface,
          ),
        ),
        CustomText(
          amount,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: isTotal ? .bold : .w500,
            color: isDiscount
                ? Colors.green
                : isTotal
                ? context.color.primary
                : context.color.onSurface,
          ),
        ),
      ],
    );
  }

  void _onTapProceedToCheckout() {
    final totalPay = _getTotalPay();

    // Validate payment method is selected only for paid courses
    if (totalPay > 0 &&
        (selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty)) {
      UiUtils.showSnackBar('Please select a payment method', isError: true);
      return;
    }

    final checkoutCubit = context.read<CheckoutCubit>();

    // Get promo code IDs from ApplyCouponCubit if applied
    List<String>? promoCodeIds;
    final applyCouponState = context.read<ApplyCouponCubit>().state;
    if (applyCouponState is ApplyCouponSuccess) {
      promoCodeIds = [
        ?applyCouponState.previewData.courses.first.promoCode?.id.toString(),
      ];
    } else if (data?.promoCodeId != null) {
      // Fallback to checkout data if available
      promoCodeIds = [data!.promoCodeId.toString()];
    }

    // For free courses, use 'free' as payment method if none selected
    final paymentMethod = totalPay > 0
        ? selectedPaymentMethod!
        : (selectedPaymentMethod ?? 'free');

    if (widget.checkoutType == CheckoutType.directEnroll) {
      // Direct enroll scenario - get course ID from checkout data
      final courseId = data?.courses.first.id;
      if (courseId != null) {
        checkoutCubit.placeOrderForDirectEnroll(
          paymentMethod: paymentMethod,
          courseId: courseId,
          promoCodeIds: promoCodeIds,
        );
      }
    } else {
      // Cart scenario
      checkoutCubit.placeOrderFromCart(
        paymentMethod: paymentMethod,
        promoCodeIds: promoCodeIds,
      );
    }
  }

  void _handlePayment(PlaceOrderResponse response) async {
    if (response.hasPaymentUrl && response.orderNumber != null) {
      // Navigate to payment webview screen
      final result = await Get.toNamed(
        AppRoutes.paymentWebViewScreen,
        arguments: {
          'paymentUrl': response.orderUrl!,
          'orderNumber': response.orderNumber!,
        },
      );

      if (result case final PaymentGatewayCallbackResponse data) {
        if (data.status == PaymentStatus.completed) {
          // Refresh user details if payment was made through wallet
          if (selectedPaymentMethod == 'wallet' && mounted) {
            try {
              await context.read<AuthenticationCubit>().refreshUserDetails();
            } catch (e) {
              // Continue even if refresh fails
            }
          }

          // Clear cart after successful payment for cart checkout
          if (widget.checkoutType == CheckoutType.cart && mounted) {
            try {
              await context.read<CartCubit>().clearCart();
            } catch (e) {
              // Continue even if clear cart fails
            }
          }

          await _showResultBottomSheet(
            isSuccess: true,
            amount: data.amount.toDouble(),
            txn: data.orderNumber,
          );
        } else if (data.status == PaymentStatus.paymentFailed) {
          await _showResultBottomSheet(
            isSuccess: false,
            amount: data.amount.toDouble(),
            txn: data.orderNumber,
          );
        }
      }
    } else {
      // No payment URL - show result bottom sheet directly
      final isSuccess = !response.error;

      // Refresh user details if payment was made through wallet and successful
      if (isSuccess && selectedPaymentMethod == 'wallet' && mounted) {
        try {
          await context.read<AuthenticationCubit>().refreshUserDetails();
        } catch (e) {
          // Continue even if refresh fails
        }
      }

      // Clear cart after successful payment for cart checkout
      if (isSuccess && widget.checkoutType == CheckoutType.cart && mounted) {
        try {
          await context.read<CartCubit>().clearCart();
        } catch (e) {
          // Continue even if clear cart fails
        }
      }

      await _showResultBottomSheet(
        isSuccess: isSuccess,
        amount: num.parse(response.order?.totalPrice ?? '0').toDouble(),
        txn: response.orderId ?? '',
      );
    }
  }

  Future<void> _showResultBottomSheet({
    required bool isSuccess,
    required String txn,
    required double amount,
  }) async {
    if (mounted) {
      final result = await UiUtils.showCustomBottomSheet<bool?>(
        context,
        enableDrag: false,
        child: CheckoutResultBottomSheet(
          isSuccess: isSuccess,
          amount: amount,
          txn: txn,
          onAction: () async {
            // Close bottom sheet first
            Get.back();

            await Get.offAllNamed(AppRoutes.mainActivity);
          },
        ),
      );

      // Handle when user taps outside (dismisses the bottom sheet)
      // If result is null, it means the sheet was dismissed by tapping outside
      if (result == null && mounted) {
        // Navigate to home screen
        await Get.offAllNamed(AppRoutes.mainActivity);
      }
    }
  }
}
