import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitflow/features/policy/cubit/policy_state.dart';
import 'package:fitflow/features/policy/repository/policy_repository.dart';

class PolicyCubit extends Cubit<PolicyState> {
  final PolicyRepository _repository;

  PolicyCubit(this._repository) : super(PolicyInitial());

  Future<void> fetchPolicySettings({required String type}) async {
    try {
      emit(PolicyProgress());

      final result = await _repository.fetchPolicySettings(type: type);

      emit(PolicySuccess(policySettings: result));
    } catch (e) {
      emit(PolicyError(error: e.toString()));
    }
  }
}
