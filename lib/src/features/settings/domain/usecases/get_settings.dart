import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<AppSettings> call() async {
    return await _repository.getSettings();
  }
}
