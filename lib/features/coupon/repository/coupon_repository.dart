import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/data_class.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/features/coupon/models/coupon_model.dart';
import 'package:fitflow/features/coupon/models/promo_code_preview_model.dart';

class CouponRepository {
  Future<DataClass<CouponModel>> fetchCoupons({
    required int? courseId,
    required CouponListTarget target,
  }) async {
    final Map<String, dynamic> response = await Api.get(
      target == CouponListTarget.course
          ? Apis.couponsForCourse
          : Apis.getValidCoupons,
      data: {ApiParams.courseId: courseId},
    );

    if (target == CouponListTarget.course) {
      final data = response['data'] as Map<String, dynamic>;
      return DataClass(
        data: (data['promo_codes'] as List)
            .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else {
      return DataClass.fromResponse(CouponModel.fromJson, response);
    }
  }

  Future<PromoCodePreviewModel> applyCoupon({
    int? promoCodeId,
    String? code,
    required int courseId,
    CouponListTarget target = CouponListTarget.course,
  }) async {
    // Use different API based on target
    final String apiEndpoint = target == CouponListTarget.cart
        ? Apis.applyCouponCart
        : Apis.applyCoupon;

    final Map<String, dynamic> response = await Api.post(
      apiEndpoint,
      data: {
        'promo_code_id': promoCodeId,
        'promo_code': code,
        'course_id': courseId,
      },
    );

    return PromoCodePreviewModel.fromJson(response['data']);
  }

  Future<void> removeCoupon({
    required CouponListTarget target,
  }) async {
    if (target == CouponListTarget.cart) {
      // Call the cart/remove-promo API for cart
      await Api.post(Apis.removeCouponCart, data: {});
    }
    // For course context, we don't need to call any API
  }
}
