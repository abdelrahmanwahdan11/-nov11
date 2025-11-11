import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/device_diagnostic.dart';

class DiagnosticsController {
  DiagnosticsController() {
    diagnosticsNotifier = ValueNotifier<List<DeviceDiagnostic>>([]);
    flaggedOnlyNotifier = ValueNotifier<bool>(false);
  }

  late final ValueNotifier<List<DeviceDiagnostic>> diagnosticsNotifier;
  late final ValueNotifier<bool> flaggedOnlyNotifier;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    final stored = prefs.getString('deviceDiagnostics');
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as List<dynamic>;
      diagnosticsNotifier.value = decoded
          .map(
            (dynamic raw) =>
                DeviceDiagnostic.fromJson(raw as Map<String, dynamic>),
          )
          .toList()
        ..sort(_compareDiagnostics);
    } else {
      diagnosticsNotifier.value = _seedDiagnostics();
      await _persistDiagnostics();
    }

    final flaggedOnly = prefs.getBool('diagnosticsFlaggedOnly') ?? false;
    flaggedOnlyNotifier.value = flaggedOnly;
  }

  Future<void> toggleFlaggedOnly(bool value) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('diagnosticsFlaggedOnly', value);
    flaggedOnlyNotifier.value = value;
  }

  Future<void> runQuickCheck(String id) async {
    final now = DateTime.now();
    final updated = diagnosticsNotifier.value.map((diagnostic) {
      if (diagnostic.id == id) {
        final nextStatus = diagnostic.autoTuneEnabled
            ? _improvedStatus(diagnostic.status)
            : diagnostic.status;
        final nextIssueCount =
            nextStatus == DiagnosticStatus.optimal ? 0 : diagnostic.issueCount;
        return diagnostic.copyWith(
          status: nextStatus,
          lastChecked: now,
          issueCount: nextIssueCount,
        );
      }
      return diagnostic;
    }).toList()
      ..sort(_compareDiagnostics);
    diagnosticsNotifier.value = updated;
    await _persistDiagnostics();
  }

  Future<void> runQuickCheckAll() async {
    final now = DateTime.now();
    final updated = diagnosticsNotifier.value.map((diagnostic) {
      final nextStatus = diagnostic.autoTuneEnabled
          ? _improvedStatus(diagnostic.status)
          : diagnostic.status;
      final nextIssueCount =
          nextStatus == DiagnosticStatus.optimal ? 0 : diagnostic.issueCount;
      return diagnostic.copyWith(
        status: nextStatus,
        lastChecked: now,
        issueCount: nextIssueCount,
      );
    }).toList()
      ..sort(_compareDiagnostics);
    diagnosticsNotifier.value = updated;
    await _persistDiagnostics();
  }

  Future<void> markResolved(String id) async {
    final now = DateTime.now();
    final updated = diagnosticsNotifier.value.map((diagnostic) {
      if (diagnostic.id == id) {
        return diagnostic.copyWith(
          status: DiagnosticStatus.optimal,
          lastChecked: now,
          issueCount: 0,
        );
      }
      return diagnostic;
    }).toList()
      ..sort(_compareDiagnostics);
    diagnosticsNotifier.value = updated;
    await _persistDiagnostics();
  }

  Future<void> toggleAutoTune(String id, bool enabled) async {
    final updated = diagnosticsNotifier.value.map((diagnostic) {
      if (diagnostic.id == id) {
        return diagnostic.copyWith(autoTuneEnabled: enabled);
      }
      return diagnostic;
    }).toList()
      ..sort(_compareDiagnostics);
    diagnosticsNotifier.value = updated;
    await _persistDiagnostics();
  }

  List<DeviceDiagnostic> get flaggedDiagnostics {
    return diagnosticsNotifier.value
        .where((diagnostic) => diagnostic.isFlagged)
        .toList()
      ..sort(_compareDiagnostics);
  }

  List<DeviceDiagnostic> _seedDiagnostics() {
    final now = DateTime.now();
    final items = <DeviceDiagnostic>[
      DeviceDiagnostic(
        id: 'haloPrime',
        deviceName: 'Halo Prime Fan',
        status: DiagnosticStatus.attention,
        lastChecked: now.subtract(const Duration(hours: 6)),
        advisoryKeys: const <String>[
          'diagnosticAdvisoryFilter',
          'diagnosticAdvisoryAlignment',
        ],
        autoTuneEnabled: true,
        issueCount: 1,
      ),
      DeviceDiagnostic(
        id: 'auroraHeat',
        deviceName: 'Aurora Heat+ Purifier',
        status: DiagnosticStatus.critical,
        lastChecked: now.subtract(const Duration(hours: 12)),
        advisoryKeys: const <String>[
          'diagnosticAdvisorySensors',
          'diagnosticAdvisoryFirmware',
        ],
        autoTuneEnabled: false,
        issueCount: 2,
      ),
      DeviceDiagnostic(
        id: 'zenPure',
        deviceName: 'ZenPure Mini',
        status: DiagnosticStatus.optimal,
        lastChecked: now.subtract(const Duration(hours: 2)),
        advisoryKeys: const <String>[],
        autoTuneEnabled: true,
        issueCount: 0,
      ),
      DeviceDiagnostic(
        id: 'circaFlow',
        deviceName: 'CircaFlow Tower',
        status: DiagnosticStatus.attention,
        lastChecked: now.subtract(const Duration(days: 1, hours: 4)),
        advisoryKeys: const <String>[
          'diagnosticAdvisoryFilter',
        ],
        autoTuneEnabled: true,
        issueCount: 1,
      ),
    ]
      ..sort(_compareDiagnostics);
    return items;
  }

  DiagnosticStatus _improvedStatus(DiagnosticStatus status) {
    switch (status) {
      case DiagnosticStatus.critical:
        return DiagnosticStatus.attention;
      case DiagnosticStatus.attention:
        return DiagnosticStatus.optimal;
      case DiagnosticStatus.optimal:
        return DiagnosticStatus.optimal;
    }
  }

  Future<void> _persistDiagnostics() async {
    final prefs = await _ensurePrefs();
    final encoded = jsonEncode(
      diagnosticsNotifier.value.map((diagnostic) => diagnostic.toJson()).toList(),
    );
    await prefs.setString('deviceDiagnostics', encoded);
  }

  int _compareDiagnostics(
    DeviceDiagnostic a,
    DeviceDiagnostic b,
  ) {
    final severityCompare = b.severityIndex.compareTo(a.severityIndex);
    if (severityCompare != 0) {
      return severityCompare;
    }
    return a.deviceName.toLowerCase().compareTo(b.deviceName.toLowerCase());
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
