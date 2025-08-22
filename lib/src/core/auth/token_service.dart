import 'package:hive_flutter/hive_flutter.dart';

/// Token servisi - artık yetkilendirme yok, sadece placeholder olarak kalıyor
class TokenService {
  TokenService({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  static const String _tokenKey = 'access_token';

  /// API'de artık yetkilendirme yok, boş string döndür
  Future<String> getToken() async {
    print('🔓 TokenService: API\'de yetkilendirme yok, boş token döndürülüyor');
    return '';
  }

  /// Placeholder - artık kullanılmıyor
  Future<void> saveToken(String token) async => _box.put(_tokenKey, token);

  /// API'de yetkilendirme olmadığı için login gereksiz
  void clearToken() => _box.delete(_tokenKey);
}
