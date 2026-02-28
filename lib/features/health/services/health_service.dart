import 'dart:io';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

/// Unified health data service for Apple HealthKit and Google Health Connect.
/// Provides trainers with client biometric data for personalized training.
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  bool _isAuthorized = false;

  /// Health data types we request access to
  static const List<HealthDataType> _readTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.ACTIVE_CALORIES_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WORKOUT,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
  ];

  static const List<HealthDataType> _writeTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
  ];

  bool get isAuthorized => _isAuthorized;

  /// Request permissions from the user
  Future<bool> requestAuthorization() async {
    try {
      // Configure the health plugin
      await Health().configure();

      _isAuthorized = await _health.requestAuthorization(
        _readTypes,
        permissions: _readTypes.map((_) => HealthDataAccess.READ).toList(),
      );
      return _isAuthorized;
    } catch (e) {
      debugPrint('Health authorization error: $e');
      return false;
    }
  }

  /// Check if health data is available on this device
  Future<bool> isHealthAvailable() async {
    try {
      await Health().configure();
      return await _health.hasPermissions(_readTypes) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Fetch health summary for a given date range
  /// Returns a HealthSummary with aggregated data
  Future<HealthSummary> fetchHealthSummary({
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final startDate = start ?? DateTime(now.year, now.month, now.day);
    final endDate = end ?? now;

    try {
      final List<HealthDataPoint> dataPoints =
          await _health.getHealthDataFromTypes(
        types: _readTypes,
        startTime: startDate,
        endTime: endDate,
      );

      return HealthSummary.fromDataPoints(dataPoints, startDate, endDate);
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      return HealthSummary.empty(startDate, endDate);
    }
  }

  /// Fetch heart rate data for the last N hours
  Future<List<HeartRateReading>> fetchHeartRate({int hours = 24}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(hours: hours));

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: now,
      );

      return data
          .map((dp) => HeartRateReading(
                timestamp: dp.dateFrom,
                bpm:
                    (dp.value as NumericHealthValue).numericValue.toDouble(),
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching heart rate: $e');
      return [];
    }
  }

  /// Fetch sleep data for last N days
  Future<List<SleepRecord>> fetchSleep({int days = 7}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_IN_BED,
        ],
        startTime: start,
        endTime: now,
      );

      // Group by night and calculate totals
      final Map<String, Duration> sleepByDate = {};
      for (final dp in data) {
        if (dp.type == HealthDataType.SLEEP_ASLEEP ||
            dp.type == HealthDataType.SLEEP_IN_BED) {
          final dateKey =
              '${dp.dateFrom.year}-${dp.dateFrom.month}-${dp.dateFrom.day}';
          final duration = dp.dateTo.difference(dp.dateFrom);
          sleepByDate[dateKey] =
              (sleepByDate[dateKey] ?? Duration.zero) + duration;
        }
      }

      return sleepByDate.entries
          .map((e) => SleepRecord(
                date: DateTime.parse(e.key.padLeft(10, '0')),
                totalSleep: e.value,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching sleep data: $e');
      return [];
    }
  }

  /// Fetch step count for today
  Future<int> fetchTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    try {
      final steps = await _health.getTotalStepsInInterval(start, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      return 0;
    }
  }

  /// Fetch workout sessions for last N days
  Future<List<WorkoutRecord>> fetchWorkouts({int days = 7}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: now,
      );

      return data
          .map((dp) => WorkoutRecord(
                startTime: dp.dateFrom,
                endTime: dp.dateTo,
                type: dp.value.toString(),
                calories: 0, // Will be enriched from TOTAL_CALORIES_BURNED
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      return [];
    }
  }
}

/// Aggregated health summary for a date range
class HealthSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalSteps;
  final double avgHeartRate;
  final double restingHeartRate;
  final double? hrv;
  final Duration totalSleep;
  final double caloriesBurned;
  final double? weight;
  final double? bodyFat;
  final int workoutCount;

  HealthSummary({
    required this.startDate,
    required this.endDate,
    required this.totalSteps,
    required this.avgHeartRate,
    required this.restingHeartRate,
    this.hrv,
    required this.totalSleep,
    required this.caloriesBurned,
    this.weight,
    this.bodyFat,
    required this.workoutCount,
  });

  factory HealthSummary.empty(DateTime start, DateTime end) {
    return HealthSummary(
      startDate: start,
      endDate: end,
      totalSteps: 0,
      avgHeartRate: 0,
      restingHeartRate: 0,
      totalSleep: Duration.zero,
      caloriesBurned: 0,
      workoutCount: 0,
    );
  }

  factory HealthSummary.fromDataPoints(
    List<HealthDataPoint> points,
    DateTime start,
    DateTime end,
  ) {
    int steps = 0;
    List<double> heartRates = [];
    double restingHR = 0;
    double? hrv;
    Duration sleep = Duration.zero;
    double calories = 0;
    double? weight;
    double? bodyFat;
    int workouts = 0;

    for (final dp in points) {
      final numVal = dp.value is NumericHealthValue
          ? (dp.value as NumericHealthValue).numericValue.toDouble()
          : 0.0;

      switch (dp.type) {
        case HealthDataType.STEPS:
          steps += numVal.toInt();
          break;
        case HealthDataType.HEART_RATE:
          heartRates.add(numVal);
          break;
        case HealthDataType.RESTING_HEART_RATE:
          restingHR = numVal;
          break;
        case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
          hrv = numVal;
          break;
        case HealthDataType.SLEEP_ASLEEP:
        case HealthDataType.SLEEP_IN_BED:
          sleep += dp.dateTo.difference(dp.dateFrom);
          break;
        case HealthDataType.TOTAL_CALORIES_BURNED:
        case HealthDataType.ACTIVE_CALORIES_BURNED:
          calories += numVal;
          break;
        case HealthDataType.WEIGHT:
          weight = numVal;
          break;
        case HealthDataType.BODY_FAT_PERCENTAGE:
          bodyFat = numVal;
          break;
        case HealthDataType.WORKOUT:
          workouts++;
          break;
        default:
          break;
      }
    }

    return HealthSummary(
      startDate: start,
      endDate: end,
      totalSteps: steps,
      avgHeartRate: heartRates.isEmpty
          ? 0
          : heartRates.reduce((a, b) => a + b) / heartRates.length,
      restingHeartRate: restingHR,
      hrv: hrv,
      totalSleep: sleep,
      caloriesBurned: calories,
      weight: weight,
      bodyFat: bodyFat,
      workoutCount: workouts,
    );
  }

  /// Formatted sleep string
  String get sleepFormatted {
    final hours = totalSleep.inHours;
    final minutes = totalSleep.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Is the client well-rested? (7+ hours)
  bool get isWellRested => totalSleep.inHours >= 7;

  /// Is resting HR elevated? (above 80 could indicate stress/fatigue)
  bool get isHRTElevated => restingHeartRate > 80;
}

class HeartRateReading {
  final DateTime timestamp;
  final double bpm;
  HeartRateReading({required this.timestamp, required this.bpm});
}

class SleepRecord {
  final DateTime date;
  final Duration totalSleep;
  SleepRecord({required this.date, required this.totalSleep});

  String get formatted {
    final hours = totalSleep.inHours;
    final minutes = totalSleep.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class WorkoutRecord {
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final double calories;
  WorkoutRecord({
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.calories,
  });

  Duration get duration => endTime.difference(startTime);
}
