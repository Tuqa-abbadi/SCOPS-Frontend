import '../config/app_config.dart';

String? resolveMediaUrl(dynamic raw) {
  if (raw == null) return null;

  final value = raw.toString().trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme) {
    if (uri.scheme == 'http' && uri.host == 'scops-api.onrender.com') {
      return uri.replace(scheme: 'https').toString();
    }
    return uri.toString();
  }
  if (value.startsWith('//')) return 'https:$value';

  final apiBase = Uri.parse(AppConfig.apiBaseUrl);
  final origin = '${apiBase.scheme}://${apiBase.authority}';
  final path = value.startsWith('/') ? value : '/$value';

  return '$origin$path';
}

String? resolveLogoUrlFromJson(Map<String, dynamic> json) {
  final direct = json['logo_url'] ??
      json['logoUrl'] ??
      json['logo'] ??
      json['image_url'] ??
      json['imageUrl'] ??
      json['image'] ??
      json['icon_url'] ??
      json['iconUrl'];

  final directUrl = resolveMediaUrl(direct);
  if (directUrl != null) return directUrl;

  for (final key in const ['media', 'logo_file', 'logoFile', 'file']) {
    final value = json[key];
    if (value is Map) {
      final nested = value.map((k, v) => MapEntry(k.toString(), v));
      final nestedUrl = resolveMediaUrl(
        nested['url'] ??
            nested['path'] ??
            nested['full_url'] ??
            nested['fullUrl'] ??
            nested['original_url'] ??
            nested['originalUrl'],
      );
      if (nestedUrl != null) return nestedUrl;
    }
  }

  return null;
}
