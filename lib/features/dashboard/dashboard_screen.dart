import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/shared/widgets/nutrient_progress_card.dart';
import 'package:cal_nutri_pal/core/services/nutrition_log_provider.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:cal_nutri_pal/core/services/user_stats_provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dashboard screen for the app
class DashboardScreen extends StatefulWidget {
  /// Creates the [DashboardScreen] widget
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  String _welcomeMessage = 'Welcome!';
  int _waterGoalMl = 2000; // Default water goal

  @override
  void initState() {
    super.initState();
    _updateWelcomeMessage();
    _loadWaterGoal(); // Ensure water goal is loaded
    // Optionally, trigger loading today's log if needed immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensures provider is available when called
      final logProvider =
          Provider.of<NutritionLogProvider>(context, listen: false);
      // Load log if it hasn't been loaded or if date is different
      if (logProvider.currentDailyLog.date.day != DateTime.now().day) {
        logProvider.loadLogForDate(DateTime.now());
      }
    });
  }

  void _updateWelcomeMessage() {
    // Use a generic welcome message
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    setState(() {
      _welcomeMessage = '$greeting!';
    });
  }

  /// Load water goal from SharedPreferences
  Future<void> _loadWaterGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _waterGoalMl = prefs.getInt('user_water_goal_ml') ?? 2000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_welcomeMessage),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Show date picker
              _selectDate(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<NutritionLogProvider>(
          builder: (context, logProvider, child) {
            // Show loading indicator if log is loading
            if (logProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily summary card
                  _buildDailySummaryCard(),

                  const SizedBox(height: 24),

                  // Section title
                  const Text(
                    'Nutrients',
                    style: AppTheme.subheadingStyle,
                  ),

                  const SizedBox(height: 16),

                  // Nutrients grid
                  _buildNutrientsGrid(),

                  const SizedBox(height: 24),

                  // Recent meals section
                  const Text(
                    'Recent Meals',
                    style: AppTheme.subheadingStyle,
                  ),

                  const SizedBox(height: 16),

                  // Show meals or placeholder
                  _buildRecentMeals(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Show date picker to select a date
  Future<void> _selectDate(BuildContext context) async {
    final logProvider =
        Provider.of<NutritionLogProvider>(context, listen: false);
    final DateTime now = DateTime.now();
    final initialDate = logProvider.currentDailyLog.date;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && picked != initialDate) {
      logProvider.loadLogForDate(picked);
    }
  }

  Widget _buildDailySummaryCard() {
    return Consumer2<NutritionLogProvider, NutritionGoalsProvider>(
      builder: (context, logProvider, nutritionGoalsProvider, child) {
        // Get actual consumed calories from nutrition log
        final consumedCalories = logProvider.currentDailyLog.totalCalories;

        // Use goals from the provider that were set during onboarding
        final calorieTarget = nutritionGoalsProvider.nutritionGoals.calorieGoal;
        final percentConsumed =
            (consumedCalories / calorieTarget).clamp(0.0, 1.0);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Summary',
                      style: AppTheme.subheadingStyle,
                    ),
                    Text(
                      '${logProvider.currentDailyLog.date.month}/${logProvider.currentDailyLog.date.day}/${logProvider.currentDailyLog.date.year}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calories',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${consumedCalories.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / $calorieTarget kcal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(percentConsumed * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const Text(
                              'consumed',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: percentConsumed,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor),
                  minHeight: 8,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),

                // Display meal breakdown
                if (logProvider.currentDailyLog.entries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Meal Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMealBreakdown(logProvider),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealBreakdown(NutritionLogProvider logProvider) {
    // Calculate calories per meal type
    final breakfastCalories = logProvider.breakfastEntries
        .fold<double>(0, (sum, entry) => sum + entry.calories);
    final lunchCalories = logProvider.lunchEntries
        .fold<double>(0, (sum, entry) => sum + entry.calories);
    final dinnerCalories = logProvider.dinnerEntries
        .fold<double>(0, (sum, entry) => sum + entry.calories);
    final snackCalories = logProvider.snackEntries
        .fold<double>(0, (sum, entry) => sum + entry.calories);

    // Calculate total calories
    final totalCalories = logProvider.currentDailyLog.totalCalories;

    return Column(
      children: [
        _buildMealProgressBar(
            'Breakfast', breakfastCalories, totalCalories, Colors.amber),
        const SizedBox(height: 8),
        _buildMealProgressBar(
            'Lunch', lunchCalories, totalCalories, Colors.orange),
        const SizedBox(height: 8),
        _buildMealProgressBar(
            'Dinner', dinnerCalories, totalCalories, Colors.red),
        const SizedBox(height: 8),
        _buildMealProgressBar(
            'Snacks', snackCalories, totalCalories, Colors.purple),
      ],
    );
  }

  Widget _buildMealProgressBar(
      String label, double value, double total, Color color) {
    final percentage = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ),
        SizedBox(
          width: 70,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${value.toInt()} kcal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientsGrid() {
    return Consumer2<NutritionLogProvider, NutritionGoalsProvider>(
      builder: (context, logProvider, nutritionGoalsProvider, child) {
        // Get actual consumed nutrients from nutrition log
        final consumedProtein = logProvider.currentDailyLog.totalProteins;
        final consumedCarbs = logProvider.currentDailyLog.totalCarbs;
        final consumedFat = logProvider.currentDailyLog.totalFats;
        final consumedWater = logProvider.currentDailyLog.waterIntake ?? 0.0;

        // Get goal values from the nutrition goals provider (set during onboarding)
        final proteinGoal = nutritionGoalsProvider.nutritionGoals.proteinGrams;
        final carbsGoal = nutritionGoalsProvider.nutritionGoals.carbsGrams;
        final fatGoal = nutritionGoalsProvider.nutritionGoals.fatGrams;
        // Use the fetched water goal from state
        final waterGoal = _waterGoalMl.toDouble();

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            NutrientProgressCard(
              title: 'Protein',
              currentValue: consumedProtein,
              goalValue: proteinGoal,
              color: Colors.blue,
              unit: 'g',
            ),
            NutrientProgressCard(
              title: 'Carbs',
              currentValue: consumedCarbs,
              goalValue: carbsGoal,
              color: Colors.orange,
              unit: 'g',
            ),
            NutrientProgressCard(
              title: 'Fat',
              currentValue: consumedFat,
              goalValue: fatGoal,
              color: Colors.red,
              unit: 'g',
            ),
            NutrientProgressCard(
              title: 'Water',
              currentValue: consumedWater,
              goalValue: waterGoal,
              color: Colors.lightBlue,
              unit: 'ml',
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentMeals() {
    return Consumer<NutritionLogProvider>(
      builder: (context, logProvider, child) {
        // If no entries, show placeholder
        if (logProvider.currentDailyLog.entries.isEmpty) {
          return _buildRecentMealsPlaceholder();
        }

        // Otherwise, show the last 3 entries
        final recentEntries = [...logProvider.currentDailyLog.entries];
        recentEntries.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
        final entriesToShow = recentEntries.take(3).toList();

        return Column(
          children: entriesToShow.map((entry) {
            return _buildMealCard(entry);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMealCard(NutritionLogEntry entry) {
    String mealTypeString;
    Color mealColor;

    switch (entry.mealType) {
      case MealType.breakfast:
        mealTypeString = 'Breakfast';
        mealColor = Colors.amber;
        break;
      case MealType.lunch:
        mealTypeString = 'Lunch';
        mealColor = Colors.orange;
        break;
      case MealType.dinner:
        mealTypeString = 'Dinner';
        mealColor = Colors.red;
        break;
      case MealType.snack:
        mealTypeString = 'Snack';
        mealColor = Colors.purple;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 50,
              decoration: BoxDecoration(
                color: mealColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$mealTypeString • ${entry.amount.toStringAsFixed(0)} ${entry.unit}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.calories.toInt()} kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'P: ${entry.proteins.toInt()}g • C: ${entry.carbs.toInt()}g • F: ${entry.fats.toInt()}g',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMealsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No meals logged for this day',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Navigate to add meal screen
              Navigator.pushNamed(context, '/add-meal');
            },
            child: const Text('Add Meal'),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // Helper to calculate water progress safely
  double _calculateWaterProgress(NutritionLogProvider logProvider) {
    final currentIntake = logProvider.currentDailyLog.waterIntake ?? 0;
    // Avoid division by zero if goal is somehow 0
    final goal = _waterGoalMl > 0 ? _waterGoalMl : 2000;
    return (currentIntake / goal).clamp(0.0, 1.0);
  }
}
