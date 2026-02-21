import 'dart:async';

import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/common/widgets/custom_shimmer.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/login/guest_checker.dart';
import 'package:fitflow/features/help_support/cubits/ask_question_cubit.dart';
import 'package:fitflow/features/help_support/cubits/fetch_questions_cubit.dart';
import 'package:fitflow/features/help_support/cubits/request_private_group_cubit.dart';
import 'package:fitflow/features/help_support/models/discussion_list_arguments.dart';
import 'package:fitflow/features/help_support/models/discussion_topic.dart';
import 'package:fitflow/features/help_support/repositories/help_desk_repository.dart';
import 'package:fitflow/features/help_support/widgets/ask_question_dialog.dart';
import 'package:fitflow/features/help_support/widgets/help_discussion_card.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class DiscussionListScreen extends StatefulWidget {
  const DiscussionListScreen({super.key});

  static Widget route() {
    final arguments = Get.arguments as DiscussionListArguments;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              FetchQuestionsCubit(HelpDeskRepository())
                ..fetch(groupId: arguments.groupId),
        ),
        BlocProvider(
          create: (context) => RequestPrivateGroupCubit(HelpDeskRepository()),
        ),
        BlocProvider(
          create: (context) => AskQuestionCubit(HelpDeskRepository()),
        ),
      ],
      child: const DiscussionListScreen(),
    );
  }

  @override
  State<DiscussionListScreen> createState() => _DiscussionListScreenState();
}

class _DiscussionListScreenState extends State<DiscussionListScreen>
    with Pagination<DiscussionListScreen, FetchQuestionsCubit> {
  late DiscussionListArguments arguments;
  late bool isPrivate;

  @override
  void initState() {
    super.initState();
    arguments = Get.arguments as DiscussionListArguments;
    isPrivate = arguments.privacy == GroupPrivacy.private;
  }

  void _onTapRequestAccess() {
    context.read<RequestPrivateGroupCubit>().requestAccess(
      groupId: arguments.groupId,
    );
  }

  Future<void> _onTapAskQuestion() async {
    GuestChecker.check(
      onNotGuest: () async {
        final result = await UiUtils.showDialog(
          context,
          child: BlocProvider.value(
            value: context.read<AskQuestionCubit>(),
            child: AskQuestionDialog(
              groupId: arguments.groupId,
              topicName: arguments.groupName ?? '',
            ),
          ),
        );

        if (result == true && mounted) {
          unawaited(context.read<FetchQuestionsCubit>().fetch(groupId: arguments.groupId));
          context.read<AskQuestionCubit>().reset();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.discussion.tr,
        showBackButton: true,
      ),
      bottomNavigationBar: isPrivate
          ? null
          : BottomAppBar(
              padding: const .all(8),
              height: kBottomNavigationBarHeight,
              child: CustomButton(
                customTitle: Row(
                  spacing: 8,
                  mainAxisAlignment: .center,
                  children: [
                    CustomImage(AppIcons.addSquare),
                    CustomText(
                      AppLabels.askQuestion.tr,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: context.color.onPrimary,
                      ),
                    ),
                  ],
                ),
                backgroundColor: context.color.darkColor,
                onPressed: _onTapAskQuestion,
              ),
            ),
      body: isPrivate
          ? BlocConsumer<RequestPrivateGroupCubit, RequestPrivateGroupState>(
              listener: (context, state) {
                if (state is RequestPrivateGroupSuccess) {
                  UiUtils.showSnackBar(
                    state.data['message'] ?? AppLabels.requestSent.tr,
                  );
                } else if (state is RequestPrivateGroupError) {
                  UiUtils.showSnackBar(state.error.toString(), isError: true);
                }
              },
              builder: (context, state) {
                return _buildPrivateTopicCard(state);
              },
            )
          : BlocBuilder<FetchQuestionsCubit, FetchQuestionsState>(
              builder: (context, state) {
                if (state is FetchQuestionsProgress) {
                  return _buildLoadingState();
                } else if (state is FetchQuestionsSuccess) {
                  return _buildSuccessState(state);
                } else if (state is FetchQuestionsError) {
                  return _buildErrorState(state);
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildPrivateTopicCard(RequestPrivateGroupState state) {
    final bool isLoading = state is RequestPrivateGroupProgress;
    final bool isSuccess = state is RequestPrivateGroupSuccess;

    return Center(
      child: CustomCard(
        padding: const .all(20),
        margin: const .all(16),
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .center,
          children: [
            CustomText(
              AppLabels.privateGroup.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: .w500),
              textAlign: .center,
            ),
            const SizedBox(height: 8),
            CustomText(
              AppLabels.sendRequestToJoin.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: .w400),
              textAlign: .center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              height: 40,
              title: isSuccess
                  ? AppLabels.requestSent.tr
                  : AppLabels.sendRequest.tr,
              onPressed: isLoading || isSuccess ? null : _onTapRequestAccess,
              customTitle: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCountsShimmer(),
          const Divider(height: 1),
          ListView.separated(
            itemCount: 5,
            shrinkWrap: true,
            padding: const .all(16),
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              return const CustomShimmer(height: 100);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(FetchQuestionsSuccess state) {
    if (state.data.isEmpty) {
      return Center(
        child: CustomText(
          AppLabels.noQuestionsFound.tr,
          style: Theme.of(context).textTheme.bodyLarge!,
        ),
      );
    }

    // Extract totals from API response if available
    final totalQuestions = state.total;
    final totalReplies = state.data.fold<int>(
      0,
      (sum, question) => sum + question.repliesCount,
    );

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          _buildCounts(
            totalQuestions: totalQuestions,
            totalReplies: totalReplies,
          ),
          const Divider(height: 1),
          ListView.separated(
            itemCount: state.data.length + (state.isLoadingMore ? 1 : 0),
            shrinkWrap: true,
            padding: const .all(16),
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              if (index == state.data.length && state.isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: .all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final question = state.data[index];
              return HelpDiscussionCard(question: question);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FetchQuestionsError state) {
    return Center(
      child: Padding(
        padding: const .all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            CustomText(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium!,
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: AppLabels.retry.tr,
              onPressed: () {
                context.read<FetchQuestionsCubit>().fetch(
                  groupId: arguments.groupId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountsShimmer() {
    return const Padding(
      padding: .all(12),
      child: Row(
        spacing: 20,
        children: [
          CustomShimmer(width: 150, height: 24),
          CustomShimmer(width: 150, height: 24),
        ],
      ),
    );
  }

  Widget _buildCounts({
    required int totalQuestions,
    required int totalReplies,
  }) {
    return Padding(
      padding: const .all(12),
      child: Row(
        spacing: 20,
        children: [
          _buildCount(
            icon: AppIcons.questionMessage,
            count: totalQuestions,
            title: AppLabels.question.tr,
          ),
          _buildCount(
            icon: AppIcons.redu,
            count: totalReplies,
            title: AppLabels.repliesCount.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildCount({
    required String icon,
    required int count,
    required String title,
  }) {
    return Row(
      children: [
        CustomImage(
          icon,
          width: 24,
          height: 24,
          color: context.color.onSurface,
        ),
        const SizedBox(width: 2),
        CustomText(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
        ),
        const SizedBox(width: 8),
        CustomText(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: .w500),
        ),
      ],
    );
  }
}
