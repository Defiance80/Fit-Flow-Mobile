// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/user_model.dart';
import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/core/login/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final class PhoneNumber extends Model {
  String? number;
  String? countryCode;

  String get formattedNumber {
    return '$countryCode $number';
  }

  PhoneNumber({required this.number, required this.countryCode});

  PhoneNumber.lazy();
  void setNumber(String number) {
    this.number = number;
  }

  void setCountryCode(String code) {
    countryCode = code;
  }

  @override
  Map<String, dynamic> toJson() {
    return {ApiParams.mobile: number, ApiParams.countryCode: countryCode};
  }
}

class PhonePasswordLoginParameters extends LoginParameters {
  final String password;
  final PhoneNumber phoneNumber;

  PhonePasswordLoginParameters({
    required this.phoneNumber,
    required this.password,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'platform_type': Platform.operatingSystem,
      ...phoneNumber.toJson(),
    };
  }
}

class PhonePasswordLoginResponse {
  final UserModel user;
  PhonePasswordLoginResponse({required this.user});
}

class PhonePasswordLogin extends Login<PhonePasswordLoginResponse> {
  @override
  FutureOr<void> init() {}

  @override
  Future<LoginResponse<PhonePasswordLoginResponse?>?> login() async {
    final String? fcm = await FirebaseMessaging.instance.getToken();

    final Map<dynamic, dynamic> response = await Api.post(
      Apis.mobileLogin,
      data: (parameters as PhonePasswordLoginParameters).toMap()
        ..addAll({'fcm_id': fcm}),
    );

    final UserModel user = UserModel.fromJson(
      Map.from(response[ApiParams.data]),
    );

    return LoginResponse(PhonePasswordLoginResponse(user: user));
  }
}
