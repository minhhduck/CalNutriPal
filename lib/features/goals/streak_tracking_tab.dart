import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/streak_data.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Tab for displaying streak tracking information and calendar
class StreakTrackingTab extends StatefulWidget {
  /// Current streak data
  final StreakData streakData;

  /// Callback when a date is logged
  final Function(DateTime) onLogDate;

  /// Creates the [StreakTrackingTab] widget
  const StreakTrackingTab({
    Key? key,
    required this.streakData,
    required this.onLogDate,
  }) : super(key: key);

  @override
  State<StreakTrackingTab> createState() => _StreakTrackingTabState();
}

class _StreakTrackingTabState extends State<StreakTrackingTab> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header section
            _buildHeader(),
            const SizedBox(height: 24),

            // Streak cards
            _buildStreakCards(),
            const SizedBox(height: 24),

            // Milestone progress
            _buildMilestoneProgress(),
            const SizedBox(height: 24),

            // Calendar section
            _buildCalendarSection(),
            const SizedBox(height: 24),

            // Log today button (if not already logged)
            if (!widget.streakData.isDateLogged(DateTime.now()))
              _buildLogTodayButton(),
          ],
        ),
      ),
    );
  }

  /// Build the header section with title and description
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Streak Tracking",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track your daily logging consistency",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Build streak cards (current and longest)
  Widget _buildStreakCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStreakCard(
              "Current Streak",
              "${widget.streakData.currentStreak}",
              "days",
              Colors.blue[100]!,
              Colors.blue[700]!,
              Icons.local_fire_department,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStreakCard(
              "Longest Streak",
              "${widget.streakData.longestStreak}",
              "days",
              Colors.purple[100]!,
              Colors.purple[700]!,
              Icons.emoji_events,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a streak card with icon and count
  Widget _buildStreakCard(
    String title,
    String value,
    String unit,
    Color backgroundColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build milestone progress section (Now an empty container or can be removed entirely)
  Widget _buildMilestoneProgress() {
    return Container(); // Return an empty container, or remove the call to this method
  }

  /// Build calendar section
  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Calendar",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: _buildCalendarLogButton(),
                ),
              ],
            ),
          ),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Colors.blue[200],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final isLogged = widget.streakData.isDateLogged(date);
                    if (isLogged) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          width: 8,
                          height: 8,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem("Logged Day", Colors.green),
                _buildLegendItem("Today", Colors.blue[200]!),
                _buildLegendItem("Selected", Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// Build log today button
  Widget _buildLogTodayButton() {
    final today = DateTime.now();
    final isToday = isSameDay(today, _selectedDay);
    final alreadyLogged = widget.streakData.isDateLogged(_selectedDay);

    return ElevatedButton.icon(
      onPressed: alreadyLogged
          ? null
          : () {
              widget.onLogDate(_selectedDay);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isToday
                        ? "Today logged successfully!"
                        : "${DateFormat('MMM d').format(_selectedDay)} logged successfully!",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
      icon: const Icon(Icons.check),
      label: Text(isToday ? "Log Today" : "Log Selected"),
      style: ElevatedButton.styleFrom(
        backgroundColor: alreadyLogged ? Colors.grey[300] : Colors.green,
        foregroundColor: alreadyLogged ? Colors.grey[600] : Colors.white,
      ),
    );
  }

  /// Build a smaller log button for the calendar header
  Widget _buildCalendarLogButton() {
    final today = DateTime.now();
    final isToday = isSameDay(today, _selectedDay);
    final alreadyLogged = widget.streakData.isDateLogged(_selectedDay);

    return ElevatedButton.icon(
      onPressed: alreadyLogged
          ? null
          : () {
              widget.onLogDate(_selectedDay);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isToday
                        ? "Today logged successfully!"
                        : "${DateFormat('MMM d').format(_selectedDay)} logged successfully!",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
      icon: const Icon(Icons.check, size: 16),
      label: Text(
        "Log",
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: alreadyLogged ? Colors.grey[300] : Colors.green,
        foregroundColor: alreadyLogged ? Colors.grey[600] : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: const Size(0, 0),
      ),
    );
  }
}
