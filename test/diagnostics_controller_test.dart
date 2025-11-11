import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/diagnostics_controller.dart';
import 'package:smart_air_devices/shared/models/device_diagnostic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load seeds diagnostics when storage empty', () async {
    final controller = DiagnosticsController();
    await controller.load();

    final diagnostics = controller.diagnosticsNotifier.value;
    expect(diagnostics, isNotEmpty);
    expect(diagnostics.length, greaterThanOrEqualTo(4));
    expect(diagnostics.first.severityIndex >= diagnostics.last.severityIndex,
        isTrue);
  });

  test('runQuickCheckAll improves auto-tuned flagged devices', () async {
    final controller = DiagnosticsController();
    await controller.load();

    final flagged = controller.diagnosticsNotifier.value
        .where((d) => d.autoTuneEnabled && d.isFlagged)
        .map((d) => MapEntry(d.id, d.status.index))
        .toList();

    await controller.runQuickCheckAll();

    for (final entry in flagged) {
      final updated = controller.diagnosticsNotifier.value
          .firstWhere((d) => d.id == entry.key);
      expect(updated.status.index, lessThanOrEqualTo(entry.value));
    }
  });

  test('toggleAutoTune updates notifier and persisted payload', () async {
    final controller = DiagnosticsController();
    await controller.load();

    final target = controller.diagnosticsNotifier.value.first;
    await controller.toggleAutoTune(target.id, !target.autoTuneEnabled);

    final updated = controller.diagnosticsNotifier.value
        .firstWhere((d) => d.id == target.id);
    expect(updated.autoTuneEnabled, !target.autoTuneEnabled);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('deviceDiagnostics');
    expect(stored, isNotNull);
    final decoded = jsonDecode(stored!) as List<dynamic>;
    final payload = decoded.firstWhere(
      (dynamic item) => (item as Map<String, dynamic>)['id'] == target.id,
    ) as Map<String, dynamic>;
    expect(payload['autoTuneEnabled'], !target.autoTuneEnabled);
  });

  test('markResolved clears issues and sets optimal status', () async {
    final controller = DiagnosticsController();
    await controller.load();

    final flagged = controller.diagnosticsNotifier.value
        .firstWhere((d) => d.isFlagged);

    await controller.markResolved(flagged.id);

    final updated = controller.diagnosticsNotifier.value
        .firstWhere((d) => d.id == flagged.id);
    expect(updated.status, DiagnosticStatus.optimal);
    expect(updated.issueCount, 0);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('deviceDiagnostics');
    expect(stored, isNotNull);
    final decoded = jsonDecode(stored!) as List<dynamic>;
    final payload = decoded.firstWhere(
      (dynamic item) => (item as Map<String, dynamic>)['id'] == flagged.id,
    ) as Map<String, dynamic>;
    expect(payload['status'], 'optimal');
  });
}
