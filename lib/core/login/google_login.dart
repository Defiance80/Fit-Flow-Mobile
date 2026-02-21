import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/core/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class GoogleLoginParameters extends LoginParameters {
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class GoogleLogin extends SocialLogin<UserCredential> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _scopes = ['profile', 'email'];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String get provider => 'google';

  @override
  void init() {
    // No initialization needed
  }

  /// Sign out from Google Sign-In
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<LoginResponse<UserCredential>> login() async {
    try {
      await _googleSignIn.initialize();

      final account = await _googleSignIn.authenticate();

      GoogleSignInClientAuthorization? auth;

      auth = await account.authorizationClient.authorizationForScopes(_scopes);
      auth ??= await account.authorizationClient.authorizeScopes(_scopes);

      final credentials = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
        accessToken: auth.accessToken,
      );
      final userCredentials = await _auth.signInWithCredential(credentials);

      return LoginResponse(userCredentials);
    } catch (e) {
      if (e case final GoogleSignInException exception
          when exception.code == GoogleSignInExceptionCode.canceled) {
        throw AppException(message: AppLabels.googleLoginCancelled.tr);
      }
      if (e is PlatformException) {
        throw AppException(message: e.code.tr);
      }
      rethrow;
    }
  }
}
