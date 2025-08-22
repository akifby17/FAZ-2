import '../../domain/entities/personnel.dart';
import '../../domain/repositories/personnel_repository.dart';
import '../datasources/personnel_remote_data_source.dart';
import '../models/personnel_dto.dart';

class PersonnelRepositoryImpl implements PersonnelRepository {
  final PersonnelRemoteDataSource remote;
  List<Personnel>? _cache;

  PersonnelRepositoryImpl({required this.remote});

  @override
  Future<List<Personnel>> fetchAll() async {
    if (_cache != null) return _cache!;
    final List<PersonnelDto> dtos = await remote.fetchAll();
    _cache = dtos.map((e) => e.toDomain()).toList();
    return _cache!;
  }

  @override
  Personnel? findById(int id) {
    final list = _cache;
    if (list == null) return null;
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
