import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double border;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? borderColor;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? color;
  final Alignment? alignment;
  const CustomCard(
      {super.key,
      required this.child,
      this.border = 0.5,
      this.borderColor,
      this.borderRadius = 12.0,
      this.margin = EdgeInsets.zero,
      this.padding = EdgeInsets.zero,
      this.height,
      this.color,
      this.width,
      this.alignment,
      this.boxShadow});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      width: width,
      alignment: alignment,
      height: height,
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
          border: Border.all(
              color: borderColor ?? Colors.black.withOpacity(0.04),
              width: border > 0 ? 0.5 : 0),
          borderRadius: BorderRadius.circular(borderRadius)),
      decoration: BoxDecoration(
        color: color ?? context.color.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
