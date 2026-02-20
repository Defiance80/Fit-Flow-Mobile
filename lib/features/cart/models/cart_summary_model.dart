import 'package:elms/common/models/blueprints.dart';

class CartSummaryModel extends Model {
  CartSummaryModel({
    required this.subtotal,
    required this.grandTotal,
    this.appliedCouponCode,
    this.couponDiscount,
    required this.totalPay,
    required this.displayPrice,
    required this.discount,
    this.taxType,
    this.totalTaxAmount,
    this.finalTotal,
  });

  final num subtotal;
  final num displayPrice;
  final num grandTotal;
  final String? appliedCouponCode;
  final num? couponDiscount;
  final num totalPay;
  final num discount;
  final String? taxType;
  final num? totalTaxAmount;
  final num? finalTotal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartSummaryModel &&
          runtimeType == other.runtimeType &&
          subtotal == other.subtotal &&
          grandTotal == other.grandTotal &&
          appliedCouponCode == other.appliedCouponCode &&
          couponDiscount == other.couponDiscount &&
          totalPay == other.totalPay;

  @override
  int get hashCode =>
      subtotal.hashCode ^
      grandTotal.hashCode ^
      appliedCouponCode.hashCode ^
      couponDiscount.hashCode ^
      totalPay.hashCode;

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      discount: json['discount'],
      displayPrice: json['display_price'],
      subtotal: (json['subtotal'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      appliedCouponCode: json['appliedCouponCode'] as String?,
      couponDiscount: json['couponDiscount'] != null
          ? (json['couponDiscount'] as num).toDouble()
          : null,
      totalPay: (json['totalPay'] as num).toDouble(),
      taxType: json['taxType'] as String?,
      totalTaxAmount: json['totalTaxAmount'] as num?,
      finalTotal: json['finalTotal'] as num?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'grandTotal': grandTotal,
      'appliedCouponCode': appliedCouponCode,
      'couponDiscount': couponDiscount,
      'totalPay': totalPay,
      'taxType': taxType,
      'totalTaxAmount': totalTaxAmount,
      'finalTotal': finalTotal,
    };
  }
}
