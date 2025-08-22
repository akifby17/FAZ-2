import '../repositories/weaver_repository.dart';

class ChangeWeaver {
  final WeaverRepository _repository;

  ChangeWeaver(this._repository);

  Future<void> call({
    required String loomNo,
    required int weaverId,
  }) async {
    await _repository.changeWeaver(
      loomNo: loomNo,
      weaverId: weaverId,
    );
  }
}
