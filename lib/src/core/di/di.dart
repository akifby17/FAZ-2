import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/api_client.dart';
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

Future<void> configureDependencies(GetIt sl) async {
  // Local storage
  await Hive.initFlutter();
  final Box<dynamic> settingsBox = await Hive.openBox('settings');
  sl.registerLazySingleton<Box<dynamic>>(() => settingsBox);

  // Core - Dio
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: ApiClient.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      )));

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
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
}
