import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

typedef Validator = String? Function(String?)?;

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? title;
  final bool isRequired;
  final TextEditingController? controller;
  final Validator validator;
  final List<Validator>? multiValidator;
  final bool isPassword;
  final Widget? suffixIcon;
  final TextInputType? inputType;
  final String? prefixIcon;
  final double? radius;
  final bool enabled;
  final bool isMultiline;
  final int? maxLines;
  final int? minLines;
  final Color? fillColor;
  final Color? hintColor;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? formatters;

  const CustomTextFormField({
    this.formatters,
    super.key,
    this.hintText,
    this.title,
    this.isRequired = false,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.suffixIcon,
    this.inputType,
    this.prefixIcon,
    this.radius,
    this.enabled = true,
    this.isMultiline = false,
    this.maxLines,
    this.minLines,
    this.fillColor,
    this.hintColor,
    this.multiValidator,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _getValidator(String? value) {
    if (widget.multiValidator != null) {
      for (int i = 0; i < widget.multiValidator!.length; i++) {
        final String? message = widget.multiValidator?[i]?.call(value);
        if (message != null) return message;
      }
    } else if (widget.validator != null) {
      return widget.validator?.call(value);
    } else {
      if (widget.isRequired && (value?.isEmpty ?? true)) {
        return AppLabels.fieldRequired.tr;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // final borderRadius = BorderRadius.circular(widget.radius ?? 4);
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (widget.title != null) ...{
          Text.rich(
            TextSpan(
              text: widget.title!,
              style: Theme.of(context).textTheme.labelLarge,
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        },
        TextFormField(
          controller: widget.controller,
          inputFormatters: widget.formatters,
          obscureText: widget.isPassword && _obscureText,
          enabled: widget.enabled,
          maxLines: widget.isMultiline ? widget.maxLines ?? 5 : 1,
          minLines: widget.isMultiline ? widget.minLines ?? 1 : 1,
          keyboardType: widget.isMultiline
              ? TextInputType.multiline
              : widget.inputType,
          validator: _getValidator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColor ?? context.color.surface,
            contentPadding: const .symmetric(horizontal: 12, vertical: 13),
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  widget.hintColor ??
                  context.color.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: widget.prefixIcon != null
                ? CustomImage(
                    widget.prefixIcon!,
                    color: context.color.onSurface,
                    width: 24,
                    height: 24,
                    fit: .none,
                  )
                : null,
            disabledBorder: getBorder(),
            enabledBorder: getBorder(),
            focusedBorder: getBorder(color: context.color.primary),
            errorBorder: getBorder(color: context.color.error),
            focusedErrorBorder: getBorder(color: context.color.error),
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: _togglePasswordVisibility,
                    child: CustomImage(
                      _obscureText
                          ? AppIcons.obscuredText
                          : AppIcons.obscureText,
                      width: 24,
                      height: 24,
                      fit: .none,
                      color: context.color.onSurface,
                    ),
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder getBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.radius ?? 4),
      borderSide: BorderSide(color: color ?? context.color.outline),
    );
  }
}
