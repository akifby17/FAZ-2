import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/operation_dto.dart';

abstract class OperationRemoteDataSource {
  Future<List<OperationDto>> fetchAll();
}

class OperationRemoteDataSourceImpl implements OperationRemoteDataSource {
  final ApiClient apiClient;
  OperationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OperationDto>> fetchAll() async {
    final Response<dynamic> res = await apiClient.get(
      '/api/operations',
      options: Options(headers: {
        'accept': 'application/json',
      }),
    );
    final dynamic body = res.data;
    final List<dynamic> listJson = body is List
        ? body
        : body is Map && body['data'] is List
            ? (body['data'] as List<dynamic>)
            : <dynamic>[];
    return listJson
        .map((e) => OperationDto.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
