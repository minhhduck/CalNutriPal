import 'package:intl/intl.dart';

/// Utility class for formatting dates in the app
class DateFormatter {
  /// Returns the date in the format 'Mon, Jan 1'
  static String formatDayMonth(DateTime date) {
    return DateFormat('E, MMM d').format(date);
  }

  /// Returns the date in the format 'Monday, January 1, 2023'
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  /// Returns the date in the format 'Jan 1, 2023'
  static String formatMediumDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Returns the date in the format '01/01/2023'
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Returns the time in the format '3:30 PM'
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Returns true if the given date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns true if the given date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns true if the given date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Returns a friendly string representation of the date (Today, Yesterday, etc.)
  static String getFriendlyDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      return formatMediumDate(date);
    }
  }

  /// Returns a list of DateTime objects for the past week
  static List<DateTime> getPastWeekDates() {
    final today = DateTime.now();
    final dates = <DateTime>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      dates.add(DateTime(date.year, date.month, date.day));
    }

    return dates;
  }

  /// Returns a list of DateTime objects for the next week
  static List<DateTime> getNextWeekDates() {
    final today = DateTime.now();
    final dates = <DateTime>[];

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      dates.add(DateTime(date.year, date.month, date.day));
    }

    return dates;
  }
}
