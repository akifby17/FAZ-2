import '../repositories/settings_repository.dart';

class UpdateApiUrl {
  final SettingsRepository _repository;

  UpdateApiUrl(this._repository);

  Future<void> call(String newUrl) async {
    // URL validation
    if (!_isValidUrl(newUrl)) {
      throw Exception('Geçersiz URL formatı');
    }

    await _repository.updateApiBaseUrl(newUrl);
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }
}
