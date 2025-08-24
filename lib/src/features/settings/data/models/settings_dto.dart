import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_dto.g.dart';

@JsonSerializable()
class SettingsDto {
  final String apiBaseUrl;
  final String languageCode;
  final String adminPassword;

  const SettingsDto({
    required this.apiBaseUrl,
    required this.languageCode,
    required this.adminPassword,
  });

  factory SettingsDto.fromJson(Map<String, dynamic> json) =>
      _$SettingsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsDtoToJson(this);

  factory SettingsDto.fromDomain(AppSettings settings) {
    return SettingsDto(
      apiBaseUrl: settings.apiBaseUrl,
      languageCode: settings.languageCode,
      adminPassword: settings.adminPassword,
    );
  }

  AppSettings toDomain() {
    return AppSettings(
      apiBaseUrl: apiBaseUrl,
      languageCode: languageCode,
      adminPassword: adminPassword,
    );
  }

  static SettingsDto defaultSettings() {
    return const SettingsDto(
      apiBaseUrl: 'http://95.70.139.125:5100',
      languageCode: 'tr',
      adminPassword: '27526',
    );
  }
}
