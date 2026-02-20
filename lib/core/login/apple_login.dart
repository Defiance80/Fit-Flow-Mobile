import 'package:elms/core/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginParameters extends LoginParameters {
  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class AppleLogin extends SocialLogin<UserCredential> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String get provider => 'apple';

  @override
  void init() {
    // No initialization needed
  }

  @override
  Future<LoginResponse<UserCredential>> login() async {
    try {
      final rawNonce = generateNonce();
      final nonce = rawNonce;

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final UserCredential authResult = await _auth.signInWithCredential(
        oauthCredential,
      );
      return LoginResponse(authResult);
    } catch (e) {
      rethrow;
    }
  }
}
