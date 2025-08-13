import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/tezgah_dto.dart';

abstract class TezgahRemoteDataSource {
  Future<List<TezgahDto>> fetchTezgahlar({String? group});
  Future<void> startOperation({required List<String> tezgahIds});
  Future<void> endOperation({required List<String> tezgahIds});
}

class TezgahRemoteDataSourceImpl implements TezgahRemoteDataSource {
  final ApiClient apiClient;

  TezgahRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TezgahDto>> fetchTezgahlar({String? group}) async {
    try {
      final Response<dynamic> res = await apiClient.get(
        '/api/looms/monitoring',
        queryParameters: group == null || group.isEmpty
            ? null
            : <String, dynamic>{'group': group},
        options: Options(headers: {'accept': 'application/json'}),
      );

      final dynamic body = res.data;
      late final List<dynamic> listJson;
      if (body is List) {
        listJson = body;
      } else if (body is Map && body['data'] is List) {
        listJson = body['data'] as List<dynamic>;
      } else if (body is Map) {
        // Herhangi bir liste değeri varsa onu kullan
        final Iterable<dynamic> values = body.values;
        final dynamic firstList =
            values.firstWhere((v) => v is List, orElse: () => <dynamic>[]);
        listJson = (firstList is List) ? firstList : <dynamic>[];
      } else {
        listJson = <dynamic>[];
      }

      return listJson
          .map((dynamic e) =>
              TezgahDto.fromJson((e as Map?)?.cast<String, dynamic>() ?? {}))
          .toList();
    } on DioException {
      rethrow; // ağ hatasını yukarı iletelim (BLoC failure gösterecek)
    } catch (_) {
      // Beklenmeyen parse hatasında boş liste dönerek UI'nin çalışmasını sağlayalım
      return <TezgahDto>[];
    }
  }

  @override
  Future<void> startOperation({required List<String> tezgahIds}) async {
    await apiClient.post('/operations/start', data: {'ids': tezgahIds});
  }

  @override
  Future<void> endOperation({required List<String> tezgahIds}) async {
    await apiClient.post('/operations/end', data: {'ids': tezgahIds});
  }
}
