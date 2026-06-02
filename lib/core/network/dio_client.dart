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
      // Logs the final encoded body and content-type actually sent over the wire.
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[DIO-DEBUG] uri=${options.uri}');
          print('[DIO-DEBUG] content-type=${options.contentType}');
          print('[DIO-DEBUG] headers=${options.headers}');
          print('[DIO-DEBUG] data=${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('[DIO-DEBUG] response=${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (err, handler) {
          print('[DIO-DEBUG] error=${err.response?.statusCode} ${err.response?.data}');
          handler.next(err);
        },
      ));
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
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
  }
}
