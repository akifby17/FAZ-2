import '../entities/tezgah.dart';

abstract class TezgahRepository {
  Future<List<Tezgah>> getTezgahlar({String? group});
  Future<void> startOperation({required List<String> tezgahIds});
  Future<void> endOperation({required List<String> tezgahIds});
}
