/// Model for health data to be sent to/from the backend API
/// This is what trainers see in their dashboard
class ClientHealthData {
  final int clientId;
  final String clientName;
  final DateTime lastSynced;
  final DailySummary today;
  final WeeklySummary thisWeek;
  final List<HealthAlert> alerts;

  ClientHealthData({
    required this.clientId,
    required this.clientName,
    required this.lastSynced,
    required this.today,
    required this.thisWeek,
    required this.alerts,
  });

  factory ClientHealthData.fromJson(Map<String, dynamic> json) {
    return ClientHealthData(
      clientId: json['client_id'],
      clientName: json['client_name'],
      lastSynced: DateTime.parse(json['last_synced']),
      today: DailySummary.fromJson(json['today']),
      thisWeek: WeeklySummary.fromJson(json['this_week']),
      alerts: (json['alerts'] as List?)
              ?.map((a) => HealthAlert.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'client_name': clientName,
        'last_synced': lastSynced.toIso8601String(),
        'today': today.toJson(),
        'this_week': thisWeek.toJson(),
        'alerts': alerts.map((a) => a.toJson()).toList(),
      };
}

class DailySummary {
  final int steps;
  final double caloriesBurned;
  final double avgHeartRate;
  final double restingHeartRate;
  final double? hrv;
  final double sleepHours;
  final int workoutMinutes;

  DailySummary({
    required this.steps,
    required this.caloriesBurned,
    required this.avgHeartRate,
    required this.restingHeartRate,
    this.hrv,
    required this.sleepHours,
    required this.workoutMinutes,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      steps: json['steps'] ?? 0,
      caloriesBurned: (json['calories_burned'] ?? 0).toDouble(),
      avgHeartRate: (json['avg_heart_rate'] ?? 0).toDouble(),
      restingHeartRate: (json['resting_heart_rate'] ?? 0).toDouble(),
      hrv: json['hrv']?.toDouble(),
      sleepHours: (json['sleep_hours'] ?? 0).toDouble(),
      workoutMinutes: json['workout_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'calories_burned': caloriesBurned,
        'avg_heart_rate': avgHeartRate,
        'resting_heart_rate': restingHeartRate,
        'hrv': hrv,
        'sleep_hours': sleepHours,
        'workout_minutes': workoutMinutes,
      };
}

class WeeklySummary {
  final int avgSteps;
  final double avgSleepHours;
  final double avgRestingHR;
  final int totalWorkouts;
  final double totalCalories;
  final String trend; // 'improving', 'stable', 'declining'

  WeeklySummary({
    required this.avgSteps,
    required this.avgSleepHours,
    required this.avgRestingHR,
    required this.totalWorkouts,
    required this.totalCalories,
    required this.trend,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      avgSteps: json['avg_steps'] ?? 0,
      avgSleepHours: (json['avg_sleep_hours'] ?? 0).toDouble(),
      avgRestingHR: (json['avg_resting_hr'] ?? 0).toDouble(),
      totalWorkouts: json['total_workouts'] ?? 0,
      totalCalories: (json['total_calories'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'stable',
    );
  }

  Map<String, dynamic> toJson() => {
        'avg_steps': avgSteps,
        'avg_sleep_hours': avgSleepHours,
        'avg_resting_hr': avgRestingHR,
        'total_workouts': totalWorkouts,
        'total_calories': totalCalories,
        'trend': trend,
      };
}

class HealthAlert {
  final String type; // 'low_sleep', 'high_resting_hr', 'inactive', 'overtraining'
  final String message;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime timestamp;

  HealthAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      type: json['type'],
      message: json['message'],
      severity: json['severity'] ?? 'info',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message,
        'severity': severity,
        'timestamp': timestamp.toIso8601String(),
      };
}
