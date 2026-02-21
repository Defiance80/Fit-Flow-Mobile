import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/features/cart/models/cart_response_model.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';

/// Repository for managing cart-related data operations
/// Follows the Repository pattern extending Blueprint base class
class CartRepository extends Blueprint {
  /// Fetches the current cart items from the API
  /// Returns [CartResponseModel] containing cart data
  /// Throws exception if API call fails
  Future<CartResponseModel> getCartItems() async {
    final response = await Api.get(Apis.getCart);
    return _parseCartResponse(response);
  }

  /// Adds a course to the cart
  /// [courseId] - The ID of the course to add
  /// Returns updated [CartResponseModel] after adding the course
  /// Throws exception if API call fails
  Future<CartResponseModel> addToCart({required int courseId}) async {
    final response = await Api.post(
      Apis.addToCart,
      data: {ApiParams.courseId: courseId},
    );
    return _parseCartResponse(response);
  }

  /// Removes a course from the cart
  /// [courseId] - The ID of the course to remove
  /// Returns updated [CartResponseModel] after removing the course
  /// Throws exception if API call fails
  Future<CartResponseModel> removeFromCart({required int courseId}) async {
    final response = await Api.post(
      Apis.removeFromCart,
      data: {ApiParams.courseId: courseId},
    );
    return _parseCartResponse(response);
  }

  /// Private helper method to parse API response to CartResponseModel
  /// [response] - The raw API response
  /// Returns [CartResponseModel] - parsed cart data or empty cart if no data
  CartResponseModel _parseCartResponse(Map<String, dynamic> response) {
    if (response[ApiParams.data] != null) {
      return CartResponseModel.fromJson(
        response[ApiParams.data] as Map<String, dynamic>,
      );
    }

    // Return empty cart if no data received
    return _emptyCart();
  }

  /// Clears all items from the cart
  /// Returns updated [CartResponseModel] after clearing the cart
  /// Throws exception if API call fails
  Future<CartResponseModel> clearCart() async {
    final response = await Api.post(Apis.clearCart, data: {});
    return _parseCartResponse(response);
  }

  /// Creates an empty cart response
  /// Returns [CartResponseModel] with empty data
  CartResponseModel _emptyCart() {
    return CartResponseModel(
      displayPrice: 0,
      courses: <CartCourseModel>[],
      subtotalPrice: 0.0,
      discountPrice: 0.0,
      totalPrice: 0.0,
      promoDiscount: 0,
    );
  }
}
