import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/streak_data.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';
import 'package:cal_nutri_pal/features/goals/nutrition_goals_tab.dart';
import 'package:cal_nutri_pal/features/goals/streak_tracking_tab.dart';

/// Screen for displaying and setting nutrition goals and tracking progress
class GoalsProgressScreen extends StatefulWidget {
  /// Creates the [GoalsProgressScreen] widget
  const GoalsProgressScreen({super.key});

  @override
  State<GoalsProgressScreen> createState() => _GoalsProgressScreenState();
}

class _GoalsProgressScreenState extends State<GoalsProgressScreen>
    with SingleTickerProviderStateMixin {
  /// Tab controller for switching between goals and streak tabs
  late TabController _tabController;

  /// Current streak data
  StreakData? _streakData;

  /// Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load streak data from storage
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the NutritionGoalsProvider
      final nutritionGoalsProvider =
          Provider.of<NutritionGoalsProvider>(context, listen: false);
      await nutritionGoalsProvider.initialize();

      // Load streak data
      final streakData = await StreakData.load();

      setState(() {
        _streakData = streakData;
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, use default values
      setState(() {
        _streakData = const StreakData();
        _isLoading = false;
      });
    }
  }

  /// Log a new date to update streak
  Future<void> _logDate(DateTime date) async {
    if (_streakData != null) {
      final newStreakData = _streakData!.logDate(date);

      setState(() {
        _streakData = newStreakData;
      });

      try {
        await newStreakData.save();
      } catch (e) {
        // Handle saving error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update streak: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Progress'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: const [
            Tab(text: 'Nutrition Goals'),
            Tab(text: 'Streak Tracking'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Nutrition Goals Tab - now using provider
                const NutritionGoalsTab(),

                // Streak Tracking Tab
                StreakTrackingTab(
                  streakData: _streakData ?? const StreakData(),
                  onLogDate: _logDate,
                ),
              ],
            ),
    );
  }
}
