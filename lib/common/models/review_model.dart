import 'dart:convert';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class RatingDistribution extends Model {
  final int fiveStars;
  final int fourStars;
  final int threeStars;
  final int twoStars;
  final int oneStar;
  final int fiveStarsPercentage;
  final int fourStarsPercentage;
  final int threeStarsPercentage;
  final int twoStarsPercentage;
  final int oneStarPercentage;

  RatingDistribution({
    required this.fiveStars,
    required this.fourStars,
    required this.threeStars,
    required this.twoStars,
    required this.oneStar,
    required this.fiveStarsPercentage,
    required this.fourStarsPercentage,
    required this.threeStarsPercentage,
    required this.twoStarsPercentage,
    required this.oneStarPercentage,
  });

  int get totalRatingsCount =>
      fiveStars + fourStars + threeStars + twoStars + oneStar;

  @override
  Map<String, dynamic> toJson() {
    return {
      'fiveStars': fiveStars,
      'fourStars': fourStars,
      'threeStars': threeStars,
      'twoStars': twoStars,
      'oneStar': oneStar,
      'fiveStarsPercentage': fiveStarsPercentage,
      'fourStarsPercentage': fourStarsPercentage,
      'threeStarsPercentage': threeStarsPercentage,
      'twoStarsPercentage': twoStarsPercentage,
      'oneStarPercentage': oneStarPercentage,
    };
  }

  factory RatingDistribution.fromMap(Map<String, dynamic> map) {
    final breakdown = (map['rating_breakdown'] ?? {}) as Map<String, dynamic>;
    final percentages = (map['percentage_breakdown'] ?? {}) as Map<String, dynamic>;

    return RatingDistribution(
      fiveStars: (breakdown['5_stars'] ?? 0) as int,
      fourStars: (breakdown['4_stars'] ?? 0) as int,
      threeStars: (breakdown['3_stars'] ?? 0) as int,
      twoStars: (breakdown['2_stars'] ?? 0) as int,
      oneStar: (breakdown['1_star'] ?? 0) as int,
      fiveStarsPercentage: (percentages['5_stars'] ?? 0) as int,
      fourStarsPercentage: (percentages['4_stars'] ?? 0) as int,
      threeStarsPercentage: (percentages['3_stars'] ?? 0) as int,
      twoStarsPercentage: (percentages['2_stars'] ?? 0) as int,
      oneStarPercentage: (percentages['1_star'] ?? 0) as int,
    );
  }

  factory RatingDistribution.fromJson(String source) =>
      RatingDistribution.fromMap(json.decode(source));
}

class ReviewModel extends Model {
  final num averageRating;
  final int totalReviews;
  final RatingDistribution ratingDistribution;

  ReviewModel({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution.toJson(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      averageRating: map.optional<num>('average_rating')?.toDouble() ?? 0.0,
      totalReviews: map.optional<int>('total_reviews') ?? 0,
      ratingDistribution: RatingDistribution.fromMap(map),
    );
  }

  factory ReviewModel.fromJson(String source) =>
      ReviewModel.fromMap(json.decode(source));
}
