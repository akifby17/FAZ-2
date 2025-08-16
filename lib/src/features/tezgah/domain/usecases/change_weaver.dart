import '../repositories/weaver_repository.dart';

class ChangeWeaver {
  final WeaverRepository _repository;

  ChangeWeaver(this._repository);

  Future<void> call({
    required String token,
    required String loomNo,
    required int weaverId,
  }) async {
    await _repository.changeWeaver(
      token: token,
      loomNo: loomNo,
      weaverId: weaverId,
    );
  }
}
