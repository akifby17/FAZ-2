import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';
import '../../../../core/services/api_url_service.dart';

class GetSettings {
  final SettingsRepository _repository;
  final ApiUrlService _apiUrlService;

  GetSettings(this._repository, this._apiUrlService);

  Future<AppSettings> call() async {
    final settings = await _repository.getSettings();
    
    // ApiUrlService'i settings'deki URL ile senkronize et
    final currentApiUrl = _apiUrlService.getCurrentUrl();
    if (currentApiUrl != settings.apiBaseUrl) {
      await _apiUrlService.updateUrl(settings.apiBaseUrl);
      print('🔄 ApiUrlService senkronize edildi: ${settings.apiBaseUrl}');
    }
    
    return settings;
  }
}
