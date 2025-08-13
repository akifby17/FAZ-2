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
    // NOTE: Token yönetimi daha sonra güvenli saklanacak; şimdilik DI dışından alınacak
    // Bu metodu kullanırken token parametresini DI veya başka servisle taşırız.
    throw UnimplementedError('Token must be provided via a use case');
  }

  Future<List<Personnel>> fetchAllWithToken(String token) async {
    final List<PersonnelDto> dtos = await remote.fetchAll(token: token);
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
