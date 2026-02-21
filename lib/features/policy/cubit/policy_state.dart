import 'package:fitflow/common/models/blueprints.dart';
import 'package:fitflow/features/policy/models/policy_settings_model.dart';

abstract class PolicyState extends BaseState {}

class PolicyInitial extends PolicyState {}

class PolicyProgress extends PolicyState {}

class PolicySuccess extends PolicyState {
  final PolicySettingsModel policySettings;

  PolicySuccess({required this.policySettings});
}

final class PolicyError extends PolicyState {
  final String error;

  PolicyError({required this.error});
}
