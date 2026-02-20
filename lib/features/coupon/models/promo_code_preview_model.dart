import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PromoCodePreviewModel extends Model {
  final List<CourseWithPromo> courses;
  final num totalDisplayPrice;
  final num subtotalPrice;
  final num promoDiscount;
  final num discount;
  final num totalPrice;
  final List<PromoDiscount> promoDiscounts;

  PromoCodePreviewModel({
    required this.courses,
    required this.totalDisplayPrice,
    required this.subtotalPrice,
    required this.promoDiscount,
    required this.discount,
    required this.totalPrice,
    required this.promoDiscounts,
  });

  factory PromoCodePreviewModel.fromJson(Map<String, dynamic> json) {
    return PromoCodePreviewModel(
      courses: (json.require<List>(
        'courses',
      )).map((e) => CourseWithPromo.fromJson(e)).toList(),
      totalDisplayPrice: json.require<num>('total_display_price'),
      subtotalPrice: json.require<num>('subtotal_price'),
      promoDiscount: json.require<num>('promo_discount'),
      discount: json.require<num>('discount'),
      totalPrice: json.require<num>('total_price'),
      promoDiscounts: (json.require<List>(
        'promo_discounts',
      )).map((e) => PromoDiscount.fromJson(e)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'courses': courses.map((e) => e.toJson()).toList(),
    'total_display_price': totalDisplayPrice,
    'subtotal_price': subtotalPrice,
    'promo_discount': promoDiscount,
    'discount': discount,
    'total_price': totalPrice,
    'promo_discounts': promoDiscounts.map((e) => e.toJson()).toList(),
  };
}

class CourseWithPromo extends Model {
  final int id;
  final String title;
  final String slug;
  final String? thumbnail;
  final num displayPrice;
  final num displayDiscountPrice;
  final num originalPrice;
  final num promoDiscount;
  final num finalPrice;
  final PromoCodeInfo? promoCode;
  final num taxAmount;
  final String totalTaxPercentage;
  final String instructor;
  final bool isWishlisted;

  CourseWithPromo({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbnail,
    required this.displayPrice,
    required this.displayDiscountPrice,
    required this.originalPrice,
    required this.promoDiscount,
    required this.finalPrice,
    required this.promoCode,
    required this.taxAmount,
    required this.totalTaxPercentage,
    required this.instructor,
    required this.isWishlisted,
  });

  factory CourseWithPromo.fromJson(Map<String, dynamic> json) {
    return CourseWithPromo(
      id: json.require<int>('id'),
      title: json.require<String>('title'),
      slug: json.require<String>('slug'),
      thumbnail: json.require<String?>('thumbnail'),
      displayPrice: json.require<num>('display_price'),
      displayDiscountPrice: json.require<num>('display_discount_price'),
      originalPrice: json.require<num>('original_price'),
      promoDiscount: json.require<num>('promo_discount'),
      finalPrice: json.require<num>('final_price'),
      promoCode: json['promo_code'] == null
          ? null
          : PromoCodeInfo.fromJson(
              json.require<Map<String, dynamic>>('promo_code'),
            ),
      taxAmount: json.require<num>('tax_amount'),
      totalTaxPercentage: json.require<String>('total_tax_percentage'),
      instructor: json.require<String>('instructor'),
      isWishlisted: json.require<bool>('is_wishlisted'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'thumbnail': thumbnail,
    'display_price': displayPrice,
    'display_discount_price': displayDiscountPrice,
    'original_price': originalPrice,
    'promo_discount': promoDiscount,
    'final_price': finalPrice,
    'promo_code': promoCode?.toJson(),
    'tax_amount': taxAmount,
    'total_tax_percentage': totalTaxPercentage,
    'instructor': instructor,
    'is_wishlisted': isWishlisted,
  };
}

class PromoCodeInfo extends Model {
  final int id;
  final String code;
  final String message;
  final String discountType;
  final num discountValue;
  final num discountAmount;

  PromoCodeInfo({
    required this.id,
    required this.code,
    required this.message,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  factory PromoCodeInfo.fromJson(Map<String, dynamic> json) {
    return PromoCodeInfo(
      id: json.require<int>('id'),
      code: json.require<String>('code'),
      message: json.require<String>('message'),
      discountType: json.require<String>('discount_type'),
      discountValue: json.require<num>('discount_value'),
      discountAmount: json.require<num>('discount_amount'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'message': message,
    'discount_type': discountType,
    'discount_value': discountValue,
    'discount_amount': discountAmount,
  };
}

class PromoDiscount extends Model {
  final int courseId;
  final String courseTitle;
  final String promoCode;
  final num discountAmount;

  PromoDiscount({
    required this.courseId,
    required this.courseTitle,
    required this.promoCode,
    required this.discountAmount,
  });

  factory PromoDiscount.fromJson(Map<String, dynamic> json) {
    return PromoDiscount(
      courseId: json.require<int>('course_id'),
      courseTitle: json.require<String>('course_title'),
      promoCode: json.require<String>('promo_code'),
      discountAmount: json.require<num>('discount_amount'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'course_title': courseTitle,
    'promo_code': promoCode,
    'discount_amount': discountAmount,
  };
}
