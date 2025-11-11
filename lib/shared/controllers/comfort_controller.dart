import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comfort_snapshot.dart';
import '../models/comfort_tip.dart';

enum ComfortTrend { improving, steady, declining }

class ComfortController {
  ComfortController() {
    snapshotsNotifier = ValueNotifier<List<ComfortSnapshot>>([]);
    focusNotifier = ValueNotifier<String>(_defaultFocus);
    autoBalanceNotifier = ValueNotifier<bool>(true);
    remindersEnabledNotifier = ValueNotifier<bool>(true);
    pinnedTipsNotifier = ValueNotifier<Set<String>>(<String>{});
  }

  static const _defaultFocus = 'sleep';

  static const focuses = <String>['sleep', 'productivity', 'allergy'];

  late final ValueNotifier<List<ComfortSnapshot>> snapshotsNotifier;
  late final ValueNotifier<String> focusNotifier;
  late final ValueNotifier<bool> autoBalanceNotifier;
  late final ValueNotifier<bool> remindersEnabledNotifier;
  late final ValueNotifier<Set<String>> pinnedTipsNotifier;

  SharedPreferences? _prefs;

  late final List<ComfortTip> _tips = _seedTips();
  late final Map<String, ComfortTip> _tipsById = {
    for (final tip in _tips) tip.id: tip,
  };

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    final storedSnapshots = prefs.getString('comfortSnapshots');
    if (storedSnapshots != null && storedSnapshots.isNotEmpty) {
      final raw = jsonDecode(storedSnapshots) as List<dynamic>;
      final decoded = raw
          .map((entry) =>
              ComfortSnapshot.fromJson(entry as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      snapshotsNotifier.value = decoded;
    } else {
      snapshotsNotifier.value = _seedSnapshots();
      await _persistSnapshots();
    }

    focusNotifier.value =
        prefs.getString('comfortFocus') ?? focusNotifier.value;
    autoBalanceNotifier.value =
        prefs.getBool('comfortAutoBalance') ?? autoBalanceNotifier.value;
    remindersEnabledNotifier.value = prefs.getBool('comfortReminders') ??
        remindersEnabledNotifier.value;

    final storedPinned = prefs.getStringList('comfortPinnedTips');
    if (storedPinned != null) {
      pinnedTipsNotifier.value = storedPinned.toSet();
    }
  }

  List<ComfortTip> get tips => List.unmodifiable(_tips);

  List<ComfortTip> tipsForFocus(String focus) {
    return _tips.where((tip) => tip.focus == focus).toList();
  }

  List<ComfortTip> pinnedTips() {
    final ids = pinnedTipsNotifier.value;
    return ids.map((id) => _tipsById[id]).whereType<ComfortTip>().toList();
  }

  Future<void> setFocus(String focus) async {
    if (!focuses.contains(focus)) {
      return;
    }
    focusNotifier.value = focus;
    final prefs = await _ensurePrefs();
    await prefs.setString('comfortFocus', focus);
  }

  Future<void> toggleAutoBalance(bool enabled) async {
    autoBalanceNotifier.value = enabled;
    final prefs = await _ensurePrefs();
    await prefs.setBool('comfortAutoBalance', enabled);
  }

  Future<void> toggleReminders(bool enabled) async {
    remindersEnabledNotifier.value = enabled;
    final prefs = await _ensurePrefs();
    await prefs.setBool('comfortReminders', enabled);
  }

  Future<void> toggleTipPinned(String id) async {
    final current = Set<String>.from(pinnedTipsNotifier.value);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    pinnedTipsNotifier.value = current;
    final prefs = await _ensurePrefs();
    await prefs.setStringList('comfortPinnedTips', current.toList());
  }

  Future<void> logSession(ComfortSnapshot snapshot) async {
    final updated = [...snapshotsNotifier.value, snapshot]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    snapshotsNotifier.value = updated;
    await _persistSnapshots();
  }

  int averageScoreForFocus(String focus) {
    final items = timelineForFocus(focus);
    if (items.isEmpty) {
      return 0;
    }
    final total = items.fold<int>(0, (acc, item) => acc + item.score);
    return (total / items.length).round();
  }

  ComfortSnapshot? latestForFocus(String focus) {
    final timeline = timelineForFocus(focus);
    return timeline.isNotEmpty ? timeline.last : null;
  }

  DateTime? lastUpdated() {
    final items = snapshotsNotifier.value;
    return items.isNotEmpty ? items.last.timestamp : null;
  }

  List<ComfortSnapshot> timelineForFocus(String focus) {
    final items = snapshotsNotifier.value
        .where((snapshot) => snapshot.focus == focus)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return items;
  }

  ComfortTrend trendForFocus(String focus) {
    final timeline = timelineForFocus(focus);
    if (timeline.length < 2) {
      return ComfortTrend.steady;
    }
    final latest = timeline[timeline.length - 1].score;
    final previous = timeline[timeline.length - 2].score;
    if (latest - previous >= 3) {
      return ComfortTrend.improving;
    }
    if (previous - latest >= 3) {
      return ComfortTrend.declining;
    }
    return ComfortTrend.steady;
  }

  List<ComfortSnapshot> latestSessions({int count = 5}) {
    final items = [...snapshotsNotifier.value]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (items.length <= count) {
      return items;
    }
    return items.take(count).toList();
  }

  Future<void> _persistSnapshots() async {
    final prefs = await _ensurePrefs();
    final encoded = jsonEncode(
      snapshotsNotifier.value.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('comfortSnapshots', encoded);
  }

  List<ComfortSnapshot> _seedSnapshots() {
    final now = DateTime.now();
    return [
      ComfortSnapshot(
        timestamp: now.subtract(const Duration(hours: 36)),
        score: 78,
        humidity: 48,
        temperature: 23.5,
        focus: 'sleep',
      ),
      ComfortSnapshot(
        timestamp: now.subtract(const Duration(hours: 28)),
        score: 74,
        humidity: 50,
        temperature: 24.0,
        focus: 'productivity',
      ),
      ComfortSnapshot(
        timestamp: now.subtract(const Duration(hours: 19)),
        score: 82,
        humidity: 46,
        temperature: 22.8,
        focus: 'sleep',
      ),
      ComfortSnapshot(
        timestamp: now.subtract(const Duration(hours: 12)),
        score: 71,
        humidity: 52,
        temperature: 24.6,
        focus: 'allergy',
      ),
      ComfortSnapshot(
        timestamp: now.subtract(const Duration(hours: 5)),
        score: 85,
        humidity: 45,
        temperature: 22.2,
        focus: 'sleep',
      ),
      ComfortSnapshot(
        timestamp: now.subtract(const Duration(hours: 2)),
        score: 77,
        humidity: 47,
        temperature: 23.1,
        focus: 'productivity',
      ),
    ]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<ComfortTip> _seedTips() {
    return const [
      ComfortTip(
        id: 'sleepEnvironment',
        titleKey: 'comfortTipSleepEnvironmentTitle',
        descriptionKey: 'comfortTipSleepEnvironmentDescription',
        focus: 'sleep',
      ),
      ComfortTip(
        id: 'sleepWindDown',
        titleKey: 'comfortTipSleepWindDownTitle',
        descriptionKey: 'comfortTipSleepWindDownDescription',
        focus: 'sleep',
      ),
      ComfortTip(
        id: 'focusZones',
        titleKey: 'comfortTipFocusZonesTitle',
        descriptionKey: 'comfortTipFocusZonesDescription',
        focus: 'productivity',
      ),
      ComfortTip(
        id: 'focusRhythm',
        titleKey: 'comfortTipFocusRhythmTitle',
        descriptionKey: 'comfortTipFocusRhythmDescription',
        focus: 'productivity',
      ),
      ComfortTip(
        id: 'allergySeal',
        titleKey: 'comfortTipAllergySealTitle',
        descriptionKey: 'comfortTipAllergySealDescription',
        focus: 'allergy',
      ),
      ComfortTip(
        id: 'allergyPulse',
        titleKey: 'comfortTipAllergyPulseTitle',
        descriptionKey: 'comfortTipAllergyPulseDescription',
        focus: 'allergy',
      ),
    ];
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
