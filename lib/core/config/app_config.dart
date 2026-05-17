class AppConfig {
  AppConfig._();

  static const String _defaultApiBaseUrl = 'https://scops-api.onrender.com/api';

  static const String _apiBaseUrlFromEnvironment = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );

  static String get apiBaseUrl =>
      _withTrailingSlash(_apiBaseUrlFromEnvironment.trim());

  static String _withTrailingSlash(String url) {
    if (url.endsWith('/')) return url;
    return '$url/';
  }
}
