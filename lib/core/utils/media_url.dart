import '../config/app_config.dart';

const String _cloudinaryServiceLogoBaseUrl =
    'https://res.cloudinary.com/o2aqdium/image/upload';

const Map<String, String> _serviceLogoUrls = {
  'netflix':
      'https://res.cloudinary.com/o2aqdium/image/upload/netflix-svgrepo-com.png',
  'disney+':
      'https://res.cloudinary.com/o2aqdium/image/upload/disney-plus-svgrepo-com(1).png',
  'disney plus':
      'https://res.cloudinary.com/o2aqdium/image/upload/disney-plus-svgrepo-com(1).png',
  'spotify':
      'https://res.cloudinary.com/o2aqdium/image/upload/spotify-color-svgrepo-com.png',
  'xbox game pass':
      'https://res.cloudinary.com/o2aqdium/image/upload/xbox-svgrepo-com.png',
};

String? cloudinaryServiceLogoUrl(dynamic rawName) {
  if (rawName == null) return null;

  final name = rawName.toString().trim();
  if (name.isEmpty) return null;

  final normalizedName = name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final mappedUrl = _serviceLogoUrls[normalizedName];
  if (mappedUrl != null) return mappedUrl;

  return '$_cloudinaryServiceLogoBaseUrl/${Uri.encodeComponent(name)}.png';
}

String? resolveMediaUrl(dynamic raw) {
  if (raw == null) return null;

  final value = raw.toString().trim();
  if (value.isEmpty) return null;

  final apiBase = Uri.parse(AppConfig.apiBaseUrl);
  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme) {
    if (uri.scheme == 'http' &&
        apiBase.scheme == 'https' &&
        uri.host == apiBase.host) {
      return uri.replace(scheme: 'https').toString();
    }
    return uri.toString();
  }
  if (value.startsWith('//')) return 'https:$value';

  final origin = '${apiBase.scheme}://${apiBase.authority}';
  final path = value.startsWith('/') ? value : '/$value';

  return '$origin$path';
}

String? resolveLogoUrlFromJson(Map<String, dynamic> json) {
  final generatedUrl = cloudinaryServiceLogoUrl(
    json['name'] ?? json['service_name'] ?? json['serviceName'],
  );
  if (generatedUrl != null) return generatedUrl;

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
