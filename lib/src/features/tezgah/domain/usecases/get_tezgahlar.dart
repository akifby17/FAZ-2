import '../entities/tezgah.dart';
import '../repositories/tezgah_repository.dart';

class GetTezgahlar {
  final TezgahRepository repository;
  GetTezgahlar(this.repository);

  Future<List<Tezgah>> call({String? group}) {
    return repository.getTezgahlar(group: group);
  }
}
