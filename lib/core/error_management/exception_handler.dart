import 'dart:ui';

import 'package:fitflow/core/error_management/exceptions.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ExceptionHandler {
  ///This will be responsible to show snackbar if the exception is a custom exception
  static void registerErrorSnackbarService() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is CustomException) {
        final CustomException exception =
            (details.exception as CustomException);
        if (exception.toast) {
          UiUtils.showSnackBar(exception.message ?? '', isError: true);
        }
      }
      FlutterError.presentError(details);
    };

    // Handle errors from the platform
    PlatformDispatcher.instance.onError = (error, stack) {
      if (error is CustomException) {
        final CustomException exception = error;
        if (exception.toast) {
          UiUtils.showSnackBar(exception.message ?? '', isError: true);
        }
      }
      return true;
    };
  }

  static void overrideFlutterErrorWidget() {}
}
