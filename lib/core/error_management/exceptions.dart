// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

abstract class CustomException implements Exception {
  String? get code;
  final String? message;
  final bool toast;
  CustomException({this.message, this.toast = true});
  @override
  String toString() {
    return code ?? message ?? '$runtimeType: unhandled-exception';
  }
}

class UnAuthorizedException extends CustomException {
  @override
  String? get code => 'unauthorized_error';
  UnAuthorizedException({super.toast});
}

class NoInternetException extends CustomException {
  @override
  String? get code => 'no_internet_connection';
  NoInternetException({super.toast});
}

class AppException extends CustomException {
  @override
  String? get code => kDebugMode ? null : 'app_error';

  AppException({super.message, super.toast});

  factory AppException.from(Exception exception) {
    return AppException(message: exception.toString(), toast: false);
  }
}

////Server related exceptions
class ServerException extends CustomException {
  @override
  String? get code => kDebugMode ? null : 'server_error';
  ServerException({super.message, super.toast});
}

class ServerUnavailableException extends CustomException {
  @override
  String? get code => 'server_unavailable';
  ServerUnavailableException({super.message, super.toast});
}

class ValidationError extends CustomException {
  @override
  late String? code;

  ValidationError({super.message, this.code});
}

class ApiException extends CustomException {
  @override
  late String? code;

  ApiException({this.code, super.message, super.toast});

  @override
  String toString() => message ?? '';
}

class BadResponseFormateException extends CustomException {
  @override
  String? get code => 'invalid_response_format';
  BadResponseFormateException({super.toast});
}

class ForceUpdateRequestException extends CustomException {
  @override
  String? get code => 'force_update_required';
  ForceUpdateRequestException({super.toast});
}
