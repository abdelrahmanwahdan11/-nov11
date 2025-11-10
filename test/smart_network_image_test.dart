import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_air_devices/shared/widgets/smart_network_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SmartNetworkImage surfaces placeholder while loading',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SmartNetworkImage(
          imageUrl: 'https://example.invalid/image.jpg',
          placeholder: Text('placeholder'),
        ),
      ),
    );

    expect(find.text('placeholder'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('placeholder'), findsOneWidget);
  });
}
