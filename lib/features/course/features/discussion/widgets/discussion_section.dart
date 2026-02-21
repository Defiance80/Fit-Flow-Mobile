import 'package:fitflow/common/models/message_model.dart';
import 'package:fitflow/common/widgets/custom_shimmer.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/common/widgets/custom_error_widget.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/course/cubits/fetch_discussion_cubit.dart';
import 'package:fitflow/features/course/features/discussion/widgets/discussion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DiscussionSection extends StatefulWidget {
  const DiscussionSection({super.key});

  @override
  State<DiscussionSection> createState() => _DiscussionSectionState();
}

class _DiscussionSectionState extends State<DiscussionSection> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.all(16) +
          const EdgeInsets.only(bottom: kToolbarHeight),
      child: BlocBuilder<FetchDiscussionCubit, FetchDiscussionState>(
        builder: (context, state) {
          if (state is FetchDiscussionInProgress) {
            return CustomScrollView(
              slivers: [
                SliverList.separated(
                  itemCount: 5,
                  itemBuilder: (context, index) =>
                      const CustomShimmer(height: 150),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                ),
              ],
            );
          }

          if (state is FetchDiscussionFail) {
            return CustomErrorWidget(
              error: state.error.toString(),
              onRetry: () => context.read<FetchDiscussionCubit>().fetch(),
            );
          }

          if (state is FetchDiscussionSuccess) {
            final List<DiscussionModel> discussions = state.data;

            if (discussions.isEmpty) {
              return Center(
                child: CustomText(
                  AppLabels.noDiscussionsYet.tr,
                  style: Theme.of(context).textTheme.bodyLarge!,
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    CustomText(
                      '${discussions.length} ${AppLabels.discussion.tr}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(fontWeight: .w600),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
                SliverList.separated(
                  itemBuilder: (context, index) {
                    return DiscussionCard(discussion: discussions[index]);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 16);
                  },
                  itemCount: discussions.length,
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
