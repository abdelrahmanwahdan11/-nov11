import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';
import '../models/environment_scene.dart';
import 'smart_network_image.dart';

class SceneCard extends StatelessWidget {
  const SceneCard({
    super.key,
    required this.scene,
    required this.selected,
    required this.onApply,
    required this.onInfo,
  });

  final EnvironmentScene scene;
  final bool selected;
  final VoidCallback onApply;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected ? theme.colorScheme.primary : Colors.transparent;
    return GestureDetector(
      onTap: onApply,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: (selected
                      ? theme.colorScheme.primary.withOpacity(0.35)
                      : Colors.black.withOpacity(0.12)),
              blurRadius: selected ? 28 : 18,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SmartNetworkImage(
                imageUrl: scene.imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      scene.gradientStart.withOpacity(0.9),
                      scene.gradientEnd.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.getString(
                              selected ? 'sceneActive' : 'sceneTapHint',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onInfo,
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.getString(scene.titleKey),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.getString(scene.subtitleKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
