import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_dto.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl({required SettingsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<AppSettings> getSettings() async {
    final dto = await _localDataSource.getSettings();
    return dto.toDomain();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final dto = SettingsDto.fromDomain(settings);
    await _localDataSource.saveSettings(dto);
  }

  @override
  Future<bool> verifyAdminPassword(String password) async {
    final settings = await getSettings();
    return settings.adminPassword == password;
  }

  @override
  Future<void> updateAdminPassword(String newPassword) async {
    final currentSettings = await getSettings();
    final updatedSettings =
        currentSettings.copyWith(adminPassword: newPassword);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateApiBaseUrl(String newUrl) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(apiBaseUrl: newUrl);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    final currentSettings = await getSettings();
    final updatedSettings =
        currentSettings.copyWith(languageCode: languageCode);
    await saveSettings(updatedSettings);
  }
}
