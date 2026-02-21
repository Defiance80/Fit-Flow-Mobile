import 'package:fitflow/common/models/blueprints.dart';

class WishlistItemModel extends Model {
  final String id;
  final String courseTitle;
  final String instructorName;
  final String imageUrl;
  final num rating;
  final int reviewCount;
  final num originalPrice;
  final num discountedPrice;

  WishlistItemModel({
    required this.id,
    required this.courseTitle,
    required this.instructorName,
    required this.imageUrl,
    required this.rating,
    required this.originalPrice,
    required this.discountedPrice,
    this.reviewCount = 0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseTitle': courseTitle,
      'instructorName': instructorName,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
    };
  }

  // Factory constructor from JSON/Map
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'],
      courseTitle: json['courseTitle'],
      instructorName: json['instructorName'],
      imageUrl: json['imageUrl'],
      rating: json['rating'],
      originalPrice: json['originalPrice'],
      discountedPrice: json['discountedPrice'],
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
