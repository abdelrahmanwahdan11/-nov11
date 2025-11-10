import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/widgets/dot_pager_indicator.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/smart_network_image.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  Timer? _autoTimer;
  int _index = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      titleKey: 'onboardingTitle1',
      subtitleKey: 'onboardingSubtitle1',
      imageSeed: 'airhero',
    ),
    _OnboardingItem(
      titleKey: 'onboardingTitle2',
      subtitleKey: 'onboardingSubtitle2',
      imageSeed: 'comfort-drift',
    ),
    _OnboardingItem(
      titleKey: 'onboardingTitle3',
      subtitleKey: 'onboardingSubtitle3',
      imageSeed: 'editorial-shopping',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextIndex = (_index + 1) % _items.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _cancelAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  @override
  void dispose() {
    _cancelAutoPlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.horizontal) {
                if (notification.direction == ScrollDirection.idle) {
                  if (_autoTimer == null) {
                    _startAutoPlay();
                  }
                } else {
                  _cancelAutoPlay();
                }
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (value) => setState(() => _index = value),
              itemCount: _items.length,
              itemBuilder: (context, index) => _OnboardingSlide(item: _items[index]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                    child: Text(l10n.getString('previous')),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _skip,
                        child: Text(l10n.getString('skip')),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => _goNext(manual: true),
                        child: Text(l10n.getString('next')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: 24,
            right: 24,
            child: DotPagerIndicator(length: _items.length, index: _index),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: PrimaryButton(
                  label: l10n.getString('getStarted'),
                  onPressed: _completeOnboarding,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goTo(int index) {
    _cancelAutoPlay();
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goNext({bool manual = false}) {
    if (_index >= _items.length - 1) {
      _completeOnboarding();
      return;
    }
    _goTo(_index + 1);
    if (manual) {
      _startAutoPlay();
    }
  }

  void _skip() {
    _cancelAutoPlay();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final scope = AppScope.of(context);
    await scope.appController.markOnboardingSeen();
    final prefs = scope.appController.prefsNotifier.value;
    final hasSession = prefs.isLoggedIn || prefs.isGuest;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(hasSession ? '/home' : '/auth');
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: SmartNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.getString(item.titleKey),
                        style: context.textTheme.displayLarge?.copyWith(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.getString(item.subtitleKey),
                        style: context.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.titleKey,
    required this.subtitleKey,
    required this.imageSeed,
  });

  final String titleKey;
  final String subtitleKey;
  final String imageSeed;

  String get imageUrl => 'https://picsum.photos/seed/$imageSeed/1080/1920';
}
