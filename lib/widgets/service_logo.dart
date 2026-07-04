import 'package:flutter/material.dart';

class ServiceLogo extends StatelessWidget {
  const ServiceLogo({
    super.key,
    required this.serviceName,
    required this.logoUrl,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
    this.padding = EdgeInsets.zero,
    this.fallbackFontSize = 22,
  });

  final String serviceName;
  final String? logoUrl;
  final String fallbackIcon;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final double fallbackFontSize;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, error, __) {
          debugPrint('[ServiceLogo] Failed to load $url: $error');
          return _fallback();
        },
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;

          final expectedBytes = loadingProgress.expectedTotalBytes;
          final progress = expectedBytes == null
              ? null
              : loadingProgress.cumulativeBytesLoaded / expectedBytes;

          return Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Center(
      child: Text(
        fallbackIcon,
        style: TextStyle(fontSize: fallbackFontSize),
      ),
    );
  }
}
