import 'package:fitflow/common/models/message_model.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class UserProfileTile extends StatelessWidget {
  final MessageModel message;
  const UserProfileTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return _buildProfileTile(
        context: context,
        profile: message.profile,
        name: message.userName,
        subtitle: message.userSubtitle);
  }

  Widget _buildNameAndSubtitle({
    required BuildContext context,
    required String name,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          name,
          style: Theme.of(context).textTheme.titleMedium!,
          fontWeight: .bold,
        ),
        if (subtitle != null)
          CustomText(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall!,
          )
      ],
    );
  }

  Widget _buildAvatar({required String profile}) {
    return CustomImage.circular(
        width: 42, height: 42, imageUrl: profile);
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required String profile,
    required String name,
    String? subtitle,
  }) {
    return Row(
      spacing: 12,
      children: [
        _buildAvatar(profile: profile),
        _buildNameAndSubtitle(context: context, name: name, subtitle: subtitle)
      ],
    );
  }
}
