import 'package:flutter/material.dart';

class OverlayCardController {
  OverlayCardController()
      : isVisible = ValueNotifier<bool>(false),
        isFlipped = ValueNotifier<bool>(false);

  final ValueNotifier<bool> isVisible;
  final ValueNotifier<bool> isFlipped;

  void show() {
    isVisible.value = true;
    isFlipped.value = false;
  }

  void hide() {
    isVisible.value = false;
  }

  void flip() {
    isFlipped.value = !isFlipped.value;
  }
}
