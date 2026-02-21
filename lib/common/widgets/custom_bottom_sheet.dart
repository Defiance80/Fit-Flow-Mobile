import 'dart:ui';

import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  const CustomBottomSheet({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Container(
        width: double.maxFinite,
        margin: .only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: .min,
          children: [
            const CustomBottomSheetDragHandlerContainer(),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class CustomBottomSheetDragHandlerContainer extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const CustomBottomSheetDragHandlerContainer({
    super.key,
    this.padding = const .symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CustomCard(
        color: context.color.onSurface.withAlpha(50),
        borderRadius: 10,
        border: 0,
        width: 32,
        height: 5,
        child: const SizedBox(),
      ),
    );
  }
}
