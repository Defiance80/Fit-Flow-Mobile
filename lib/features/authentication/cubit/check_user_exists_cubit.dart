import 'package:elms/features/authentication/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CheckMobileUserExistsState {}

class CheckMobileUserExistsInitial extends CheckMobileUserExistsState {}

class CheckMobileUserExistsLoading extends CheckMobileUserExistsState {}

class MobileUserExists extends CheckMobileUserExistsState {}

class MobileUserDoesNotExist extends CheckMobileUserExistsState {}

class CheckMobileUserExistsError extends CheckMobileUserExistsState {
  final String message;
  CheckMobileUserExistsError(this.message);
}

class CheckMobileUserExistsCubit extends Cubit<CheckMobileUserExistsState> {
  final AuthRepository _authRepository;

  CheckMobileUserExistsCubit(this._authRepository)
    : super(CheckMobileUserExistsInitial());

  Future<void> checkIfUserExists(
    String number, {
    required String countryCode,
  }) async {
    try {
      emit(CheckMobileUserExistsLoading());
      final bool exists = await _authRepository.isUserExists(
        number,
        countryCode: countryCode,
      );

      if (exists) {
        emit(MobileUserExists());
      } else {
        emit(MobileUserDoesNotExist());
      }
    } catch (e) {
      emit(CheckMobileUserExistsError(e.toString()));
    }
  }

  // setInitial() {
  //   emit(CheckMobileUserExistsInitial());
  // }
}
