import 'package:fitflow/common/models/blueprints.dart';

class PurchaseCertificateResponseModel extends Model {
  final int orderId;
  final String orderNumber;
  final int courseId;
  final String courseTitle;
  final num certificateFee;
  final String paymentMethod;
  final String status;
  final PaymentDetails? payment;
  final String createdAt;

  PurchaseCertificateResponseModel({
    required this.orderId,
    required this.orderNumber,
    required this.courseId,
    required this.courseTitle,
    required this.certificateFee,
    required this.paymentMethod,
    required this.status,
    this.payment,
    required this.createdAt,
  });

  factory PurchaseCertificateResponseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseCertificateResponseModel(
      orderId: json['order_id'] is String
          ? int.parse(json['order_id'])
          : json['order_id'],
      orderNumber: json['order_number'] ?? '',
      courseId: json['course_id'] is String
          ? int.parse(json['course_id'])
          : json['course_id'],
      courseTitle: json['course_title'] ?? '',
      certificateFee: json['certificate_fee'] is String
          ? num.parse(json['certificate_fee'])
          : json['certificate_fee'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      payment: json['payment'] != null
          ? PaymentDetails.fromJson(json['payment'])
          : null,
      createdAt: json['created_at'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'course_id': courseId,
      'course_title': courseTitle,
      'certificate_fee': certificateFee,
      'payment_method': paymentMethod,
      'status': status,
      if (payment != null) 'payment': payment!.toJson(),
      'created_at': createdAt,
    };
  }
}

class PaymentDetails extends Model {
  final String provider;
  final String id;
  final String url;
  final Map<String, dynamic>? meta;

  PaymentDetails({
    required this.provider,
    required this.id,
    required this.url,
    this.meta,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      provider: json['provider'] ?? '',
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'id': id,
      'url': url,
      if (meta != null) 'meta': meta,
    };
  }
}
