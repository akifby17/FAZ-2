import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/personnel_dto.dart';

abstract class PersonnelRemoteDataSource {
  Future<List<PersonnelDto>> fetchAll();
}

class PersonnelRemoteDataSourceImpl implements PersonnelRemoteDataSource {
  final ApiClient apiClient;
  PersonnelRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PersonnelDto>> fetchAll() async {
    final Response<dynamic> res = await apiClient.get(
      '/api/personnels',
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
        .map((e) => PersonnelDto.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
