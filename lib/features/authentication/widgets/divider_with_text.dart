import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double thickness;
  final Color? dividerColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double horizontalPadding;

  const DividerWithText({
    super.key,
    required this.text,
    this.thickness = 1.0,
    this.dividerColor,
    this.textColor,
    this.textStyle,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: thickness,
            color: dividerColor ?? Theme.of(context).dividerColor,
          ),
        ),
        Padding(
          padding: .symmetric(horizontal: horizontalPadding),
          child: Text(
            text,
            style: textStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor ??
                        Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
        Expanded(
          child: Divider(
              thickness: thickness,
              color: dividerColor ?? Theme.of(context).dividerColor),
        ),
      ],
    );
  }
}
