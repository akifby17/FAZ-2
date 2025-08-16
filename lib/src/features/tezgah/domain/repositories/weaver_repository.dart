abstract class WeaverRepository {
  Future<void> changeWeaver({
    required String token,
    required String loomNo,
    required int weaverId,
  });
}
