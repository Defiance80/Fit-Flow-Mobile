import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/widgets/custom_dialog_box.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/notification/cubits/team_invitation_cubit.dart';
import 'package:fitflow/features/notification/models/notification_model.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class TeamInvitationDialog extends StatelessWidget {
  final NotificationModel notification;

  const TeamInvitationDialog({super.key, required this.notification});

  static void show(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => TeamInvitationCubit(),
        child: TeamInvitationDialog(notification: notification),
      ),
    );
  }

  void _onTapAccept(BuildContext context) {
    final invitationToken = notification.teamMembers?.invitationToken;
    if (invitationToken == null) return;

    context.read<TeamInvitationCubit>().handleInvitation(
      action: 'accept',
      invitationToken: invitationToken,
    );
  }

  void _onTapDecline(BuildContext context) {
    final invitationToken = notification.teamMembers?.invitationToken;
    if (invitationToken == null) return;

    context.read<TeamInvitationCubit>().handleInvitation(
      action: 'decline',
      invitationToken: invitationToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamInvitationCubit, TeamInvitationState>(
      listener: (context, state) {
        if (state is TeamInvitationSuccess) {
          Navigator.pop(context);
          final message = state.action == 'accept'
              ? AppLabels.invitationAccepted.tr
              : AppLabels.invitationDeclined.tr;
          UiUtils.showSnackBar(message);
        } else if (state is TeamInvitationFail) {
          Navigator.pop(context);
          UiUtils.showSnackBar(state.error.toString(), isError: true);
        }
      },
      builder: (context, state) {
        final bool isLoading = state is TeamInvitationInProgress;
        final String teamName = notification.instructorDetails?.name ?? 'Team';

        return CustomDialogBox(
          title: AppLabels.teamInvitation.tr,
          content: Column(
            mainAxisSize: .min,
            children: [
              CustomText(
                AppLabels.teamInvitationMessage.tr.replaceAll(
                  '{{teamName}}',
                  teamName,
                ),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.color.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            DialogButton(
              title: AppLabels.decline.tr,
              onTap: isLoading ? null : () => _onTapDecline(context),
              color: context.color.error,
              style: DialogButtonStyle.outlined,
            ),
            DialogButton(
              title: AppLabels.accept.tr,
              onTap: isLoading ? null : () => _onTapAccept(context),
              color: context.color.primary,
              style: DialogButtonStyle.primary,
            ),
          ],
        );
      },
    );
  }
}
