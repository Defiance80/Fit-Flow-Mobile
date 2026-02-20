import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:get/get.dart';

class Validators {
  // Validate if the field is not empty
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLabels.fieldRequired.tr;
    }
    return null;
  }

  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLabels.emailRequired.tr;
    }
    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return AppLabels.enterValidEmailAddress.tr;
    }
    return null;
  }

  // Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.passwordRequired.tr;
    }
    if (value.length < 8) {
      return AppLabels.passwordLengthValidation.tr;
    }

    ///Note: Uncomment this is you want strong password validation

    // final hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    // final hasLowerCase = value.contains(RegExp(r'[a-z]'));
    // final hasDigits = value.contains(RegExp(r'\d'));
    // final hasSpecialCharacters =
    //     value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // if (!(hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters)) {
    //   return 'Password must include uppercase, lowercase, number, and special character.';
    // }
    return null;
  }

  // Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLabels.phoneNumberRequired.tr;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return AppLabels.enterValidPhoneNumber.tr;
    }
    return null;
  }

  // Validate custom length range
  static String? validateLength(String? value, {int min = 0, int max = 50}) {
    if (value == null || value.isEmpty) {
      return AppLabels.fieldRequired.tr;
    }
    if (value.length < min) {
      return AppLabels.mustBeAtLeast.translateWithTemplate({
        'min': min.toString(),
      });
    }
    if (value.length > max) {
      return AppLabels.mustBeLessThan.translateWithTemplate({
        'max': max.toString(),
      });
    }
    return null;
  }

  // Validate numbers only
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.fieldRequired.tr;
    }
    final numberRegex = RegExp(r'^\d+$');
    if (!numberRegex.hasMatch(value)) {
      return AppLabels.onlyNumbersAllowed.tr;
    }
    return null;
  }

  // Validate price/amount (positive numbers with up to 2 decimal places)
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLabels.fieldRequired.tr;
    }

    final trimmed = value.trim();

    // Strict price: digits or digits.decimals (max 2 decimals optional)
    final priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');

    if (!priceRegex.hasMatch(trimmed)) {
      return AppLabels.enterValidNumber.tr;
    }

    // Check if the amount is greater than zero
    final amount = double.tryParse(trimmed);
    if (amount == null || amount <= 0) {
      return AppLabels.amountMustBeGreaterThanZero.tr;
    }

    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLabels.nameRequired.tr;
    }
    if (value.trim().length < 2) {
      return AppLabels.nameLengthValidation.tr;
    }
    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppLabels.pleaseConfirmPassword.tr;
    }
    if (value != password) {
      return AppLabels.passwordDoNotMatch.tr;
    }
    return null;
  }
}
