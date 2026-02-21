import 'package:fitflow/common/cubits/course_list_cubit.dart';
import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/models/category_model.dart';
import 'package:fitflow/common/models/course_list_dataclass.dart';
import 'package:fitflow/common/models/course_model.dart';
import 'package:fitflow/common/widgets/course_card.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_error_widget.dart';
import 'package:fitflow/common/widgets/custom_icon_button.dart';
import 'package:fitflow/common/widgets/custom_no_data_widget.dart';
import 'package:fitflow/common/widgets/custom_shimmer.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/features/category/cubits/subcategory_cubit.dart';
import 'package:fitflow/features/category/repositories/category_repository.dart';
import 'package:fitflow/features/course/models/filter.dart';
import 'package:fitflow/features/course/repository/course_repository.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:fitflow/utils/course_navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CourseListScreen extends StatefulWidget {
  final CourseListType screenType;
  const CourseListScreen({super.key, required this.screenType});

  static Widget route() {
    final CourseListType type = Get.arguments as CourseListType;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourseListCubit(CourseRepository())
            ..setListType(type)
            ..fetch(),
        ),
        BlocProvider(
          create: (context) {
            final cubit = SubcategoryCubit(CategoryRepository());
            if (type is CourseListForCategory) {
              cubit.fetchSubcategories(type.category.id);
            }
            return cubit;
          },
        ),
      ],
      child: CourseListScreen(screenType: type),
    );
  }

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with Pagination<CourseListScreen, CourseListCubit> {
  final ValueNotifier<bool> filterApplied = ValueNotifier(false);

  void _onTapFilter() {
    Get.toNamed(
      AppRoutes.filterScreen,
      arguments: context.read<CourseListCubit>().courseFilters,
    )?.then((value) {
      if (value is List<Filter>) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          context.read<CourseListCubit>().applyFilters(value);
          // ignore: use_build_context_synchronously
          filterApplied.value = context
              .read<CourseListCubit>()
              .courseFilters
              .hasAppliedFilters;
        }
      }
    });
  }

  void _onTapRefresh() {
    context.read<CourseListCubit>().refresh();
  }

  @override
  void dispose() {
    filterApplied.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.screenType.screenTitle,
        showBackButton: true,
        actions: [
          if (widget.screenType.showFilters)
            ValueListenableBuilder(
              valueListenable: filterApplied,
              builder: (context, value, _) {
                return CustomIconButton(
                  image: AppIcons.filter,
                  color: value
                      ? context.color.primary
                      : context.color.onSurface,
                  onTap: _onTapFilter,
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _onTapRefresh();
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            if (widget.screenType is CourseListForCategory) ...[
              _buildSubCategories(),
            ],
            BlocBuilder<CourseListCubit, CourseListState>(
              builder: (context, state) {
                return switch (state) {
                  CourseListProgress() => _buildShimmerList(),
                  CourseListSuccess() => _buildCourseList(state),
                  CourseListError() => _buildErrorWidget(state.error),
                  _ => _buildEmptyWidget(),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategories() {
    return SliverToBoxAdapter(
      child: BlocBuilder<SubcategoryCubit, SubcategoryState>(
        builder: (context, state) {
          return switch (state) {
            SubcategoryProgress() => _buildSubcategoryShimmer(),
            SubcategorySuccess() =>
              state.data.isNotEmpty
                  ? _buildSubcategoryList(state.data)
                  : const SizedBox.shrink(),
            SubcategoryError() => CustomErrorWidget(error: state.error),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildSubcategoryShimmer() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        // ignore: prefer_const_constructors
        padding: .symmetric(horizontal: 16).add(.only(top: 8)),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            6,
            (index) =>
                const CustomShimmer(height: 32, width: 80, margin: .zero),
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryList(List<CategoryModel> subcategories) {
    final int itemsPerRow = (subcategories.length / 2).ceil();
    final List<CategoryModel> firstRow = subcategories
        .take(itemsPerRow)
        .toList();
    final List<CategoryModel> secondRow = subcategories
        .skip(itemsPerRow)
        .toList();

    return Padding(
      // ignore: prefer_const_constructors
      padding: .symmetric(horizontal: 16).add(.only(top: 16)),
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            if (firstRow.isNotEmpty)
              Row(
                children: firstRow.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final CategoryModel subcategory = entry.value;
                  return Padding(
                    padding: .only(right: index < firstRow.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => _onTapSubcategory(subcategory),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: context.color.outline),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const .symmetric(vertical: 8, horizontal: 14),
                        child: Text(subcategory.name),
                      ),
                    ),
                  );
                }).toList(),
              ),
            if (secondRow.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: secondRow.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final CategoryModel subcategory = entry.value;
                  return Padding(
                    padding: .only(right: index < secondRow.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => _onTapSubcategory(subcategory),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: context.color.outline),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const .symmetric(vertical: 8, horizontal: 14),
                        child: Text(subcategory.name),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onTapSubcategory(CategoryModel subcategory) {
    Get.toNamed(
      AppRoutes.courseListScreen,
      preventDuplicates: false,
      arguments: CourseListForCategory(
        category: subcategory,
        screenTitle: subcategory.name,
      ),
    );
  }

  Widget _buildCourseList(CourseListSuccess state) {
    if (state.data.isEmpty) {
      return _buildEmptyWidget();
    }

    return SliverPadding(
      padding: const .all(16),
      sliver: SliverList.separated(
        itemCount: state.data.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) {
          return const SizedBox(height: 16);
        },
        itemBuilder: (context, index) {
          if (index == state.data.length) {
            return const Center(
              child: Padding(
                padding: .all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final CourseModel course = state.data[index];
          return CourseCard.horizontal(
            course: course,
            height: 200,
            onTap: () async =>
                await CourseNavigationHelper.navigateToCourse(course),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: const .all(16),
      sliver: SliverList.separated(
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const CustomShimmer(
          height: 200,
          width: double.infinity,
          margin: .zero,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return SliverFillRemaining(
      child: CustomErrorWidget(error: error, onRetry: _onTapRefresh),
    );
  }

  Widget _buildEmptyWidget() {
    return const SliverFillRemaining(
      child: CustomNoDataWidget(titleKey: AppLabels.noCoursesFound),
    );
  }
}
