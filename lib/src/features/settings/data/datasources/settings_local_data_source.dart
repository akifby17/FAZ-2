import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_dto.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsDto> getSettings();
  Future<void> saveSettings(SettingsDto settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box<dynamic> _box;

  SettingsLocalDataSourceImpl({required Box<dynamic> box}) : _box = box;

  static const String _settingsKey = 'app_settings';

  @override
  Future<SettingsDto> getSettings() async {
    final Map<dynamic, dynamic>? data =
        _box.get(_settingsKey) as Map<dynamic, dynamic>?;

    if (data != null) {
      return SettingsDto.fromJson(Map<String, dynamic>.from(data));
    }

    // Return default settings if not found
    return SettingsDto.defaultSettings();
  }

  @override
  Future<void> saveSettings(SettingsDto settings) async {
    await _box.put(_settingsKey, settings.toJson());
  }
}
