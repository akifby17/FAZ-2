import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/core/di/di.dart';
import 'src/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies(GetIt.I);

  // 🚀 Uygulama başlatılıyor...
  print('🚀 FAZ-2 Tezgah Kontrol Uygulaması başlatılıyor (Auth disabled)...');

  // Persisted locale from Hive
  final Box<dynamic> settings = GetIt.I<Box<dynamic>>();
  final String? savedLocaleCode = settings.get('locale_code') as String?;
  final Locale startLocale =
      savedLocaleCode == null ? const Locale('tr') : Locale(savedLocaleCode);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      startLocale: startLocale,
      child: const FazApp(),
    ),
  );
}

class FazApp extends StatelessWidget {
  const FazApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildRouter();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TEZGAHLAR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF24456E)),
        useMaterial3: true,
      ),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: router,
    );
  }
}
