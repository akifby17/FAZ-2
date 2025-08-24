import 'package:dio/dio.dart';
import '../services/api_url_service.dart';

class ApiClient {
  static const String baseUrl = 'http://95.70.139.125:5100'; // Fallback

  final Dio _dio;
  final ApiUrlService _apiUrlService;

  ApiClient(this._dio, this._apiUrlService) {
    // Hata ayıklama için interceptor ekle
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
    ));

    // Dynamic base URL interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final currentBaseUrl = _apiUrlService.getCurrentUrl();
        // Set the dynamic base URL
        options.baseUrl = currentBaseUrl;
        print('🌐 API Request: ${options.baseUrl}${options.path}');
        handler.next(options);
      },
    ));
  }

  /// Get current API base URL
  String getCurrentBaseUrl() => _apiUrlService.getCurrentUrl();

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// API endpoint'lerinin durumunu kontrol etmek için yardımcı method
  Future<void> checkEndpointHealth(String endpoint) async {
    try {
      final currentUrl = getCurrentBaseUrl();
      print('🔍 Endpoint kontrolü yapılıyor: $currentUrl$endpoint');
      final response = await _dio.get(endpoint);
      print('✅ Endpoint çalışıyor: $endpoint (Status: ${response.statusCode})');
    } on DioException catch (e) {
      print('❌ Endpoint hatası: $endpoint');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Error Message: ${e.message}');
      print('   Response Data: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        print('   🚨 Bu endpoint mevcut değil veya yanlış URL!');
      }
    } catch (e) {
      print('❌ Beklenmeyen hata: $endpoint - $e');
    }
  }

  /// Tüm kullanılan endpoint'leri test et
  Future<void> testAllEndpoints() async {
    final currentUrl = getCurrentBaseUrl();
    print('\n🧪 === API Endpoint Health Check Başlatılıyor ===');
    print('🌐 Base URL: $currentUrl');

    final endpoints = [
      '/api/looms/monitoring', // ✅ Çalışıyor
      '/api/personnels', // ❌ 404
      '/api/operations', // ❌ 404
      '/api/DataMan/changeWeaver', // ❌ 404 (POST)
      '/api/warps/next/T001', // ❌ 404
      '/api/warps/current/T001', // ❌ 404
      '/api/style-work-orders/next/T001', // ❌ 404
    ];

    for (final endpoint in endpoints) {
      await checkEndpointHealth(endpoint);
      await Future.delayed(const Duration(milliseconds: 500)); // Rate limiting
    }

    print('🧪 === API Health Check Tamamlandı ===\n');
  }
}
