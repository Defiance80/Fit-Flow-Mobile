import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/message_model.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_text_form_field.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/login/guest_checker.dart';
import 'package:fitflow/features/course/cubits/create_discussion_cubit.dart';
import 'package:fitflow/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:fitflow/features/help_support/cubits/fetch_question_details_cubit.dart';
import 'package:fitflow/features/help_support/cubits/reply_question_cubit.dart';
import 'package:fitflow/features/help_support/models/help_desk_reply_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MessageBottomBar extends StatefulWidget {
  final DiscussionDestination destination;
  final int id;
  final int? parentDiscussionId;
  const MessageBottomBar({
    super.key,
    required this.id,
    required this.destination,
    this.parentDiscussionId,
  });

  @override
  State<MessageBottomBar> createState() => _MessageBottomBarState();
}

class _MessageBottomBarState extends State<MessageBottomBar> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _controller.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CreateDiscussionCubit()),
        BlocProvider(create: (context) => ReplyQuestionCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<CreateDiscussionCubit, CreateDiscussionState>(
                listener: (context, state) {
                  if (state is CreateDiscussionInProgress) {
                    _isLoading.value = true;
                  } else if (state is CreateDiscussionSuccess) {
                    _isLoading.value = false;
                    // If it's a reply to a parent discussion, insert it into that discussion's replies
                    if (widget.parentDiscussionId != null) {
                      // Convert DiscussionModel to Message for nested reply
                      final reply = Message(
                        id: state.discussion.id,
                        content: state.discussion.content,
                        senderId: state.discussion.senderId,
                        receiverId: state.discussion.receiverId,
                        timestamp: state.discussion.timestamp,
                        type: 'reply',
                        userName: state.discussion.userName,
                        userSubtitle: state.discussion.userSubtitle,
                        profile: state.discussion.profile,
                        timesAgo: state.discussion.timesAgo,
                      );
                      context.read<FetchDiscussionCubit>().insertReply(
                        reply,
                        widget.parentDiscussionId.toString(),
                      );
                    } else {
                      // Top-level discussion
                      context.read<FetchDiscussionCubit>().insert(
                        state.discussion,
                      );
                    }
                    _controller.clear();
                  } else if (state is CreateDiscussionFail) {
                    _isLoading.value = false;
                  }
                },
              ),
              BlocListener<ReplyQuestionCubit, ReplyQuestionState>(
                listener: (context, state) {
                  if (state is ReplyQuestionInProgress) {
                    _isLoading.value = true;
                  } else if (state is ReplyQuestionSuccess) {
                    _isLoading.value = false;
                    // Convert Message to HelpDeskReplyModel and insert
                    final Message reply = state.reply;
                    final HelpDeskReplyModel helpDeskReply = HelpDeskReplyModel(
                      id: int.tryParse(reply.id) ?? 0,
                      reply: reply.content,
                      createdAt: reply.timestamp,
                      timeAgo: reply.timesAgo,
                      author: ReplyAuthor(
                        id: int.tryParse(reply.senderId) ?? 0,
                        name: reply.userName,
                        avatar: reply.profile.isNotEmpty ? reply.profile : null,
                      ),
                    );
                    context.read<FetchQuestionDetailsCubit>().insertReply(
                      helpDeskReply,
                    );
                    _controller.clear();
                  } else if (state is ReplyQuestionFail) {
                    _isLoading.value = false;
                  }
                },
              ),
            ],
            child: Container(
              padding: const .symmetric(horizontal: 16, vertical: 8),
              child: Row(
                spacing: 10,
                crossAxisAlignment: .end,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _controller,
                      hintText: AppLabels.typeMessage.tr,
                      isMultiline: true,
                      minLines: 1,
                      maxLines: 6,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isLoading,
                    builder: (context, isLoading, child) {
                      return CustomButton(
                        width: 40,
                        customTitle: isLoading
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : CustomImage(AppIcons.sendMessage),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_controller.text.isNotEmpty) {
                                  if (widget.destination ==
                                      DiscussionDestination.course) {
                                    context.read<CreateDiscussionCubit>().create(
                                          text: _controller.text,
                                          courseId: widget.id,
                                          parentDiscussionId:
                                              widget.parentDiscussionId,
                                        );
                                  } else {
                                    GuestChecker.check(
                                      onNotGuest: () {
                                        context.read<ReplyQuestionCubit>().reply(
                                              id: widget.id,
                                              reply: _controller.text,
                                            );
                                      },
                                    );
                                  }
                                }
                              },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
