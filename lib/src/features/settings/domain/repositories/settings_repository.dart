import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<bool> verifyAdminPassword(String password);
  Future<void> updateAdminPassword(String newPassword);
  Future<void> updateApiBaseUrl(String newUrl);
  Future<void> updateLanguage(String languageCode);
}
