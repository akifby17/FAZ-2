import '../../domain/entities/operation.dart';
import '../datasources/operation_remote_data_source.dart';
import '../models/operation_dto.dart';

class OperationRepositoryImpl {
  final OperationRemoteDataSource remote;
  List<Operation>? _cache;

  OperationRepositoryImpl({required this.remote});

  Future<List<Operation>> fetchAll() async {
    if (_cache != null) return _cache!;
    final List<OperationDto> dtos = await remote.fetchAll();
    _cache = dtos.map((e) => e.toDomain()).toList();
    return _cache!;
  }
}
