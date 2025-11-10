import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_air_devices/core/theme/app_theme.dart';
import 'package:smart_air_devices/core/theme/design_tokens.dart';

void main() {
  test('Bottom navigation theming aligns with design tokens', () {
    const primary = Color(0xFF0A0A0A);
    final theme = const AppTheme(primaryColor: primary).buildLightTheme();
    final navTheme = theme.bottomNavigationBarTheme;

    expect(navTheme.backgroundColor, DesignTokens.surfaceAlt);
    expect(navTheme.selectedItemColor, primary);
    expect(navTheme.unselectedItemColor,
        DesignTokens.textPrimary.withOpacity(0.55));
    expect(navTheme.showUnselectedLabels, isTrue);
    expect(navTheme.type, BottomNavigationBarType.fixed);
  });
}
