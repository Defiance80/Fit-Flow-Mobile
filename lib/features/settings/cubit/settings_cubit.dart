import 'package:elms/features/settings/models/system_setting_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/features/settings/cubit/settings_state.dart';
import 'package:elms/features/settings/repository/settings_repository.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(SettingsInitial());

  Future<void> fetchAppSettings() async {
    try {
      emit(SettingsProgress());

      final result = await _repository.fetchAppSettings();

      emit(SettingsSuccess(settings: result));
    } catch (e) {
      emit(SettingsError(error: e.toString()));
    }
  }

  String get currencySymbol {
    if (state case final SettingsSuccess success) {
      return success.settings.currencySymbol ?? '';
    }
    return '';
  }

  AppSettingModel? get settings {
    if (state case final SettingsSuccess success) {
      return success.settings;
    }
    return null;
  }
}
