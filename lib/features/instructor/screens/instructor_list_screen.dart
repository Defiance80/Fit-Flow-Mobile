import 'package:fitflow/common/cubits/paginated_api_states.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_shimmer.dart';
import 'package:fitflow/core/routes/routes.dart';
import 'package:fitflow/features/instructor/cubit/instructor_cubit.dart';
import 'package:fitflow/features/instructor/models/instructor_list_arguments.dart';
import 'package:fitflow/features/instructor/widgets/instructor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class InstructorListScreen extends StatefulWidget {
  final String title;
  final int? featureSectionId;

  const InstructorListScreen({
    super.key,
    required this.title,
    this.featureSectionId,
  });

  static Widget route() {
    final arguments = Get.arguments;
    final String title;
    final int? featureSectionId;

    if (arguments is InstructorListArguments) {
      title = arguments.title;
      featureSectionId = arguments.featureSectionId;
    } else {
      title = arguments as String;
      featureSectionId = null;
    }

    return BlocProvider(
      create: (context) => InstructorCubit(featureSectionId: featureSectionId),
      child: InstructorListScreen(
        title: title,
        featureSectionId: featureSectionId,
      ),
    );
  }

  @override
  State<InstructorListScreen> createState() => _InstructorListScreenState();
}

class _InstructorListScreenState extends State<InstructorListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InstructorCubit>().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        showBackButton: true,
      ),
      body: BlocBuilder<InstructorCubit, PaginatedApiState>(
        builder: (context, state) {
          if (state is PaginatedApiLoadingState) {
            return const ShimmerBuilder(
              shimmer: InstructorCardShimmer(),
              spacing: 16,
              itemCount: 3,
              padding: .all(16),
            );
          }
          if (state is PaginatedApiSuccessState) {
            return ListView.separated(
              padding: const .all(16),
              itemCount: state.data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return InstructorCard.detailed(
                  instructor: state.data[index],
                  onTap: () {
                    Get.toNamed(AppRoutes.instructorDetailsScreen,
                        arguments: state.data[index]);
                  },
                );
              },
            );
          }
          if (state is PaginatedApiFailureState) {
            return Center(
              child: Text('Error: ${state.exception.message}'),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
