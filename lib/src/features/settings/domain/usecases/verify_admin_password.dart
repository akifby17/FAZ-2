import '../repositories/settings_repository.dart';

class VerifyAdminPassword {
  final SettingsRepository _repository;

  VerifyAdminPassword(this._repository);

  Future<bool> call(String password) async {
    return await _repository.verifyAdminPassword(password);
  }
}
