import 'package:flutter/material.dart';

class SmartNetworkImage extends StatelessWidget {
  const SmartNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.aspectRatio,
    this.alignment = Alignment.center,
    this.placeholder,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? aspectRatio;
  final Alignment alignment;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    Widget content = _FadeInNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
    );

    if (aspectRatio != null) {
      content = AspectRatio(
        aspectRatio: aspectRatio!,
        child: content,
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }
}

class _FadeInNetworkImage extends StatelessWidget {
  const _FadeInNetworkImage({
    required this.imageUrl,
    required this.fit,
    required this.alignment,
    this.placeholder,
  });

  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final Widget resolvedPlaceholder = placeholder ?? const _ImagePlaceholder();
    return Image.network(
      imageUrl,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            resolvedPlaceholder,
            Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return resolvedPlaceholder;
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceVariant.withOpacity(0.32),
            theme.colorScheme.surfaceVariant.withOpacity(0.12),
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
