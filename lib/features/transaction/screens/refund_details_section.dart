import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/common/widgets/custom_error_widget.dart';
import 'package:fitflow/common/widgets/custom_no_data_widget.dart';
import 'package:fitflow/core/constants/app_labels.dart';
import 'package:fitflow/features/transaction/cubit/fetch_my_refunds_cubit.dart';
import 'package:fitflow/features/transaction/widgets/refund_request_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RefundDetailsSection extends StatefulWidget {
  const RefundDetailsSection({super.key});

  @override
  State<RefundDetailsSection> createState() => _RefundDetailsSectionState();
}

class _RefundDetailsSectionState extends State<RefundDetailsSection>
    with
        AutomaticKeepAliveClientMixin,
        Pagination<RefundDetailsSection, FetchMyRefundsCubit> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<FetchMyRefundsCubit>().fetch();
  }

  Future<void> _onRefresh() async {
    await context.read<FetchMyRefundsCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FetchMyRefundsCubit, FetchMyRefundsState>(
      builder: (context, state) {
        if (state is FetchMyRefundsProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FetchMyRefundsError) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomErrorWidget(error: state.error, onRetry: _onRefresh),
          );
        }
        if (state is FetchMyRefundsSuccess) {
          if (state.data.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: const CustomNoDataWidget(titleKey: AppLabels.noDataFound),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              controller: scrollController,
              padding: const .all(16),
              itemCount: state.data.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final refund = state.data[index];
                return RefundRequestCard(refund: refund);
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}
