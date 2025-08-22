import '../entities/personnel.dart';
import '../../data/repositories/personnel_repository_impl.dart';

class LoadPersonnels {
  final PersonnelRepositoryImpl repository;
  LoadPersonnels(this.repository);

  Future<List<Personnel>> call() {
    return repository.fetchAll();
  }
}
