import '../../core/l10n/app_localizations.dart';
import '../models/environment_schedule.dart';

class ScheduleFormatter {
  const ScheduleFormatter._();

  static String describeDays(AppLocalizations l10n, EnvironmentSchedule schedule) {
    final selected = schedule.days.toSet();
    if (selected.isEmpty || selected.containsAll(_allDays)) {
      return l10n.getString('scheduleEveryday');
    }
    if (selected.containsAll(_weekdays) && selected.length == _weekdays.length) {
      return l10n.getString('scheduleWeekdays');
    }
    if (selected.containsAll(_weekend) && selected.length == _weekend.length) {
      return l10n.getString('scheduleWeekend');
    }
    final labels = <String>[];
    for (final day in _orderedDays) {
      if (selected.contains(day)) {
        labels.add(_labelForDay(l10n, day));
      }
    }
    return labels.join(' · ');
  }

  static const List<int> _orderedDays = <int>[
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  static final Set<int> _allDays = _orderedDays.toSet();
  static final Set<int> _weekdays = <int>{
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };
  static final Set<int> _weekend = <int>{
    DateTime.saturday,
    DateTime.sunday,
  };

  static String _labelForDay(AppLocalizations l10n, int day) {
    switch (day) {
      case DateTime.monday:
        return l10n.getString('scheduleDayMon');
      case DateTime.tuesday:
        return l10n.getString('scheduleDayTue');
      case DateTime.wednesday:
        return l10n.getString('scheduleDayWed');
      case DateTime.thursday:
        return l10n.getString('scheduleDayThu');
      case DateTime.friday:
        return l10n.getString('scheduleDayFri');
      case DateTime.saturday:
        return l10n.getString('scheduleDaySat');
      case DateTime.sunday:
        return l10n.getString('scheduleDaySun');
    }
    return '';
  }
}
