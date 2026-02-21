import 'dart:async';
import 'dart:io';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/core/login/login.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/utils.dart';

enum CredentialLoginType { phone, email }

class EmailSignupParameters extends LoginParameters {
  final String? password;
  final String? email;

  EmailSignupParameters({required this.password, required this.email});
  @override
  Map<String, dynamic> toMap() {
    return {ApiParams.platformType: Platform.operatingSystem}.removeEmptyKeys();
  }
}

class EmailLoginParameters extends LoginParameters {
  final String email;
  final String password;

  EmailLoginParameters({required this.email, required this.password});
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class EmailSignupResult {
  final String firebaseToken;
  final UserCredential credentials;

  EmailSignupResult(this.firebaseToken, this.credentials);
}

class EmailLoginResult {
  final String? firebaseToken;

  EmailLoginResult(this.firebaseToken);
}

class EmailLogin extends Login<EmailLoginResult> {
  @override
  void init() {
    // Nothing to initialize
  }

  @override
  Future<LoginResponse<EmailLoginResult>?> login() async {
    final EmailLoginParameters params = parameters as EmailLoginParameters;
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: params.email,
          password: params.password,
        );

    if (userCredential.user?.emailVerified == false) {
      throw ApiException(message: AppLabels.emailVerificationPending.tr);
    }

    final String? firebaseToken = await userCredential.user?.getIdToken();
    return LoginResponse(EmailLoginResult(firebaseToken));
  }
}

class EmailSignup extends Login<EmailSignupResult> {
  @override
  FutureOr<void> init() {}

  @override
  Future<LoginResponse<EmailSignupResult?>?> login() async {
    try {
      final EmailSignupParameters? params =
          parameters as EmailSignupParameters?;

      if (params == null) {
        throw Exception('Set Email Signup Parameters.');
      }
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: params.email!,
            password: params.password!,
          );

      await userCredential.user?.sendEmailVerification();

      final String? firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw AppException(message: 'Firebase token is null', toast: false);
      }
      return LoginResponse(EmailSignupResult(firebaseToken, userCredential));
    } catch (e) {
      if (e case final FirebaseAuthException exp) {
        UiUtils.showSnackBar(exp.message!, isError: true);
      }
    }
    return null;
  }
}
