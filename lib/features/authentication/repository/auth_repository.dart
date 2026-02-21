// ignore_for_file: avoid_dynamic_calls

import 'dart:io';
import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/user_model.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/core/login/phone_password_login.dart';
import 'package:fitflow/utils/extensions/data_type_extensions.dart';
import 'package:fitflow/utils/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthRepository {
  Future<UserModel> loginWithEmail({
    required String firebaseToken,
    required String password,
    required String email,
  }) async {
    final Map<dynamic, dynamic> response = await Api.post(
      Apis.login,
      data: {
        ApiParams.firebaseToken: firebaseToken,
        ApiParams.type: AuthenticationType.email.name,
        ApiParams.password: password,
        ApiParams.confirmPassword: password,
        ApiParams.email: email,
      },
    );

    return UserModel.fromJson(Map.from(response[ApiParams.data]));
  }

  Future<bool> resetPassword({
    required String password,
    required String confirmPassword,
    required String firebaseToken,
  }) async {
    try {
      final Map response = await Api.post(
        Apis.resetPassword,
        data: {
          ApiParams.password: password,
          ApiParams.confirmPassword: confirmPassword,
          ApiParams.firebaseToken: firebaseToken,
        },
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserExists(
    String number, {
    required String countryCode,
  }) async {
    try {
      final Map response = await Api.post(
        Apis.userExists,
        data: {ApiParams.mobile: number, ApiParams.countryCode: countryCode},
      );
      return !(response[ApiParams.data][ApiParams.isNewUser]);
    } catch (e) {
      return false;
    }
  }

  Future<UserModel> register({
    String? email,
    required String password,
    required String confirmPassword,
    required String name,
    String? mobile,
    required String firebaseToken,
  }) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    final Map<String, dynamic> params = {
      ApiParams.email: email,
      ApiParams.fcmId: fcmToken ?? '',
      ApiParams.name: name,
      ApiParams.platformType: Platform.operatingSystem,
      ApiParams.firebaseToken: firebaseToken,
      ApiParams.password: password,
      ApiParams.confirmPassword: confirmPassword,
      ApiParams.type: 'email',
    }.removeEmptyKeys();

    final Map<dynamic, dynamic> response = await Api.post(
      Apis.userSignup,
      data: params,
    );

    return UserModel.fromJson(
      Map<String, dynamic>.from(response[ApiParams.data]),
    );
  }

  Future<UserModel> socialLogin(UserCredential credential, String type) async {
    try {
      // Get FCM token (works on both simulator and device)
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      final String? firebaseToken = await credential.user?.getIdToken();
      final Map<String, dynamic> data = {
        ApiParams.name: credential.user?.displayName ?? '',
        ApiParams.email: credential.user?.email ?? '',
        ApiParams.mobile: credential.user?.phoneNumber ?? '',
        ApiParams.fcmId: fcmToken ?? '',
        ApiParams.firebaseId: credential.user?.uid ?? '',
        ApiParams.type: type,
        ApiParams.profile: credential.user?.photoURL ?? '',
        ApiParams.platformType: Platform.operatingSystem,
        ApiParams.firebaseToken: firebaseToken,
      };
      final Map response = await Api.post(Apis.userSignup, data: data);

      return UserModel.fromJson(
        (response[ApiParams.data] as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserDetails() async {
    try {
      if (LocalStorage.token == null) {
        throw UnAuthorizedException(toast: false);
      }
      final Map<String, dynamic> result = await Api.get(
        Apis.getUserDetails,
        data: {ApiParams.token: LocalStorage.token},
      );

      return UserModel.fromJson(Map.from(result[ApiParams.data]));
    } catch (e) {
      throw ApiException(toast: false);
    }
  }

  Future<UserModel> editProfile({
    String? name,
    String? email,
    PhoneNumber? phone,
    File? profile,
  }) async {
    try {
      final response = await Api.postMultipart(
        Apis.updateProfile,
        fileKey: 'profile',
        files: [?profile],
        data: {
          'name': ?name,
          'email': ?email,
          'mobile': ?phone?.number,
          'country_code': ?phone?.countryCode,
        },
      );

      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Api.post(
      Apis.changePassword,
      data: {
        'old_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );
  }

  Future<bool> deleteAccount({
    String? password,
    String? confirmPassword,
    String? firebaseToken,
  }) async {
    final Map<String, dynamic> data = {'confirm_deletion': 1};

    // Only add password if provided (for non-social login)
    if (password != null && password.isNotEmpty) {
      data[ApiParams.password] = password;
    }

    if (confirmPassword != null && confirmPassword.isNotEmpty) {
      data[ApiParams.confirmPassword] = confirmPassword;
    }

    // Add firebase token if provided (for social login)
    if (firebaseToken != null && firebaseToken.isNotEmpty) {
      data[ApiParams.firebaseToken] = firebaseToken;
    }

    await Api.post(Apis.deleteAccount, data: data);
    return true;
  }
}
