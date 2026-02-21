import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:get/get.dart';

class TransactionHistoryModel extends Model {
  final int orderId;
  final String orderNumber;
  final String status;
  final String totalPrice;
  final String taxPrice;
  final num totalDiscount;
  final num finalTotal;
  final DateTime transactionDate;
  final String transactionDateFormatted;
  final String transactionDateHuman;
  final List<TransactionCourseModel> courses;
  final Map? promoCode;
  final String? paymentMethod;

  TransactionHistoryModel({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.totalPrice,
    required this.taxPrice,
    required this.totalDiscount,
    required this.finalTotal,
    required this.transactionDate,
    required this.transactionDateFormatted,
    required this.transactionDateHuman,
    required this.courses,
    this.promoCode,
    this.paymentMethod,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      orderId: json['order_id'],
      orderNumber: json['order_number'],
      status: json['status'],
      totalPrice: json['total_price'].toString(),
      taxPrice: json['tax_price'].toString(),
      totalDiscount: ((json['total_discount'] ?? 0) as num).toDouble(),
      finalTotal: ((json['final_total'] ?? 0) as num).toDouble(),
      transactionDate: DateTime.parse(json['transaction_date']),
      transactionDateFormatted: json['transaction_date_formatted'],
      transactionDateHuman: json['transaction_date_human'],
      courses: (json['courses'] as List<dynamic>)
          .map((e) => TransactionCourseModel.fromJson(e))
          .toList(),
      promoCode: json['promo_code'],
      paymentMethod: json['payment_method'],
    );
  }

  /// Converts the string status to TransactionStatus enum
  TransactionStatus get transactionStatus {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('success') ||
        statusLower.contains('completed') ||
        statusLower.contains('paid')) {
      return TransactionStatus.success;
    } else if (statusLower.contains('pending') ||
        statusLower.contains('processing')) {
      return TransactionStatus.pending;
    } else {
      return TransactionStatus.failed;
    }
  }

  /// Gets the display name for payment method
  String get paymentMethodDisplay {
    if (paymentMethod == null || paymentMethod!.isEmpty) {
      return AppLabels.notAvailable.tr;
    }
    // Capitalize first letter
    return paymentMethod![0].toUpperCase() + paymentMethod!.substring(1);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'status': status,
      'total_price': totalPrice,
      'tax_price': taxPrice,
      'total_discount': totalDiscount,
      'final_total': finalTotal,
      'transaction_date': transactionDate.toIso8601String(),
      'transaction_date_formatted': transactionDateFormatted,
      'transaction_date_human': transactionDateHuman,
      'courses': courses.map((e) => e.toJson()).toList(),
      'promo_code': promoCode,
      'payment_method': paymentMethod,
    };
  }
}

class TransactionCourseModel {
  final int courseId;
  final String title;
  final String price;
  final String image;
  final String courseType;
  final String creatorName;
  final bool refundEnabled;
  final int refundPeriodDays;
  final bool isRefundEligible;
  final num refundDaysRemaining;
  final bool hasRefundRequest;
  final RefundStatus refundRequestStatus;
  final int? refundRequestId;
  final String? refundAdminNotes;
  final DateTime purchaseDate;

  TransactionCourseModel({
    required this.courseId,
    required this.title,
    required this.price,
    required this.image,
    required this.courseType,
    required this.creatorName,
    required this.refundEnabled,
    required this.refundPeriodDays,
    required this.isRefundEligible,
    required this.refundDaysRemaining,
    required this.hasRefundRequest,
    required this.refundRequestStatus,
    this.refundRequestId,
    this.refundAdminNotes,
    required this.purchaseDate,
  });

  factory TransactionCourseModel.fromJson(Map<String, dynamic> json) {
    return TransactionCourseModel(
      courseId: json['course_id'],
      title: json['title'],
      price: json['price'],
      image: json['image'] ?? '',
      courseType: json['course_type'] ?? '',
      creatorName: json['creator_name'] ?? '',
      refundEnabled: json['refund_enabled'] ?? false,
      refundPeriodDays: json['refund_period_days'] ?? 0,
      isRefundEligible: json['is_refund_eligible'] ?? false,
      refundDaysRemaining: json['refund_days_remaining'] ?? 0,
      hasRefundRequest: json['has_refund_request'] ?? false,
      refundRequestStatus: RefundStatus.fromString(
        json['refund_request_status'],
      ),
      refundRequestId: json['refund_request_id'],
      refundAdminNotes: json['refund_admin_notes'],
      purchaseDate: DateTime.parse(json['purchase_date']),
    );
  }

  /// Determines if the user can request a refund for this course
  /// Conditions:
  /// 1. Refund must be enabled for the course
  /// 2. Must be eligible for refund (within refund period)
  /// 3. Must have remaining days to request refund
  /// 4. Should not have an existing refund request (pending or approved)
  /// 5. If previously rejected, user can request again if still eligible
  bool get canRequestRefund {
    return refundEnabled &&
        isRefundEligible &&
        refundDaysRemaining > 0 &&
        refundRequestStatus != RefundStatus.pending &&
        refundRequestStatus != RefundStatus.approved;
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'title': title,
      'price': price,
      'image': image,
      'course_type': courseType,
      'creator_name': creatorName,
      'refund_enabled': refundEnabled,
      'refund_period_days': refundPeriodDays,
      'is_refund_eligible': isRefundEligible,
      'refund_days_remaining': refundDaysRemaining,
      'has_refund_request': hasRefundRequest,
      'refund_request_status': refundRequestStatus.name,
      'refund_request_id': refundRequestId,
      'refund_admin_notes': refundAdminNotes,
      'purchase_date': purchaseDate.toIso8601String(),
    };
  }
}
