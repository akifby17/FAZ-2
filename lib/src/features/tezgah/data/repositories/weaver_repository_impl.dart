import '../datasources/weaver_remote_data_source.dart';
import '../../domain/repositories/weaver_repository.dart';

class WeaverRepositoryImpl implements WeaverRepository {
  final WeaverRemoteDataSource _remoteDataSource;

  WeaverRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> changeWeaver({
    required String loomNo,
    required int weaverId,
  }) async {
    await _remoteDataSource.changeWeaver(
      loomNo: loomNo,
      weaverId: weaverId,
    );
  }
}
