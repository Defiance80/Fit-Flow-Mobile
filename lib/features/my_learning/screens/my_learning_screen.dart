import 'package:fitflow/common/cubits/paginated_api_states.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/widgets/course_card.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_shimmer.dart';
import 'package:fitflow/common/widgets/custom_error_widget.dart';
import 'package:fitflow/common/widgets/custom_no_data_widget.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/services/refresh_notifier.dart';
import 'package:fitflow/features/my_learning/cubit/my_learning_cubit.dart';
import 'package:fitflow/utils/extensions/color_extension.dart';
import 'package:fitflow/utils/course_navigation_helper.dart';
import 'package:fitflow/utils/extensions/scroll_extension.dart';
import 'package:flutter/material.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  static Widget route() => const MyLearningScreen();

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(title: AppLabels.myLearning.tr),
        body: Column(
          children: [
            _buildTabSelector(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMyLearnings('all'),
                  _buildMyLearnings('in_progress'),
                  _buildMyLearnings('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
      ).add(const EdgeInsetsDirectional.only(top: 10)),
      padding: const .all(6),
      child: TabBar(
        tabs: [
          Tab(text: AppLabels.all.tr),
          Tab(text: AppLabels.ongoing.tr),
          Tab(text: AppLabels.complete.tr),
        ],
        dividerHeight: 0,
        splashBorderRadius: BorderRadius.circular(100),
        indicatorSize: .tab,
        indicatorColor: context.color.primary,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: context.color.primary,
        ),
        labelStyle: TextStyle(
          color: context.color.primary.getAdaptiveTextColor(),
          fontWeight: .w500,
          height: 1.25,
        ),
        unselectedLabelStyle: TextStyle(
          color: context.color.onSurface,
          fontWeight: .w500,
        ),
      ),
    );
  }

  Widget _buildMyLearnings(String status) {
    return BlocProvider(
      create: (context) => MyLearningCubit(status)..fetchData(),
      child: const _MyLearningTabView(),
    );
  }
}

class _MyLearningTabView extends StatefulWidget {
  const _MyLearningTabView();

  @override
  State<_MyLearningTabView> createState() => _MyLearningTabViewState();
}

class _MyLearningTabViewState extends State<_MyLearningTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addEndListener(() {
      if (context.read<MyLearningCubit>().hasMore) {
        context.read<MyLearningCubit>().fetchMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<MyLearningCubit, PaginatedApiState>(
      builder: (context, state) {
        if (state is PaginatedApiLoadingState) {
          return ListView.separated(
            padding: const .all(16),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => const CustomShimmer(height: 135),
          );
        }

        if (state is PaginatedApiFailureState) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<MyLearningCubit>().fetchData();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: CustomErrorWidget(
                        error: state.exception.toString(),
                        onRetry: () => context.read<MyLearningCubit>().fetchData(),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (state is PaginatedApiSuccessState<CourseModel>) {
          if (state.data.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<MyLearningCubit>().fetchData();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: const Center(
                        child: CustomNoDataWidget(
                          titleKey: "my_learning_empty",
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<MyLearningCubit>().fetchData();
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const .all(16),
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,

                    itemBuilder: (context, index) {
                      final CourseModel course = state.data[index];
                      return _buildCourseCard(course);
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemCount: state.data.length,
                  ),
                ),
                if (state is PaginatedApiLoadingMore)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return SizedBox(
      height: 142,
      child: CourseCard.learning(
        course: course,
        onTap: () => _onTapCourse(course),
        otherOptions: true,
      ),
    );
  }

  void _onTapCourse(CourseModel course) async {
    await CourseNavigationHelper.navigateToCourse(course);

    // Check if refresh is needed when returning from course screen
    if (mounted && RefreshNotifier.instance.consumeMyLearningRefresh()) {
      await context.read<MyLearningCubit>().fetchData();
    }
  }
}
