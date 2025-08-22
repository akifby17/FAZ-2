part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final AppSettings settings;
  final bool isAdminAuthenticated;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = AppSettings.defaultSettings,
    this.isAdminAuthenticated = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
    bool? isAdminAuthenticated,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      isAdminAuthenticated: isAdminAuthenticated ?? this.isAdminAuthenticated,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, settings, isAdminAuthenticated, errorMessage];
}
