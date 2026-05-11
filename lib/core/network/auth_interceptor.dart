import 'package:dio/dio.dart';
import '../../services/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
    required this.baseUrl,
  });

  final TokenStorageService tokenStorage;
  final Dio dio;
  final String baseUrl;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    if (response?.statusCode != 401 || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await tokenStorage.clearAll();
        handler.next(err);
        return;
      }

      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

      final refreshResponse = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = refreshResponse.data['access_token'] as String?;
      final newRefreshToken = refreshResponse.data['refresh_token'] as String?;

      if (newAccessToken == null) {
        await tokenStorage.clearAll();
        handler.next(err);
        return;
      }

      await tokenStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await tokenStorage.saveRefreshToken(newRefreshToken);
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clearAll();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}