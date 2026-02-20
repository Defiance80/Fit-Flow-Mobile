import 'package:elms/core/constants/app_labels.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Helper class to convert Firebase error codes to user-friendly messages
class FirebaseErrorHelper {
  FirebaseErrorHelper._();

  /// Converts a FirebaseAuthException to a user-friendly localized message
  static String getErrorMessage(FirebaseAuthException exception) {
    final String errorCode = exception.code;

    // Map Firebase error codes to localized labels
    switch (errorCode) {
      case 'invalid-email':
        return AppLabels.invalidEmail.tr;
      case 'wrong-password':
        return AppLabels.wrongPassword.tr;
      case 'user-not-found':
        return AppLabels.userNotFound.tr;
      case 'user-disabled':
        return AppLabels.userDisabled.tr;
      case 'email-already-in-use':
        return AppLabels.emailAlreadyInUse.tr;
      case 'weak-password':
        return AppLabels.weakPassword.tr;
      case 'user-token-expired':
        return AppLabels.userTokenExpired.tr;
      case 'requires-recent-login':
        return AppLabels.requiresRecentLogin.tr;
      case 'network-request-failed':
        return AppLabels.networkRequestFailed.tr;
      case 'operation-not-allowed':
        return AppLabels.operationNotAllowed.tr;
      case 'too-many-requests':
        return AppLabels.tooManyRequests.tr;
      case 'invalid-credential':
        return AppLabels.invalidCredential.tr;
      case 'credential-already-in-use':
        return AppLabels.credentialAlreadyInUse.tr;
      case 'invalid-verification-code':
        return AppLabels.invalidVerificationCode.tr;
      default:
        // If there's a custom message, use it; otherwise use generic message
        return exception.message ?? AppLabels.somethingWentWrong.tr;
    }
  }

  /// Checks if an error is a FirebaseAuthException and returns formatted message
  static String formatError(dynamic error) {
    if (error is FirebaseAuthException) {
      return getErrorMessage(error);
    }
    return error.toString();
  }
}
