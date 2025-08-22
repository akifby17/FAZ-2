part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsLoaded extends SettingsEvent {}

class LanguageChanged extends SettingsEvent {
  final String languageCode;

  const LanguageChanged(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

class AdminPasswordVerified extends SettingsEvent {
  final String password;

  const AdminPasswordVerified(this.password);

  @override
  List<Object> get props => [password];
}

class ApiUrlUpdated extends SettingsEvent {
  final String newUrl;

  const ApiUrlUpdated(this.newUrl);

  @override
  List<Object> get props => [newUrl];
}


