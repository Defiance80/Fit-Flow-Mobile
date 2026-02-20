import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class PromoCodeModel extends Model {
  final int? id;
  final String? code;
  final String? message;
  final num? discountValue;
  final String? discountType;
  final num? discountAmount;

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.message,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      id: json.require<int?>('id'),
      code:
          json.require<String?>('code') ?? json.require<String?>('promo_code'),
      message: json.require<String?>('message'),
      discountType: json.require<String?>('discount_type'),
      discountValue: json.require<num?>('discount_value'),
      discountAmount: json.require<num?>('discount_amount'),
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

class CartCourseModel extends Model {
  final int id;
  final String title;
  final String slug;
  final String thumbnail;
  final num displayPrice;
  final num displayDiscountPrice;
  final num originalPrice;
  final num promoDiscount;
  final num finalPrice;
  final PromoCodeModel? promoCode;
  final num taxAmount;
  final String totalTaxPercentage;
  final String instructor;
  final bool isWishlisted;
  final int ratings;
  final num averageRating;

  CartCourseModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbnail,
    required this.displayPrice,
    required this.displayDiscountPrice,
    required this.originalPrice,
    required this.promoDiscount,
    required this.finalPrice,
    this.promoCode,
    required this.taxAmount,
    required this.totalTaxPercentage,
    required this.instructor,
    required this.isWishlisted,
    required this.ratings,
    required this.averageRating,
  });

  factory CartCourseModel.fromJson(Map<String, dynamic> json) {
    return CartCourseModel(
      id: json.require<int>('id'),
      title: json.require<String>('title'),
      slug: json.require<String>('slug'),
      thumbnail: json.require<String?>('thumbnail') ?? '',
      displayPrice: json.require<num>('display_price').toDouble(),
      displayDiscountPrice: json
          .require<num>('display_discount_price')
          .toDouble(),
      originalPrice: json.require<num>('original_price').toDouble(),
      promoDiscount: json.require<num>('promo_discount').toDouble(),
      finalPrice: json.require<num>('final_price').toDouble(),
      promoCode: json.optional<Map<String, dynamic>?>('promo_code') != null
          ? PromoCodeModel.fromJson(
              json.optional<Map<String, dynamic>>('promo_code')!,
            )
          : null,
      taxAmount: json.require<num>('tax_amount').toDouble(),
      totalTaxPercentage: json['total_tax_percentage'] is String
          ? json.require<String>('total_tax_percentage')
          : json.require<num>('total_tax_percentage').toString(),
      instructor: json.require<String>('instructor'),
      isWishlisted: json.require<bool>('is_wishlisted'),
      ratings: json.require<int>('ratings'),
      averageRating: json.require<num>('average_rating').toDouble(),
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
    'ratings': ratings,
    'average_rating': averageRating,
  };

  num get effectivePrice =>
      displayDiscountPrice > 0 ? displayDiscountPrice : displayPrice;
}

class CartResponseModel extends Model {
  final List<CartCourseModel> courses;
  final num subtotalPrice;
  final num discountPrice;
  final num totalPrice;
  final num promoDiscount;
  final num displayPrice;
  final PromoCodeModel? promoCode;
  final String? taxType;
  final num? totalTaxAmount;
  final num? finalTotal;

  CartResponseModel({
    required this.courses,
    required this.subtotalPrice,
    required this.discountPrice,
    required this.totalPrice,
    required this.promoDiscount,
    required this.displayPrice,
    this.promoCode,
    this.taxType,
    this.totalTaxAmount,
    this.finalTotal,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      courses: json
          .require<List>('courses')
          .map(
            (course) =>
                CartCourseModel.fromJson(course as Map<String, dynamic>),
          )
          .toList(),
      displayPrice: json.require('total_display_price'),
      subtotalPrice: json.require<num>('subtotal_price').toDouble(),
      discountPrice: json.require<num>('discount').toDouble(),
      totalPrice: json.require<num>('total_price').toDouble(),
      promoDiscount: json.require<num>('promo_discount'),
      promoCode:
          (json['promo_discounts'] is List &&
              (json['promo_discounts'] as List).isNotEmpty)
          ? PromoCodeModel.fromJson(
              (json['promo_discounts'] as List).first as Map<String, dynamic>,
            )
          : null,
      taxType: json.require<String?>('tax_type'),
      totalTaxAmount: json.require<num?>('total_tax_amount'),
      finalTotal: json.require<num?>('final_total'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'courses': courses.map((course) => course.toJson()).toList(),
    'subtotal_price': subtotalPrice,
    'discount_price': discountPrice,
    'total_price': totalPrice,
    'promo_discount': promoDiscount,
    'promo_code': promoCode?.toJson(),
    'tax_type': taxType,
    'total_tax_amount': totalTaxAmount,
    'final_total': finalTotal,
  };
}
