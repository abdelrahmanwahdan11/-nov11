import 'package:flutter/foundation.dart';

enum DiagnosticStatus {
  optimal,
  attention,
  critical,
}

class DeviceDiagnostic {
  DeviceDiagnostic({
    required this.id,
    required this.deviceName,
    required this.status,
    required this.lastChecked,
    required List<String> advisoryKeys,
    required this.autoTuneEnabled,
    required this.issueCount,
  }) : advisoryKeys = List.unmodifiable(advisoryKeys);

  final String id;
  final String deviceName;
  final DiagnosticStatus status;
  final DateTime lastChecked;
  final List<String> advisoryKeys;
  final bool autoTuneEnabled;
  final int issueCount;

  bool get isFlagged => status != DiagnosticStatus.optimal;

  String get statusLocalizationKey {
    switch (status) {
      case DiagnosticStatus.optimal:
        return 'diagnosticStatusOptimal';
      case DiagnosticStatus.attention:
        return 'diagnosticStatusAttention';
      case DiagnosticStatus.critical:
        return 'diagnosticStatusCritical';
    }
  }

  int get severityIndex {
    switch (status) {
      case DiagnosticStatus.critical:
        return 2;
      case DiagnosticStatus.attention:
        return 1;
      case DiagnosticStatus.optimal:
        return 0;
    }
  }

  DeviceDiagnostic copyWith({
    String? id,
    String? deviceName,
    DiagnosticStatus? status,
    DateTime? lastChecked,
    List<String>? advisoryKeys,
    bool? autoTuneEnabled,
    int? issueCount,
  }) {
    return DeviceDiagnostic(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      status: status ?? this.status,
      lastChecked: lastChecked ?? this.lastChecked,
      advisoryKeys: advisoryKeys ?? this.advisoryKeys,
      autoTuneEnabled: autoTuneEnabled ?? this.autoTuneEnabled,
      issueCount: issueCount ?? this.issueCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deviceName': deviceName,
      'status': describeEnum(status),
      'lastChecked': lastChecked.toIso8601String(),
      'advisoryKeys': advisoryKeys,
      'autoTuneEnabled': autoTuneEnabled,
      'issueCount': issueCount,
    };
  }

  factory DeviceDiagnostic.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'optimal';
    return DeviceDiagnostic(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String,
      status: _statusFromString(rawStatus),
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      advisoryKeys: (json['advisoryKeys'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      autoTuneEnabled: json['autoTuneEnabled'] as bool? ?? true,
      issueCount: json['issueCount'] as int? ?? 0,
    );
  }

  static DiagnosticStatus _statusFromString(String value) {
    switch (value) {
      case 'critical':
        return DiagnosticStatus.critical;
      case 'attention':
        return DiagnosticStatus.attention;
      case 'optimal':
      default:
        return DiagnosticStatus.optimal;
    }
  }
}
