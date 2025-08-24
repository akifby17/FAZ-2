import 'package:hive_flutter/hive_flutter.dart';

class ApiUrlService {
  final Box<dynamic> _box;
  static const String _apiUrlKey = 'api_base_url';
  static const String _defaultUrl = 'http://95.70.139.125:5100';

  ApiUrlService({required Box<dynamic> box}) : _box = box;

  String getCurrentUrl() {
    return _box.get(_apiUrlKey, defaultValue: _defaultUrl) as String;
  }

  Future<void> updateUrl(String newUrl) async {
    await _box.put(_apiUrlKey, newUrl);
  }

  String get defaultUrl => _defaultUrl;
}
