import '../../domain/entities/tezgah.dart';
import '../../domain/repositories/tezgah_repository.dart';
import '../datasources/tezgah_remote_data_source.dart';
import '../models/tezgah_dto.dart';

class TezgahRepositoryImpl implements TezgahRepository {
  final TezgahRemoteDataSource remoteDataSource;

  TezgahRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> endOperation({required List<String> tezgahIds}) async {
    await remoteDataSource.endOperation(tezgahIds: tezgahIds);
  }

  @override
  Future<List<Tezgah>> getTezgahlar({String? group}) async {
    final List<TezgahDto> list =
        await remoteDataSource.fetchTezgahlar(group: group);
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> startOperation({required List<String> tezgahIds}) async {
    await remoteDataSource.startOperation(tezgahIds: tezgahIds);
  }
}
