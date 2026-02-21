import 'dart:convert';

import 'package:fitflow/common/enums.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RefundRequestModel {
  final String name;
  final String author;
  final String image;
  final String? rejectReason;
  final RefundStatus status;
  final String? attachedFile;
  final num amount;
  final int id;
  RefundRequestModel({
    required this.name,
    required this.author,
    required this.image,
    this.rejectReason,
    required this.status,
    this.attachedFile,
    required this.amount,
    required this.id,
  });

  RefundRequestModel copyWith({
    String? name,
    String? author,
    String? image,
    String? rejectReason,
    RefundStatus? status,
    String? attachedFile,
    num? amount,
    int? id,
  }) {
    return RefundRequestModel(
      name: name ?? this.name,
      author: author ?? this.author,
      image: image ?? this.image,
      rejectReason: rejectReason ?? this.rejectReason,
      status: status ?? this.status,
      attachedFile: attachedFile ?? this.attachedFile,
      amount: amount ?? this.amount,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'author': author,
      'image': image,
      'rejectReason': rejectReason,
      'status': status,
      'attachedFile': attachedFile,
      'amount': amount,
      'id': id,
    };
  }

  factory RefundRequestModel.fromMap(Map<String, dynamic> map) {
    return RefundRequestModel(
      name: map['name'] as String,
      author: map['author'] as String,
      image: map['image'] as String,
      rejectReason: map['rejectReason'] != null
          ? map['rejectReason'] as String
          : null,
      status: RefundStatus.values.byName(
        map['status'] != null
            ? map['status'].toString().toLowerCase()
            : 'pending',
      ),
      attachedFile: map['attachedFile'] != null
          ? map['attachedFile'] as String
          : null,
      amount: map['amount'] as num,
      id: map['id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory RefundRequestModel.fromJson(String source) =>
      RefundRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RefundRequestModel(name: $name, author: $author, image: $image, rejectReason: $rejectReason, status: $status, attachedFile: $attachedFile, amount: $amount, id: $id)';
  }

  @override
  bool operator ==(covariant RefundRequestModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.author == author &&
        other.image == image &&
        other.rejectReason == rejectReason &&
        other.status == status &&
        other.attachedFile == attachedFile &&
        other.amount == amount &&
        other.id == id;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        author.hashCode ^
        image.hashCode ^
        rejectReason.hashCode ^
        status.hashCode ^
        attachedFile.hashCode ^
        amount.hashCode ^
        id.hashCode;
  }
}
