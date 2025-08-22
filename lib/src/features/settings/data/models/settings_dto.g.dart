// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsDto _$SettingsDtoFromJson(Map<String, dynamic> json) => SettingsDto(
      apiBaseUrl: json['apiBaseUrl'] as String,
      languageCode: json['languageCode'] as String,
      adminPassword: json['adminPassword'] as String,
    );

Map<String, dynamic> _$SettingsDtoToJson(SettingsDto instance) =>
    <String, dynamic>{
      'apiBaseUrl': instance.apiBaseUrl,
      'languageCode': instance.languageCode,
      'adminPassword': instance.adminPassword,
    };
