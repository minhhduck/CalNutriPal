import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Represents streak tracking data for user's daily logging activity
class StreakData {
  /// The user's current streak (consecutive days logged)
  final int currentStreak;

  /// The user's longest streak historically
  final int longestStreak;

  /// Set of logged dates as string (format: yyyy-MM-dd)
  final Set<String> loggedDates;

  /// Creates a new StreakData instance
  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.loggedDates = const {},
  });

  /// Returns true if the given date has been logged
  bool isDateLogged(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return loggedDates.contains(dateStr);
  }

  /// Returns the next milestone day count
  int get nextMilestone {
    if (currentStreak < 3) return 3;
    if (currentStreak < 7) return 7;
    if (currentStreak < 14) return 14;
    if (currentStreak < 21) return 21;
    if (currentStreak < 30) return 30;
    if (currentStreak < 60) return 60;
    if (currentStreak < 90) return 90;
    if (currentStreak < 180) return 180;
    if (currentStreak < 365) return 365;
    return (currentStreak ~/ 365 + 1) * 365; // Next year milestone
  }

  /// Returns progress towards next milestone (0.0 to 1.0)
  double get milestoneProgress {
    if (currentStreak == 0) return 0.0;

    final previousMilestone = currentStreak < 3
        ? 0
        : currentStreak < 7
            ? 3
            : currentStreak < 14
                ? 7
                : currentStreak < 21
                    ? 14
                    : currentStreak < 30
                        ? 21
                        : currentStreak < 60
                            ? 30
                            : currentStreak < 90
                                ? 60
                                : currentStreak < 180
                                    ? 90
                                    : currentStreak < 365
                                        ? 180
                                        : (currentStreak ~/ 365) * 365;

    return (currentStreak - previousMilestone) /
        (nextMilestone - previousMilestone);
  }

  /// Creates a new instance with updated streak after adding a logged date
  StreakData addLoggedDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // If already logged, return unchanged
    if (loggedDates.contains(dateStr)) {
      return this;
    }

    // Create new set of logged dates
    final newLoggedDates = Set<String>.from(loggedDates);
    newLoggedDates.add(dateStr);

    // Calculate new streak
    int newStreak = _calculateCurrentStreak(newLoggedDates);

    // Update longest streak if needed
    int newLongestStreak = longestStreak;
    if (newStreak > longestStreak) {
      newLongestStreak = newStreak;
    }

    return StreakData(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      loggedDates: newLoggedDates,
    );
  }

  /// Calculate current streak based on logged dates
  int _calculateCurrentStreak(Set<String> dates) {
    if (dates.isEmpty) return 0;

    // Get sorted dates
    final sortedDates = dates
        .map((dateStr) => DateFormat('yyyy-MM-dd').parse(dateStr))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    // Start with most recent date
    DateTime checkDate = sortedDates.first;
    int streak = 1;

    // Check if today is logged
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    // If most recent date is not today or yesterday, reset streak
    if (!dates.contains(todayStr)) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);

      if (!dates.contains(yesterdayStr)) {
        return 0; // Streak broken
      }
    }

    // Count consecutive days
    for (int i = 1; i < 1000; i++) {
      // Safety limit
      final prevDate = checkDate.subtract(Duration(days: 1));
      final prevDateStr = DateFormat('yyyy-MM-dd').format(prevDate);

      if (dates.contains(prevDateStr)) {
        streak++;
        checkDate = prevDate;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Creates a StreakData from JSON map
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      loggedDates: (json['loggedDates'] as List<dynamic>?)
              ?.map((date) => date.toString())
              ?.toSet() ??
          {},
    );
  }

  /// Converts StreakData to JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'loggedDates': loggedDates.toList(),
    };
  }

  /// Formats a DateTime as a string key (yyyy-MM-dd)
  static String formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Adds a date to the logged dates and updates the streak
  StreakData logDate(DateTime date) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = formatDateKey(normalizedDate);

    // Create a new set with the new date
    final newLoggedDates = Set<String>.from(loggedDates)..add(dateKey);

    // Calculate the new streak
    int newStreak = currentStreak;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = formatDateKey(yesterday);

    // If yesterday was logged or this is the first entry, increment streak
    if (currentStreak == 0 || loggedDates.contains(yesterdayKey)) {
      newStreak++;
    } else {
      // Streak broken
      newStreak = 1;
    }

    // Update longest streak if needed
    final newLongestStreak =
        newStreak > longestStreak ? newStreak : longestStreak;

    return StreakData(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      loggedDates: newLoggedDates,
    );
  }

  /// Creates a copy of this [StreakData] with the given values
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    Set<String>? loggedDates,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      loggedDates: loggedDates ?? this.loggedDates,
    );
  }

  /// Saves the streak data to local storage
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', currentStreak);
    await prefs.setInt('longestStreak', longestStreak);
    await prefs.setStringList('loggedDates', loggedDates.toList());
  }

  /// Loads streak data from local storage
  static Future<StreakData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = prefs.getStringList('loggedDates') ?? [];

    return StreakData(
      currentStreak: prefs.getInt('currentStreak') ?? 0,
      longestStreak: prefs.getInt('longestStreak') ?? 0,
      loggedDates: dateStrings.toSet(),
    );
  }
}
