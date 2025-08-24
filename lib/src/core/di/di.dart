import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/api_client.dart';
import '../services/api_url_service.dart';
import '../../features/tezgah/data/datasources/tezgah_remote_data_source.dart';
import '../../features/tezgah/data/repositories/tezgah_repository_impl.dart';
import '../../features/tezgah/domain/repositories/tezgah_repository.dart';
import '../../features/personnel/data/datasources/personnel_remote_data_source.dart';
import '../../features/personnel/data/repositories/personnel_repository_impl.dart';
import '../auth/token_service.dart';
import '../../features/operation/data/datasources/operation_remote_data_source.dart';
import '../../features/operation/data/repositories/operation_repository_impl.dart';
import '../../features/tezgah/data/datasources/weaver_remote_data_source.dart';
import '../../features/tezgah/data/repositories/weaver_repository_impl.dart';
import '../../features/tezgah/domain/repositories/weaver_repository.dart';
import '../../features/tezgah/domain/usecases/change_weaver.dart';

// Settings imports
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/verify_admin_password.dart';
import '../../features/settings/domain/usecases/update_api_url.dart';

Future<void> configureDependencies(GetIt sl) async {
  // Local storage
  await Hive.initFlutter();
  final Box<dynamic> settingsBox = await Hive.openBox('settings');
  sl.registerLazySingleton<Box<dynamic>>(() => settingsBox);

  // Core services
  sl.registerLazySingleton<ApiUrlService>(() => ApiUrlService(box: sl()));

  // Core - Dio (dynamic base URL will be handled by ApiClient)
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        headers: {
          'Content-Type': 'application/json',
        },
      )));

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl()));
  sl.registerLazySingleton<TokenService>(() => TokenService(box: sl()));

  // Data sources
  sl.registerLazySingleton<TezgahRemoteDataSource>(
      () => TezgahRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<PersonnelRemoteDataSource>(
      () => PersonnelRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<OperationRemoteDataSource>(
      () => OperationRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<WeaverRemoteDataSource>(
    () => WeaverRemoteDataSource(),
  );

  // Repository
  sl.registerLazySingleton<TezgahRepository>(() => TezgahRepositoryImpl(
        remoteDataSource: sl(),
      ));
  sl.registerLazySingleton<PersonnelRepositoryImpl>(
      () => PersonnelRepositoryImpl(remote: sl()));
  sl.registerLazySingleton<OperationRepositoryImpl>(
      () => OperationRepositoryImpl(remote: sl()));
  sl.registerLazySingleton<WeaverRepository>(
    () => WeaverRepositoryImpl(sl<WeaverRemoteDataSource>()),
  );
  sl.registerLazySingleton<ChangeWeaver>(
    () => ChangeWeaver(sl<WeaverRepository>()),
  );

  // Settings feature
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
      apiUrlService: sl(),
    ),
  );
  sl.registerLazySingleton<GetSettings>(
    () => GetSettings(sl(), sl()),
  );
  sl.registerLazySingleton<VerifyAdminPassword>(
    () => VerifyAdminPassword(sl()),
  );
  sl.registerLazySingleton<UpdateApiUrl>(
    () => UpdateApiUrl(sl()),
  );
}
