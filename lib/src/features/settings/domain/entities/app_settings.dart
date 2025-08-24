import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String apiBaseUrl;
  final String languageCode;
  final String adminPassword;

  const AppSettings({
    required this.apiBaseUrl,
    required this.languageCode,
    required this.adminPassword,
  });

  AppSettings copyWith({
    String? apiBaseUrl,
    String? languageCode,
    String? adminPassword,
  }) {
    return AppSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      languageCode: languageCode ?? this.languageCode,
      adminPassword: adminPassword ?? this.adminPassword,
    );
  }

  @override
  List<Object?> get props => [apiBaseUrl, languageCode, adminPassword];

  // Default settings
  static const AppSettings defaultSettings = AppSettings(
    apiBaseUrl: 'http://95.70.139.125:5100',
    languageCode: 'tr',
    adminPassword: '27526',
  );
}
