import 'package:elms/common/enums.dart';
import 'package:elms/common/models/blueprints.dart';

class MyRefundModel extends Model {
  final int id;
  final int userId;
  final int courseId;
  final int transactionId;
  final num refundAmount;
  final RefundStatus status;
  final String reason;
  final String? userMedia;
  final String? adminNotes;
  final String? adminReceipt;
  final DateTime purchaseDate;
  final DateTime requestDate;
  final DateTime? processedAt;
  final int? processedBy;
  final String? userMediaUrl;
  final String? adminReceiptUrl;
  final RefundCourseModel course;
  final RefundTransactionModel transaction;

  MyRefundModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.transactionId,
    required this.refundAmount,
    required this.status,
    required this.reason,
    this.userMedia,
    this.adminNotes,
    this.adminReceipt,
    required this.purchaseDate,
    required this.requestDate,
    this.processedAt,
    this.processedBy,
    this.userMediaUrl,
    this.adminReceiptUrl,
    required this.course,
    required this.transaction,
  });

  factory MyRefundModel.fromJson(Map<String, dynamic> json) {
    return MyRefundModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      transactionId: json['transaction_id'],
      refundAmount: num.parse(json['refund_amount'].toString()),
      status: RefundStatus.fromString(json['status']),
      reason: json['reason'] ?? '',
      userMedia: json['user_media'],
      adminNotes: json['admin_notes'],
      adminReceipt: json['admin_receipt'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      requestDate: DateTime.parse(json['request_date']),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      processedBy: json['processed_by'],
      userMediaUrl: json['user_media_url'],
      adminReceiptUrl: json['admin_receipt_url'],
      course: RefundCourseModel.fromJson(json['course']),
      transaction: RefundTransactionModel.fromJson(json['transaction']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'transaction_id': transactionId,
      'refund_amount': refundAmount.toString(),
      'status': status.name,
      'reason': reason,
      'user_media': userMedia,
      'admin_notes': adminNotes,
      'admin_receipt': adminReceipt,
      'purchase_date': purchaseDate.toIso8601String(),
      'request_date': requestDate.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'processed_by': processedBy,
      'user_media_url': userMediaUrl,
      'admin_receipt_url': adminReceiptUrl,
      'course': course.toJson(),
      'transaction': transaction.toJson(),
    };
  }
}

class RefundCourseModel {
  final int id;
  final String title;
  final String thumbnail;
  final String creatorName;
  final num price;
  final num? discountPrice;
  final String courseType;

  RefundCourseModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.creatorName,
    required this.price,
    this.discountPrice,
    required this.courseType,
  });

  factory RefundCourseModel.fromJson(Map<String, dynamic> json) {
    return RefundCourseModel(
      id: json['id'],
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      creatorName: json['creator_name'] ?? '',
      price: num.parse(json['price']?.toString() ?? '0'),
      discountPrice: json['discount_price'] != null
          ? num.parse(json['discount_price'].toString())
          : null,
      courseType: json['course_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'creator_name': creatorName,
      'price': price.toString(),
      'discount_price': discountPrice?.toString(),
      'course_type': courseType,
    };
  }
}

class RefundTransactionModel {
  final int id;
  final String transactionId;
  final num amount;
  final String paymentMethod;
  final String status;
  final RefundOrderModel? order;

  RefundTransactionModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.order,
  });

  factory RefundTransactionModel.fromJson(Map<String, dynamic> json) {
    return RefundTransactionModel(
      id: json['id'],
      transactionId: json['transaction_id'] ?? '',
      amount: num.parse(json['amount']?.toString() ?? '0'),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      order: json['order'] != null
          ? RefundOrderModel.fromJson(json['order'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount.toString(),
      'payment_method': paymentMethod,
      'status': status,
      'order': order?.toJson(),
    };
  }
}

class RefundOrderModel {
  final int id;
  final String orderNumber;
  final num totalPrice;
  final num taxPrice;
  final num finalPrice;

  RefundOrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.taxPrice,
    required this.finalPrice,
  });

  factory RefundOrderModel.fromJson(Map<String, dynamic> json) {
    return RefundOrderModel(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      totalPrice: num.parse(json['total_price']?.toString() ?? '0'),
      taxPrice: num.parse(json['tax_price']?.toString() ?? '0'),
      finalPrice: num.parse(json['final_price']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'total_price': totalPrice.toString(),
      'tax_price': taxPrice.toString(),
      'final_price': finalPrice.toString(),
    };
  }
}
