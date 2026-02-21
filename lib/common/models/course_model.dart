import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';

class CourseModel extends Model {
  final int id;
  final String? slug;
  final String image;
  final int? categoryId;
  final String? categoryName;
  final int ratings;
  final num averageRating;
  final String title;
  final String shortDescription;
  final String authorName;
  final num price;
  final num? discountedPrice;
  final num discountPercentage;
  bool isWishlisted;
  final bool isEnrolled;
  final String level;
  final int? totalChapters;
  final int? completedChapters;
  final int? totalCurriculumItems;
  final int? completedCurriculumItems;
  final num? progressPercentage;
  final String? progressStatus;
  final String? currentChapter;
  final String courseType;

  num get finalPrice {
    if (courseType == 'free') {
      return 0;
    }
    if ((discountedPrice ?? 0) <= 0) {
      return price;
    }
    return discountedPrice ?? 0;
  }

  bool get hasDiscount {
    if (discountPercentage > 0) {
      return true;
    }
    return false;
  }

  bool get isFree {
    return courseType == 'free';
  }

  CourseModel({
    required this.id,
    required this.slug,
    required this.image,
    required this.categoryId,
    required this.categoryName,
    required this.ratings,
    required this.averageRating,
    required this.title,
    required this.shortDescription,
    required this.authorName,
    required this.price,
    required this.level,
    this.discountedPrice,
    required this.discountPercentage,
    required this.isWishlisted,
    required this.isEnrolled,
    this.totalChapters,
    this.completedChapters,
    this.totalCurriculumItems,
    this.completedCurriculumItems,
    this.progressPercentage,
    this.progressStatus,
    this.currentChapter,
    required this.courseType,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json.require<int>('id'),
      slug: json.optional<String?>('slug'),
      image: json.require<String?>('image') ?? '',
      categoryId: json.require<int?>('category_id'),
      categoryName: json.require<String?>('category_name'),
      ratings: json.require<int>('ratings'),
      averageRating: json.require<num>('average_rating').toDouble(),
      title: json.require<String>('title'),
      shortDescription: json.require<String?>('short_description') ?? "",
      authorName: json.require<String>('author_name'),
      price: json.require<num>('price').toDouble(),
      discountedPrice: json.optional<num>('discount_price')?.toDouble(),
      discountPercentage: json.require<num>('discount_percentage'),
      isWishlisted: json.require<bool>('is_wishlisted'),
      isEnrolled: /* true ??*/ json.require<bool>(
        'is_enrolled',
      ), // Set to true for testing - json.require<bool>('is_enrolled'),
      level: json.require<String>('level'),
      totalChapters: json.optional<int>('total_chapters'),
      completedChapters: json.optional<int>('completed_chapters'),
      totalCurriculumItems: json.optional<int>('total_curriculum_items'),
      completedCurriculumItems: json.optional<int>(
        'completed_curriculum_items',
      ),
      progressPercentage: json.optional<num>('progress_percentage')?.toDouble(),
      progressStatus: json.optional<String>('progress_status'),
      currentChapter: json.optional<String?>('current_chapter_name'),
      courseType: json.require<String>('course_type'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'image': image,
    'category_id': categoryId,
    'category_name': categoryName,
    'ratings': ratings,
    'average_rating': averageRating,
    'title': title,
    'short_description': shortDescription,
    'author_name': authorName,
    'price': price,
    'discounted_price': discountedPrice,
    'discount_percentage': discountPercentage,
    'is_wishlisted': isWishlisted,
    'is_enrolled': isEnrolled,
    'level': level,
    'total_chapters': totalChapters,
    'completed_chapters': completedChapters,
    'total_curriculum_items': totalCurriculumItems,
    'completed_curriculum_items': completedCurriculumItems,
    'progress_percentage': progressPercentage,
    'progress_status': progressStatus,
    'course_type': courseType,
  };
}
