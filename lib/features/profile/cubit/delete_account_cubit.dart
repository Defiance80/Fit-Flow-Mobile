import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/features/authentication/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

abstract class DeleteAccountState extends BaseState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountInProgress extends ProgressState
    implements DeleteAccountState {}

class DeleteAccountSuccess extends BaseState implements DeleteAccountState {}

final class DeleteAccountFailed extends ErrorState
    implements DeleteAccountState {
  DeleteAccountFailed({required super.error});
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository _authRepository;

  DeleteAccountCubit(this._authRepository) : super(DeleteAccountInitial());

  /// Deletes the user account
  /// [password] - The user's password for verification (required for non-social login)
  /// [confirmPassword] - Password confirmation (required for non-social login)
  /// [isSocialLogin] - Whether the user logged in via social login (Google, Apple, etc.)
  /// [firebaseToken] - Firebase token for social login users (required for social login)
  Future<void> deleteAccount({
    String? password,
    String? confirmPassword,
    required bool isSocialLogin,
    String? firebaseToken,
  }) async {
    try {
      emit(DeleteAccountInProgress());

      // If not social login, password is required
      if (!isSocialLogin && (password == null || password.isEmpty)) {
        throw ValidationError(message: AppLabels.passwordRequired.tr);
      }

      // For social login, firebase token is required
      if (isSocialLogin && (firebaseToken == null || firebaseToken.isEmpty)) {
        throw ValidationError(message: 'Firebase token is required for social login'.tr);
      }

      // Then call the backend API to delete account
      await _authRepository.deleteAccount(
        password: isSocialLogin ? null : password,
        confirmPassword: isSocialLogin ? null : confirmPassword,
        firebaseToken: isSocialLogin ? firebaseToken : null,
      );

      // For social login, delete Firebase account after successful API call
      if (isSocialLogin) {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
        }
      }

      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountFailed(error: e));
    }
  }
}
