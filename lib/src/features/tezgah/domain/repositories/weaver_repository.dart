abstract class WeaverRepository {
  Future<void> changeWeaver({
    required String loomNo,
    required int weaverId,
  });
}
