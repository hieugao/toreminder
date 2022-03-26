import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  static get todayDateOnly {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get isToday {
    return difference(todayDateOnly).inDays == 0;
  }

  bool get isThisWeek {
    return difference(todayDateOnly).inDays < 7;
  }

  String toRelative() {
    final now = DateTime.now();

    switch (difference(DateTime(now.year, now.month, now.day)).inDays) {
      case -1:
        return 'Yesterday';
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      default:
        return '${DateFormat('E').format(this)}, ${DateFormat('MMMd').format(this)}';
      //  ${hour != 0 && minute != 0 ? ', ' + DateFormat('Hm').format(this) : ""}';
    }
  }
}
