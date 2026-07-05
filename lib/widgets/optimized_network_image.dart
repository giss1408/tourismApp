import 'package:flutter/material.dart';

class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final IconData fallbackIcon;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
    this.fallbackIcon = Icons.photo,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final mediaSize = MediaQuery.of(context).size;
    final targetWidth = _resolveDimension(width, fallback: mediaSize.width);
    final targetHeight = _resolveDimension(height, fallback: mediaSize.height);

    final cacheWidth = _computeCacheDimension(targetWidth, devicePixelRatio);
    final cacheHeight = _computeCacheDimension(targetHeight, devicePixelRatio);

    final placeholder = Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, size: 28, color: Colors.grey.shade500),
    );

    Widget image = Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.low,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: child,
          );
        }
        return AnimatedOpacity(
          opacity: 0,
          duration: const Duration(milliseconds: 120),
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder;
      },
      errorBuilder: (context, error, stackTrace) => placeholder,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  double? _resolveDimension(double? value, {required double fallback}) {
    if (value != null && value.isFinite && value > 0) {
      return value;
    }
    if (fallback.isFinite && fallback > 0) {
      return fallback;
    }
    return null;
  }

  int? _computeCacheDimension(double? dimension, double pixelRatio) {
    if (dimension == null || !dimension.isFinite || dimension <= 0) {
      return null;
    }
    if (!pixelRatio.isFinite || pixelRatio <= 0) {
      return null;
    }

    final scaled = dimension * pixelRatio;
    if (!scaled.isFinite || scaled.isNaN || scaled <= 0) {
      return null;
    }

    return scaled.round();
  }
}
