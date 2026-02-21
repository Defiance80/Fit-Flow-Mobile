import 'package:fitflow/common/enums.dart';
import 'package:fitflow/common/models/message_model.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:fitflow/features/course/features/discussion/widgets/discussion_card.dart';
import 'package:fitflow/features/course/features/discussion/widgets/message_bottombar.dart';
import 'package:fitflow/features/course/features/discussion/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ThreadScreen extends StatefulWidget {
  final DiscussionModel discussion;
  static Widget route() {
    return ThreadScreen(discussion: Get.arguments as DiscussionModel);
  }

  const ThreadScreen({super.key, required this.discussion});
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<FetchDiscussionCubit, FetchDiscussionState>(
        builder: (context, state) {
          // Get the current discussion from state or use widget.discussion as fallback
          DiscussionModel currentDiscussion = widget.discussion;
          if (state is FetchDiscussionSuccess) {
            currentDiscussion = state.data.firstWhere(
              (d) => d.id == widget.discussion.id,
              orElse: () => widget.discussion,
            );
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: CustomText(
                        AppLabels.discussion.tr,
                        style: Theme.of(context).textTheme.titleLarge!,
                      ),
                      floating: true,
                      snap: true,
                    ),
                    SliverPadding(
                      padding: const .all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          DiscussionCard(
                            discussion: currentDiscussion,
                            replyVisibility: ReplyVisibility.hidden,
                          ),
                          const SizedBox(height: 16),
                          _buildRepliesCountRow(currentDiscussion),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const .symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: .only(
                              bottom:
                                  index < currentDiscussion.replies.length - 1
                                  ? 8
                                  : 16,
                            ),
                            child: MessageCard(
                              message: currentDiscussion.replies[index],
                              useCard: true,
                            ),
                          );
                        }, childCount: currentDiscussion.replies.length),
                      ),
                    ),
                  ],
                ),
              ),
              MessageBottomBar(
                id: int.parse(widget.discussion.receiverId),
                destination: DiscussionDestination.course,
                parentDiscussionId: int.parse(widget.discussion.id),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRepliesCountRow(DiscussionModel discussion) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        CustomText(
          AppLabels.repliesCount.tr,
          style: Theme.of(context).textTheme.titleMedium!,
          fontWeight: .w600,
        ),
        CustomText(
          discussion.replies.length.toString(),
          style: Theme.of(context).textTheme.titleMedium!,
          fontWeight: .w600,
        ),
      ],
    );
  }
}
