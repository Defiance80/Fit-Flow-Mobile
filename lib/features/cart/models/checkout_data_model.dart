import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/features/cart/models/cart_response_model.dart';
import 'package:fitflow/features/cart/models/cart_summary_model.dart';
import 'package:fitflow/features/coupon/models/promo_code_preview_model.dart';

class CheckoutDataModel extends Model {
  final List<CartCourseModel> courses;
  final CartSummaryModel summary;
  final int? promoCodeId;
  final PromoCodePreviewModel? promoPreview;

  CheckoutDataModel({
    required this.courses,
    required this.summary,
    this.promoCodeId,
    this.promoPreview,
  });

  factory CheckoutDataModel.fromCart(CartResponseModel cart) {
    return CheckoutDataModel(
      courses: cart.courses,
      summary: CartSummaryModel(
        discount: cart.discountPrice,
        displayPrice: cart.displayPrice,
        subtotal: cart.subtotalPrice,
        grandTotal: cart.totalPrice,
        totalPay: cart.totalPrice,
        couponDiscount: cart.discountPrice > 0 ? cart.discountPrice : null,
        appliedCouponCode: cart.discountPrice > 0 ? '' : null,
        taxType: cart.taxType,
        totalTaxAmount: cart.totalTaxAmount,
        finalTotal: cart.finalTotal,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'courses': courses.map((course) => course.toJson()).toList(),
    'summary': summary.toJson(),
    'promoCodeId': promoCodeId,
    'promoPreview': promoPreview?.toJson(),
  };

  factory CheckoutDataModel.fromJson(Map<String, dynamic> json) {
    return CheckoutDataModel(
      courses: (json['courses'] as List)
          .map((course) => CartCourseModel.fromJson(course))
          .toList(),
      summary: CartSummaryModel.fromJson(json['summary']),
      promoCodeId: json['promoCodeId'] as int?,
      promoPreview: json['promoPreview'] != null
          ? PromoCodePreviewModel.fromJson(json['promoPreview'])
          : null,
    );
  }
}
