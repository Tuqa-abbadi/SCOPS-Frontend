import 'package:dio/dio.dart';

import '../../services/token_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static DioClient? _instance;

  static DioClient get instance {
    assert(
      _instance != null,
      'DioClient has not been initialized.\n'
      'Call DioClient.init() before using DioClient.instance.',
    );
    return _instance!;
  }

  late final Dio _dio;

  Dio get dio => _dio;

  static void init({
    required String baseUrl,
    required TokenStorageService tokenStorage,
  }) {
    if (_instance != null) return;

    final client = DioClient._();

    final dio = Dio(_baseOptions(baseUrl));

    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => print(o),
        ),
      );
      return true;
    }());

    dio.interceptors.add(
      AuthInterceptor(tokenStorage: tokenStorage, dio: dio, baseUrl: baseUrl),
    );

    client._dio = dio;
    _instance = client;
  }

  static BaseOptions _baseOptions(String baseUrl) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
  }
}
