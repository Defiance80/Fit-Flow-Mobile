import 'dart:io';

import 'package:elms/common/widgets/custom_bottom_sheet.dart';

import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UiUtils {
  UiUtils._();

  ///
  static void showSnackBar(String text, {bool isError = false, int? duration}) {
    int countedDuration = 0;
    if (duration == null) {
      const double wordsPerSecond = 4.0;
      final int wordCount = text.split(' ').length;
      countedDuration = (wordCount / wordsPerSecond)
          .ceil(); // Calculate required seconds
    }

    Get.showSnackbar(
      GetSnackBar(
        message: text,
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: duration ?? countedDuration.clamp(0, 10)),
        animationDuration: const Duration(milliseconds: 500),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.GROUNDED,
      ),
    );
  }

  ///

  ///
  static Future showDialog(
    BuildContext context, {
    required Widget child,
    int? millisecondTransitionDuration,
    bool? dismissible,
  }) async {
    //we dont active dialog if the dialog is active already
    return await showGeneralDialog(
      context: context,
      barrierDismissible: dismissible ?? true,
      barrierLabel: 'dialog-barrier',
      barrierColor: context.color.onSurface.withValues(alpha: 0.14),
      transitionDuration: Duration(
        milliseconds: millisecondTransitionDuration ?? 200,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return child;
          },
    );
  }

  ///
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool enableDrag = true,
    bool isDismissible = true,
  }) async {
    return showModalBottomSheet<T>(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: context.color.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      clipBehavior: .antiAlias,
      context: context,
      builder: (context) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return CustomBottomSheet(child: child);
      },
    );
  }

  static void showImagePickerSheet(Function(File image) onSelected) async {
    Expanded option(String name, IconData icon, ImageSource source) {
      return Expanded(
        child: GestureDetector(
          behavior: .opaque,
          onTap: () async {
            final XFile? xFile = await ImagePicker().pickImage(source: source);
            if (xFile != null) {
              onSelected(File(xFile.path));
            }
            Get.back();
          },
          child: Column(
            mainAxisSize: .min,
            children: [Icon(icon), Text(name)],
          ),
        ),
      );
    }

    await showCustomBottomSheet(
      Get.context!,
      child: Padding(
        padding: const .all(8.0),
        child: Row(
          children: [
            option('Camera', Icons.camera_alt_outlined, ImageSource.camera),
            option('Gallery', Icons.perm_media_outlined, ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  ///
}
