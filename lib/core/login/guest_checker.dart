import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility class to check if user is logged in as guest and prompt login when needed
class GuestChecker {
  static final ValueNotifier<bool?> _isGuest = ValueNotifier(
    LocalStorage.token == null,
  );

  /// Update guest status
  static void set(String from, {required bool isGuest}) {
    _isGuest.value = isGuest;
  }

  /// Check if user is guest and execute callback if not guest, otherwise show login prompt
  static void check({required Function() onNotGuest}) {
    if (_isGuest.value == true) {
      _showLoginBottomSheet(Get.context!);
    } else {
      onNotGuest.call();
    }
  }

  /// Get current guest status
  static bool get value {
    return _isGuest.value ?? false;
  }

  /// Listen to guest status changes
  static ValueNotifier<bool?> listen() {
    return _isGuest;
  }

  /// Widget builder that updates UI based on guest status
  static Widget updateUI({required Function(bool? isGuest) onChangeStatus}) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _isGuest,
      builder: (context, value, child) {
        return onChangeStatus.call(value);
      },
    );
  }

  /// Show bottom sheet prompting user to login
  static void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surface,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const .all(30),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              CustomText(
                AppLabels.loginIsRequired.tr,
                style: Theme.of(context).textTheme.titleMedium!,
              ),
              const SizedBox(height: 5),
              CustomText(
                AppLabels.tapOnLogin.tr,
                style: Theme.of(context).textTheme.bodyMedium!,
                fontSize: 14,
                color: context.color.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  elevation: 0,
                  color: context.color.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const .symmetric(vertical: 12),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.loginScreen,
                      arguments: {'popToCurrent': true},
                    );
                  },
                  child: CustomText(
                    AppLabels.loginNow.tr,
                    style: Theme.of(context).textTheme.labelLarge!,
                    color: context.color.onPrimary,
                    fontWeight: .w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
