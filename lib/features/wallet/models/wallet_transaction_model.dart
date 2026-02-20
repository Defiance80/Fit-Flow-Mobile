import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/course_model.dart';

class PaymentDetails {
  final String? accountHolderName;
  final String? accountNumber;
  final String? bankName;
  final String? otherDetails;

  PaymentDetails({
    this.accountHolderName,
    this.accountNumber,
    this.bankName,
    this.otherDetails,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      accountHolderName: json['account_holder_name'] as String?,
      accountNumber: json['account_number'] as String?,
      bankName: json['bank_name'] as String?,
      otherDetails: json['other_details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'otherDetails': otherDetails,
    };
  }
}

class WalletTransactionModel extends Model {
  final int? id;
  final int? userId;
  final num? amount;
  final String? type;
  final String? transactionType;
  final String? entryType;
  final String? referenceId;
  final String? referenceType;
  final String? description;
  final num? balanceBefore;
  final num? balanceAfter;
  final String? createdAt;
  final String? updatedAt;
  final String? courseName;
  final String? transactionId;
  final String? transactionDate;
  final String? status;
  final String? paymentMethod;
  final PaymentDetails? paymentDetails;
  final String? typeLabel;
  final String? transactionTypeLabel;
  final String? createdAtFormatted;
  final String? timeAgo;
  final WalletTransactionReference? reference;

  WalletTransactionModel({
    this.id,
    this.userId,
    this.amount,
    this.type,
    this.transactionType,
    this.entryType,
    this.referenceId,
    this.referenceType,
    this.description,
    this.balanceBefore,
    this.balanceAfter,
    this.createdAt,
    this.updatedAt,
    this.courseName,
    this.transactionId,
    this.transactionDate,
    this.status,
    this.paymentMethod,
    this.paymentDetails,
    this.typeLabel,
    this.transactionTypeLabel,
    this.createdAtFormatted,
    this.timeAgo,
    this.reference,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      amount: json['amount'] != null
          ? (json['amount'] is String
                ? num.tryParse(json['amount'])
                : json['amount'] as num?)
          : null,
      type: json['type'] as String?,
      transactionType: json['transaction_type'] as String?,
      entryType: json['entry_type'] as String?,
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type'] as String?,
      description: json['description'] as String?,
      balanceBefore: json['balance_before'] != null
          ? (json['balance_before'] is String
                ? num.tryParse(json['balance_before'])
                : json['balance_before'] as num?)
          : null,
      balanceAfter: json['balance_after'] != null
          ? (json['balance_after'] is String
                ? num.tryParse(json['balance_after'])
                : json['balance_after'] as num?)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      courseName: json['course_name'] as String?,
      transactionId: json['transaction_id'],
      transactionDate: json['transaction_date'] as String?,
      status: json['status'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentDetails: json['payment_details'] != null
          ? PaymentDetails.fromJson(
              json['payment_details'] as Map<String, dynamic>,
            )
          : null,
      typeLabel: json['type_label'] as String?,
      transactionTypeLabel: json['transaction_type_label'] as String?,
      createdAtFormatted: json['created_at_formatted'] as String?,
      timeAgo: json['time_ago'] as String?,
      reference: json['reference'] != null
          ? WalletTransactionReference.fromJson(
              json['reference'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'transaction_type': transactionType,
      'entry_type': entryType,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'description': description,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course_name': courseName,
      'transaction_id': transactionId,
      'transaction_date': transactionDate,
      'status': status,
      'payment_method': paymentMethod,
      'payment_details': paymentDetails?.toJson(),
      'type_label': typeLabel,
      'transaction_type_label': transactionTypeLabel,
      'created_at_formatted': createdAtFormatted,
      'time_ago': timeAgo,
      'reference': reference?.toJson(),
    };
  }
}

class WalletTransactionReference {
  final int? id;
  final int? userId;
  final int? courseId;
  final int? transactionId;
  final num? refundAmount;
  final String? status;
  final String? reason;
  final String? userMedia;
  final String? adminNotes;
  final String? adminReceipt;
  final String? purchaseDate;
  final String? requestDate;
  final String? processedAt;
  final int? processedBy;
  final String? createdAt;
  final String? updatedAt;
  final CourseModel? course;

  WalletTransactionReference({
    this.id,
    this.userId,
    this.courseId,
    this.transactionId,
    this.refundAmount,
    this.status,
    this.reason,
    this.userMedia,
    this.adminNotes,
    this.adminReceipt,
    this.purchaseDate,
    this.requestDate,
    this.processedAt,
    this.processedBy,
    this.createdAt,
    this.updatedAt,
    this.course,
  });

  factory WalletTransactionReference.fromJson(Map<String, dynamic> json) {
    return WalletTransactionReference(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      courseId: json['course_id'] as int?,
      transactionId: json['transaction_id'] as int?,
      refundAmount: json['refund_amount'] != null
          ? (json['refund_amount'] is String
                ? num.tryParse(json['refund_amount'])
                : json['refund_amount'] as num?)
          : null,
      status: json['status'] as String?,
      reason: json['reason'] as String?,
      userMedia: json['user_media'] as String?,
      adminNotes: json['admin_notes'] as String?,
      adminReceipt: json['admin_receipt'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      requestDate: json['request_date'] as String?,
      processedAt: json['processed_at'] as String?,
      processedBy: json['processed_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'transaction_id': transactionId,
      'refund_amount': refundAmount,
      'status': status,
      'reason': reason,
      'user_media': userMedia,
      'admin_notes': adminNotes,
      'admin_receipt': adminReceipt,
      'purchase_date': purchaseDate,
      'request_date': requestDate,
      'processed_at': processedAt,
      'processed_by': processedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course': course?.toJson(),
    };
  }
}
