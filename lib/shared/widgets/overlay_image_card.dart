import 'package:flutter/material.dart';

import 'smart_network_image.dart';

class OverlayImageCard extends StatelessWidget {
  const OverlayImageCard({super.key, required this.image, required this.summary, required this.details, required this.onClose, required this.flipped, required this.onFlip});

  final String image;
  final Widget summary;
  final Widget details;
  final VoidCallback onClose;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return _OverlayContent(
      image: image,
      summary: summary,
      details: details,
      onClose: onClose,
      flipped: flipped,
      onFlip: onFlip,
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({required this.image, required this.summary, required this.details, required this.onClose, required this.flipped, required this.onFlip});

  final String image;
  final Widget summary;
  final Widget details;
  final VoidCallback onClose;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final rotate = Tween(begin: flipped ? 3.14 : 0.0, end: flipped ? 0.0 : 3.14)
                .animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.rotationY(rotate.value),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: child,
            );
          },
          child: flipped
              ? Container(
                  key: const ValueKey('details'),
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: details,
                )
              : ClipRRect(
                  key: const ValueKey('image'),
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: SmartNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 24,
                        bottom: 24,
                        right: 24,
                        child: summary,
                      ),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'flip',
            onPressed: onFlip,
            child: const Icon(Icons.flip),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'close',
            onPressed: onClose,
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
