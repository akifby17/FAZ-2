import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/verify_admin_password.dart';
import '../../domain/usecases/update_api_url.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final VerifyAdminPassword _verifyAdminPassword;
  final UpdateApiUrl _updateApiUrl;
  final SettingsRepository _repository;

  SettingsBloc({
    required GetSettings getSettings,
    required VerifyAdminPassword verifyAdminPassword,
    required UpdateApiUrl updateApiUrl,
    required SettingsRepository repository,
  })  : _getSettings = getSettings,
        _verifyAdminPassword = verifyAdminPassword,
        _updateApiUrl = updateApiUrl,
        _repository = repository,
        super(const SettingsState()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<LanguageChanged>(_onLanguageChanged);
    on<AdminPasswordVerified>(_onAdminPasswordVerified);
    on<ApiUrlUpdated>(_onApiUrlUpdated);

  }

  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final settings = await _getSettings();
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.updateLanguage(event.languageCode);
      final updatedSettings =
          state.settings.copyWith(languageCode: event.languageCode);
      emit(state.copyWith(settings: updatedSettings));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAdminPasswordVerified(
    AdminPasswordVerified event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final isValid = await _verifyAdminPassword(event.password);
      emit(state.copyWith(isAdminAuthenticated: isValid));

      if (!isValid) {
        emit(state.copyWith(
          status: SettingsStatus.failure,
          errorMessage:
              'Yanlış şifre!', // This will be handled by UI with localization
          isAdminAuthenticated: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
        isAdminAuthenticated: false,
      ));
    }
  }

  Future<void> _onApiUrlUpdated(
    ApiUrlUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    if (!state.isAdminAuthenticated) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: 'API URL değiştirmek için admin şifresi gerekli!',
      ));
      return;
    }

    try {
      await _updateApiUrl(event.newUrl);
      final updatedSettings = state.settings.copyWith(apiBaseUrl: event.newUrl);
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updatedSettings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
