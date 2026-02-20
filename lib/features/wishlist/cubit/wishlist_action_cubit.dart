import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/wishlist/repository/wishlist_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WishlistActionState implements BaseState {}

class WishlistActionInitial extends WishlistActionState {}

class WishlistActionInProgress extends ProgressState
    implements WishlistActionState {}

class WishlistActionSuccess extends WishlistActionState {
  final int courseId;
  final bool isWishlisted;
  final String message;

  WishlistActionSuccess({
    required this.courseId,
    required this.isWishlisted,
    required this.message,
  });
}

final class WishlistActionError extends ErrorState<String>
    implements WishlistActionState {
  final int courseId;
  final bool previousState;

  WishlistActionError({
    required super.error,
    required this.courseId,
    required this.previousState,
  });
}

class WishlistActionCubit extends Cubit<WishlistActionState> {
  final WishlistRepository _repository;

  WishlistActionCubit(this._repository) : super(WishlistActionInitial());

  Future<void> toggleWishlist({
    required int courseId,
    required bool currentWishlistState,
  }) async {
    try {
      emit(WishlistActionInProgress());
      // Use status: 0 for remove, 1 for add
      final int status = currentWishlistState ? 0 : 1;

      final Map<String, dynamic> response =
          await _repository.toggleWishlist(courseId: courseId, status: status);

      emit(WishlistActionSuccess(
        courseId: courseId,
        isWishlisted: !currentWishlistState,
        message: response['message'] ?? 'Wishlist updated successfully',
      ));
    } catch (e) {
      emit(WishlistActionError(
        error: e.toString(),
        courseId: courseId,
        previousState: currentWishlistState,
      ));
    }
  }
}
