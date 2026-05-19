import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String displayDate(DateTime date) {
    final day = date.day;
    return '$day${_ordinal(day)} ${DateFormat('MMM yyyy').format(date)}';
  }

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
