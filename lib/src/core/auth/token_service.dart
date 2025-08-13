import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/api_client.dart';

class TokenService {
  TokenService({required ApiClient apiClient, required Box<dynamic> box})
      : _api = apiClient,
        _box = box;

  final ApiClient _api;
  final Box<dynamic> _box;

  static const String _tokenKey = 'access_token';

  Future<String> getToken() async {
    final String? token = _box.get(_tokenKey) as String?;
    if (token != null && token.isNotEmpty) return token;
    return await _loginAndStore();
  }

  Future<void> saveToken(String token) async => _box.put(_tokenKey, token);

  Future<String> _loginAndStore(
      {String username = 'SA', String password = 'MASTER'}) async {
    const String bootstrapBearer =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IlNBIiwibmJmIjoxNzU1MDg5ODgzLCJleHAiOjE3NTU2OTQ2ODMsImlhdCI6MTc1NTA4OTg4MywiaXNzIjoiVGVrc2RhdGEiLCJhdWQiOiJUZWtzZGF0YSJ9.8OvHSqsv7UvcXrvKdbyabprFDGX-v4raRNexoE-5QeE';

    final Response<dynamic> res = await _api.post(
      '/api/users/login',
      data: <String, dynamic>{'userName': username, 'password': password},
      options: Options(headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bootstrapBearer',
      }),
    );

    final Map<String, dynamic> json = (res.data as Map).cast<String, dynamic>();
    final String accessToken = (json['accessToken'] ?? '').toString();
    await saveToken(accessToken);
    return accessToken;
  }
}
