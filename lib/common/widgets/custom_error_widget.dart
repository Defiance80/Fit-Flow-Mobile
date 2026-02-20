import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/common/widgets/custom_no_internet_widget.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final String? title;
  final String? illustrator;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final double? illustratorSize;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry? padding;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.title,
    this.illustrator,
    this.buttonText,
    this.onRetry,
    this.showRetryButton = true,
    this.illustratorSize = 200,
    this.titleStyle,
    this.messageStyle,
    this.padding = const .all(16),
  });

  factory CustomErrorWidget.fromErrorState({
    required ErrorState errorState,
    String? title,
    String? illustrator,
    String? buttonText,
    VoidCallback? onRetry,
    bool showRetryButton = true,
    double? illustratorSize,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomErrorWidget(
      error: errorState.error.toString(),
      title: title,
      illustrator: illustrator,
      buttonText: buttonText,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      illustratorSize: illustratorSize,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the error is a no-internet error
    if (error == 'no-internet') {
      return CustomNoInternetWidget(
        onRetry: onRetry,
        showRetryButton: showRetryButton,
        buttonText: buttonText,
        illustratorSize: illustratorSize,
      );
    }

    return Center(
      child: Padding(
        padding: padding ?? .zero,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            CustomImage(
              illustrator ?? AppIcons.errorIllustrator,
              height: illustratorSize,
              width: illustratorSize,
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                textAlign: .center,
                style: titleStyle ?? Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              error,
              textAlign: .center,
              style: messageStyle ?? Theme.of(context).textTheme.bodyLarge,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(buttonText ?? AppLabels.retry.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
