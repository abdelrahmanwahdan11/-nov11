import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';
import '../../shared/widgets/dot_pager_indicator.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  late Timer _timer;
  int _index = 0;

  final _items = const [
    (
      title: 'Clean Air, Calm Mind',
      subtitle: 'Crafted experiences for fans, purifiers and heaters.',
      image: 'https://images.unsplash.com/photo-1585386959984-a4155223167f',
    ),
    (
      title: 'Adaptive Comfort',
      subtitle: 'Switch between breeze, warmth and purification instantly.',
      image: 'https://images.unsplash.com/photo-1616628188505-4049d16e29d5',
    ),
    (
      title: 'Editorial Shopping',
      subtitle: 'Compare specs, favorite trends and preview in 360°.',
      image: 'https://images.unsplash.com/photo-1598300053650-7b7b2a1dc07b',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      _index = (_index + 1) % _items.length;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(item.image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          item.title,
                          style: context.textTheme.displayLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.subtitle,
                          style: context.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: DotPagerIndicator(length: _items.length, index: _index),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: PrimaryButton(
              label: context.l10n.getString('getStarted'),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/auth');
              },
            ),
          ),
          Positioned(
            top: 48,
            right: 24,
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
              child: Text(context.l10n.getString('skip'), style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
