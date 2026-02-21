import 'package:country_code_picker/country_code_picker.dart';
import 'package:fitflow/core/configs/app_settings.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/extensions/state_extension.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum AdaptiveFieldMode { email, number }

class AdaptiveAuthField extends StatefulWidget {
  final String? title;
  final String? hintText;
  final bool isRequired;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final Function(AdaptiveFieldMode mode)? onChangedMode;
  final Function(CountryCode? code)? onChangedCountryCode;
  final bool enabled;

  ///This field is to fix the field to specific type
  final AdaptiveFieldMode? fixedFieldType;

  const AdaptiveAuthField({
    super.key,
    this.title,
    this.hintText,
    this.fixedFieldType,
    this.isRequired = false,
    this.onChanged,
    this.controller,
    this.onChangedMode,
    this.onChangedCountryCode,
    this.enabled = true,
  });

  @override
  State<AdaptiveAuthField> createState() => _AdaptiveAuthFieldState();
}

class _AdaptiveAuthFieldState extends State<AdaptiveAuthField> {
  late bool isPhoneMode = widget.fixedFieldType != null
      ? widget.fixedFieldType == AdaptiveFieldMode.number
      : false;
  late CountryCode? selectedCountryCode =
      Utils.simCountry ?? _loadDefaultDialCode();
  late final TextEditingController _controller;
  String _lastValue = '';

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    super.initState();
  }

  CountryCode? _loadDefaultDialCode() {
    try {
      return CountryCode.fromDialCode(AppSettings.defaultDialCode.toString());
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final String text = _controller.text;

    if (widget.fixedFieldType != null) {
      isPhoneMode = widget.fixedFieldType == AdaptiveFieldMode.number;

      if (_controller.text == _lastValue) return;
      _lastValue = _controller.text;

      setState(() {});
      widget.onChanged?.call(text);
      return;
    }

    // Check if the input is a valid phone number format
    bool newIsPhoneMode =
        text.startsWith('+') || RegExp(r'^[0-9]+$').hasMatch(text);

    if (text.isEmpty) {
      newIsPhoneMode = true;
    }
    if (newIsPhoneMode != isPhoneMode) {
      setState(() {
        isPhoneMode = newIsPhoneMode;
        widget.onChangedMode?.call(
          isPhoneMode ? AdaptiveFieldMode.number : AdaptiveFieldMode.email,
        );
      });
    }

    widget.onChanged?.call(text);
  }

  void _onCountryCodeSelection(CountryCode? countryCode) {
    postFrame((timeStamp) {
      widget.onChangedCountryCode?.call(countryCode);
      setState(() {
        selectedCountryCode = countryCode;
      });
    });
  }

  OutlineInputBorder getBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: color ?? context.color.outline),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: isPhoneMode
              ? TextInputType.number
              : TextInputType.emailAddress,
          inputFormatters: isPhoneMode
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.color.surface,
            contentPadding: .symmetric(
              horizontal: isPhoneMode ? 0 : 12,
              vertical: 13,
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: context.color.outline),
            enabledBorder: getBorder(),
            focusedBorder: getBorder(color: context.color.primary),
            errorBorder: getBorder(color: context.color.error),
            focusedErrorBorder: getBorder(color: context.color.error),
            prefixIcon: isPhoneMode
                ? Container(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    margin: const EdgeInsetsDirectional.only(end: 8, start: 7),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: context.color.outline),
                      ),
                    ),
                    child: CountryCodePicker(
                      onChanged: _onCountryCodeSelection,
                      onInit: _onCountryCodeSelection,
                      initialSelection: selectedCountryCode?.code,
                      backgroundColor: context.color.surface,
                      dialogBackgroundColor: context.color.surface,
                      barrierColor: Colors.black.withValues(alpha: 0.5),
                      dialogTextStyle: TextTheme.of(
                        context,
                      ).bodyMedium?.copyWith(color: context.color.onSurface),
                      searchDecoration: InputDecoration(
                        filled: true,
                        fillColor: context.color.surface,
                        hintText: AppLabels.search.tr,
                        hintStyle: TextTheme.of(context).bodyMedium?.copyWith(
                          color: context.color.onSurface.withValues(alpha: 0.6),
                        ),
                        border: getBorder(),
                        enabledBorder: getBorder(),
                        focusedBorder: getBorder(color: context.color.primary),
                        contentPadding: const .symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.color.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      searchStyle: TextTheme.of(
                        context,
                      ).bodyMedium?.copyWith(color: context.color.onSurface),
                      textStyle: TextTheme.of(
                        context,
                      ).bodyMedium?.copyWith(color: context.color.onSurface),
                      closeIcon: Icon(
                        Icons.close,
                        color: context.color.onSurface,
                      ),
                      builder: (CountryCode? countryCode) {
                        return Row(
                          mainAxisSize: .min,
                          children: [
                            CustomImage(
                              countryCode?.flagUri ?? '',
                              width: 34,
                              height: 24,
                              package: 'country_code_picker',
                            ),
                            const SizedBox(width: 4),
                            Text(
                              countryCode?.dialCode ?? '',
                              style: TextTheme.of(context).bodyMedium,
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: context.color.onSurface,
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (widget.isRequired && (value?.isEmpty ?? true)) {
              return AppLabels.fieldRequired.tr;
            }
            if (isPhoneMode && value != null) {
              // Remove any non-digit characters for validation
              final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digitsOnly.length < 10) {
                return AppLabels.enterValidPhoneNumber.tr;
              }
            } else if (value != null && value.isNotEmpty) {
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return AppLabels.enterValidEmailAddress.tr;
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
