import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/network/api_client.dart';

class WeaverRemoteDataSource {
  final ApiClient _apiClient = GetIt.I<ApiClient>();

  Future<void> changeWeaver({
    required String loomNo,
    required int weaverId,
  }) async {
    try {
      await _apiClient.post(
        '/api/DataMan/changeWeaver',
        data: {
          'loomNo': loomNo,
          'weaverId': weaverId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to change weaver: $e');
    }
  }
}
