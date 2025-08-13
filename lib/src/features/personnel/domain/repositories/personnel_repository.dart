import '../entities/personnel.dart';

abstract class PersonnelRepository {
  Future<List<Personnel>> fetchAll();
  Personnel? findById(int id);
}
