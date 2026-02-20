import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/core/constants/app_icons.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:elms/common/widgets/custom_text.dart';

class SearchSuggestionItem extends StatelessWidget {
  final String suggestion;
  final VoidCallback onTap;

  const SearchSuggestionItem({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const .symmetric(vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            CustomImage(
              AppIcons.send,
              color: context.color.onSurface,
            ),
            Expanded(
              child: CustomText(
                suggestion,
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
