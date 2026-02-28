import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitflow/features/health/services/health_service.dart';

// States
abstract class HealthState {}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthNotAuthorized extends HealthState {}

class HealthAuthorized extends HealthState {}

class HealthDataLoaded extends HealthState {
  final HealthSummary summary;
  final int todaySteps;
  final List<HeartRateReading> recentHeartRate;
  HealthDataLoaded({
    required this.summary,
    required this.todaySteps,
    required this.recentHeartRate,
  });
}

class HealthError extends HealthState {
  final String message;
  HealthError(this.message);
}

// Cubit
class HealthCubit extends Cubit<HealthState> {
  final HealthService _healthService = HealthService();

  HealthCubit() : super(HealthInitial());

  Future<void> checkAuthorization() async {
    emit(HealthLoading());
    final hasPermission = await _healthService.isHealthAvailable();
    if (hasPermission) {
      emit(HealthAuthorized());
    } else {
      emit(HealthNotAuthorized());
    }
  }

  Future<void> requestAccess() async {
    emit(HealthLoading());
    final authorized = await _healthService.requestAuthorization();
    if (authorized) {
      emit(HealthAuthorized());
      await fetchHealthData();
    } else {
      emit(HealthNotAuthorized());
    }
  }

  Future<void> fetchHealthData() async {
    emit(HealthLoading());
    try {
      final summary = await _healthService.fetchHealthSummary();
      final steps = await _healthService.fetchTodaySteps();
      final heartRate = await _healthService.fetchHeartRate(hours: 6);

      emit(HealthDataLoaded(
        summary: summary,
        todaySteps: steps,
        recentHeartRate: heartRate,
      ));
    } catch (e) {
      emit(HealthError('Failed to load health data: $e'));
    }
  }
}
