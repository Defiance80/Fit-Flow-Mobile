import 'package:fitflow/features/health/screens/health_consent_screen.dart';
import 'package:fitflow/common/widgets/custom_app_bar.dart';
import 'package:fitflow/common/widgets/custom_button.dart';
import 'package:fitflow/common/widgets/custom_card.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/features/health/cubits/health_cubit.dart';
import 'package:fitflow/features/health/services/health_service.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  static Widget route() => const _HealthDashboardWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health & Wellness'),
      body: BlocBuilder<HealthCubit, HealthState>(
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HealthNotAuthorized) {
            return _buildConnectPrompt(context);
          }

          if (state is HealthDataLoaded) {
            return _buildDashboard(context, state);
          }

          if (state is HealthError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildConnectPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: AppColors.accentColor,
          ),
          const SizedBox(height: 24),
          CustomText(
            'Connect Your Health Data',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          CustomText(
            'Link Apple Health or Google Health Connect so your trainer can personalize your programs based on your sleep, heart rate, and activity levels.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: context.color.onSurface.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () {
                context.read<HealthCubit>().requestAccess();
              },
              title: 'Connect Health App',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, HealthDataLoaded state) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () => context.read<HealthCubit>().fetchHealthData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            CustomText(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            // Top stat cards row
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.directions_walk_rounded,
                    label: 'Steps',
                    value: '${state.todaySteps}',
                    color: AppColors.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value: '${summary.caloriesBurned.toInt()}',
                    color: AppColors.accentColor,
                  ),
                ),
              ],
            ),

            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.favorite_rounded,
                    label: 'Avg HR',
                    value: '${summary.avgHeartRate.toInt()} bpm',
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.bedtime_rounded,
                    label: 'Sleep',
                    value: summary.sleepFormatted,
                    color: Colors.indigo,
                    alert: !summary.isWellRested,
                  ),
                ),
              ],
            ),

            // Resting HR + HRV
            CustomCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  CustomText(
                    'Recovery Indicators',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          context,
                          'Resting HR',
                          '${summary.restingHeartRate.toInt()} bpm',
                          summary.isHRTElevated
                              ? Colors.orange
                              : AppColors.successColor,
                        ),
                      ),
                      if (summary.hrv != null)
                        Expanded(
                          child: _buildMiniStat(
                            context,
                            'HRV',
                            '${summary.hrv!.toInt()} ms',
                            AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  if (summary.isHRTElevated)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        spacing: 8,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.orange, size: 18),
                          Expanded(
                            child: CustomText(
                              'Resting heart rate is elevated — consider lighter intensity today.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.orange.shade800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Workouts
            CustomCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.fitness_center_rounded,
                      color: AppColors.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Workouts Today',
                          style: Theme.of(context).textTheme.titleSmall!,
                        ),
                        CustomText(
                          '${summary.workoutCount} session${summary.workoutCount == 1 ? '' : 's'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: context.color.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool alert = false,
  }) {
    return CustomCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          CustomText(
            value,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Row(
            children: [
              CustomText(
                label,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: context.color.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              if (alert) ...[
                const SizedBox(width: 4),
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: Colors.orange),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: context.color.onSurface.withValues(alpha: 0.6),
              ),
        ),
        CustomText(
          value,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _HealthDashboardWrapper extends StatefulWidget {
  const _HealthDashboardWrapper();

  @override
  State<_HealthDashboardWrapper> createState() => _HealthDashboardWrapperState();
}

class _HealthDashboardWrapperState extends State<_HealthDashboardWrapper> {
  bool? _hasConsent;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final consented = await HealthConsentScreen.hasConsented();
    setState(() => _hasConsent = consented);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasConsent == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasConsent!) {
      return HealthConsentScreen(
        onConsented: () => setState(() => _hasConsent = true),
      );
    }

    return BlocProvider(
      create: (_) => HealthCubit()..checkAuthorization(),
      child: const HealthDashboardScreen(),
    );
  }
}
