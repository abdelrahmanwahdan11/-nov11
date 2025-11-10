import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_air_devices/core/l10n/app_localizations.dart';
import 'package:smart_air_devices/features/onboarding/onboarding_page.dart';
import 'package:smart_air_devices/shared/widgets/primary_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('Onboarding CTA respects bottom safe padding', (tester) async {
    await tester.pumpWidget(buildApp(const OnboardingPage()));
    await tester.pump(const Duration(milliseconds: 200));

    final buttonFinder = find.byType(PrimaryButton);
    expect(buttonFinder, findsOneWidget);

    final rect = tester.getRect(buttonFinder);
    final screenHeight = tester.binding.window.physicalSize.height /
        tester.binding.window.devicePixelRatio;

    expect(screenHeight - rect.bottom, greaterThanOrEqualTo(24));
  });
}
