import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_card.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/common/widgets/custom_no_data_widget.dart';
import 'package:elms/common/widgets/custom_shimmer.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/features/authentication/cubit/authentication_cubit.dart';
import 'package:elms/features/wallet/cubit/fetch_wallet_history_cubit.dart';
import 'package:elms/features/wallet/repository/wallet_repository.dart';
import 'package:elms/features/wallet/widgets/wallet_card_widget.dart';
import 'package:elms/features/wallet/widgets/wallet_transaction_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static Widget route() {
    return BlocProvider(
      create: (context) => FetchWalletHistoryCubit(WalletRepository())..fetch(),
      child: const WalletScreen(),
    );
  }

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with Pagination<WalletScreen, FetchWalletHistoryCubit> {
  bool isWalletRequestPending = false;

  ///By-default its true because otherwise user will try to withdraw money when its still loading
  bool isWalletRequestsLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLabels.wallet.tr, showBackButton: true),
      body: RefreshIndicator(
        onRefresh: () {
          context.read<AuthenticationCubit>().refreshUserDetails();
          return context.read<FetchWalletHistoryCubit>().fetch();
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (isWalletRequestPending && !isWalletRequestsLoading)
              SliverPadding(
                padding: const .only(left: 16, right: 16, top: 16, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: _buildPendingRequestNote(context),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: isWalletRequestPending && !isWalletRequestsLoading
                    ? 8
                    : 16,
                bottom: 16,
              ),
              sliver: SliverToBoxAdapter(
                child: WalletCardWidget(
                  shouldDisableWithdrawButton:
                      isWalletRequestPending || isWalletRequestsLoading,
                  onWithdrawalSuccess: () {
                    context.read<FetchWalletHistoryCubit>().fetch();
                  },
                ),
              ),
            ),
            BlocConsumer<FetchWalletHistoryCubit, FetchWalletHistoryState>(
              listener: (context, state) {
                if (state is FetchWalletHistoryProgress) {
                  isWalletRequestsLoading = true;
                  setState(() {});
                }
                if (state is FetchWalletHistorySuccess) {
                  isWalletRequestsLoading = false;
                  isWalletRequestPending = state.isWalletRequestPending;
                  setState(() {});
                }
              },
              builder: (context, state) {
                if (state is FetchWalletHistoryProgress) {
                  return _buildShimmerLoading();
                }

                if (state is FetchWalletHistoryError) {
                  return SliverFillRemaining(
                    child: CustomErrorWidget(
                      error: state.error.toString(),
                      onRetry: () {
                        context.read<FetchWalletHistoryCubit>().fetch();
                      },
                    ),
                  );
                }

                if (state is FetchWalletHistorySuccess) {
                  if (state.data.isEmpty) {
                    return const SliverFillRemaining(
                      child: CustomNoDataWidget(
                        titleKey: AppLabels.noTransactionsFound,
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const .symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount:
                          state.data.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == state.data.length) {
                          return const Center(
                            child: Padding(
                              padding: .all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final transaction = state.data[index];
                        return WalletTransactionCard(transaction: transaction);
                      },
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
            const SliverPadding(padding: .only(bottom: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SliverPadding(
      padding: const .symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return const CustomShimmer(height: 150, borderRadius: 12);
        },
      ),
    );
  }

  Widget _buildPendingRequestNote(BuildContext context) {
    return CustomCard(
      padding: const .all(12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.color.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              AppLabels.withdrawalRequestPending.tr,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: context.color.onSurface),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
