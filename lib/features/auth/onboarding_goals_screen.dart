import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals_model.dart';
import 'package:cal_nutri_pal/core/models/user_stats_model.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';
import 'package:cal_nutri_pal/core/services/user_stats_provider.dart';
import 'package:cal_nutri_pal/core/services/main_app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';
import 'package:cal_nutri_pal/features/auth/privacy_terms_screen.dart';

/// Onboarding screen for setting nutrition goals
class OnboardingGoalsScreen extends StatefulWidget {
  /// Function to call when user completes onboarding
  final VoidCallback onComplete;

  /// Function to call when user skips this screen
  final VoidCallback onSkip;

  /// Creates an [OnboardingGoalsScreen] widget
  const OnboardingGoalsScreen({
    Key? key,
    required this.onComplete,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<OnboardingGoalsScreen> createState() => _OnboardingGoalsScreenState();
}

class _OnboardingGoalsScreenState extends State<OnboardingGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calorieController = TextEditingController();

  // Current macro values
  int _proteinPercentage = 30;
  int _carbsPercentage = 40;
  int _fatPercentage = 30;

  // Goal selection
  GoalType _selectedGoalType = GoalType.maintainWeight;

  // Calculated values
  double _calculatedTDEE = 2000;
  int _calculatedCalories = 2000;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCalculations();
    });
  }

  void _initializeCalculations() {
    final userStatsProvider =
        Provider.of<UserStatsProvider>(context, listen: false);
    final nutritionGoalsProvider =
        Provider.of<NutritionGoalsProvider>(context, listen: false);

    // Calculate TDEE based on user stats
    final userStats = userStatsProvider.userStats;
    _calculatedTDEE = userStats.calculateTDEE();

    // Set initial goal type and calculate calories
    _selectedGoalType = nutritionGoalsProvider.selectedGoalType;
    _updateCaloriesBasedOnGoal();

    // Initialize controller with calculated value
    _calorieController.text = _calculatedCalories.toString();

    // Initialize macro percentages from provider or defaults
    final goals = nutritionGoalsProvider.nutritionGoals;
    _proteinPercentage = goals.proteinPercentage;
    _carbsPercentage = goals.carbsPercentage;
    _fatPercentage = goals.fatPercentage;

    setState(() {});
  }

  void _updateCaloriesBasedOnGoal() {
    switch (_selectedGoalType) {
      case GoalType.loseWeight:
        _calculatedCalories = (_calculatedTDEE * 0.8).round(); // 20% deficit
        break;
      case GoalType.maintainWeight:
        _calculatedCalories = _calculatedTDEE.round();
        break;
      case GoalType.gainWeight:
        _calculatedCalories = (_calculatedTDEE * 1.1).round(); // 10% surplus
        break;
    }
  }

  void _updateMacroPercentage(String macroType, int newValue) {
    // Calculate the difference from current value
    int difference = 0;

    if (macroType == 'protein') {
      difference = newValue - _proteinPercentage;
      _proteinPercentage = newValue;
    } else if (macroType == 'carbs') {
      difference = newValue - _carbsPercentage;
      _carbsPercentage = newValue;
    } else {
      difference = newValue - _fatPercentage;
      _fatPercentage = newValue;
    }

    // If no change, exit early
    if (difference == 0) return;

    // Adjust the other two macros proportionally to maintain 100% total
    if (macroType == 'protein') {
      // Adjust carbs and fats
      final carbsRatio = _carbsPercentage / (_carbsPercentage + _fatPercentage);
      final carbsAdjustment = (difference * carbsRatio).round();
      final fatAdjustment = difference - carbsAdjustment;

      _carbsPercentage -= carbsAdjustment;
      _fatPercentage -= fatAdjustment;
    } else if (macroType == 'carbs') {
      // Adjust protein and fats
      final proteinRatio =
          _proteinPercentage / (_proteinPercentage + _fatPercentage);
      final proteinAdjustment = (difference * proteinRatio).round();
      final fatAdjustment = difference - proteinAdjustment;

      _proteinPercentage -= proteinAdjustment;
      _fatPercentage -= fatAdjustment;
    } else {
      // Adjust protein and carbs
      final proteinRatio =
          _proteinPercentage / (_proteinPercentage + _carbsPercentage);
      final proteinAdjustment = (difference * proteinRatio).round();
      final carbsAdjustment = difference - proteinAdjustment;

      _proteinPercentage -= proteinAdjustment;
      _carbsPercentage -= carbsAdjustment;
    }

    // Ensure minimums of 10% for each macro
    _ensureMinimumValues();

    setState(() {});
  }

  void _ensureMinimumValues() {
    const int minimum = 10;

    // Check if any value is below minimum
    if (_proteinPercentage < minimum) {
      int deficit = minimum - _proteinPercentage;
      _proteinPercentage = minimum;

      // Reduce from the larger of the other two
      if (_carbsPercentage > _fatPercentage) {
        _carbsPercentage -= deficit;
      } else {
        _fatPercentage -= deficit;
      }
    }

    if (_carbsPercentage < minimum) {
      int deficit = minimum - _carbsPercentage;
      _carbsPercentage = minimum;

      // Reduce from the larger of the other two
      if (_proteinPercentage > _fatPercentage) {
        _proteinPercentage -= deficit;
      } else {
        _fatPercentage -= deficit;
      }
    }

    if (_fatPercentage < minimum) {
      int deficit = minimum - _fatPercentage;
      _fatPercentage = minimum;

      // Reduce from the larger of the other two
      if (_proteinPercentage > _carbsPercentage) {
        _proteinPercentage -= deficit;
      } else {
        _carbsPercentage -= deficit;
      }
    }

    // Final adjustment if needed to ensure sum is 100%
    int total = _proteinPercentage + _carbsPercentage + _fatPercentage;
    if (total != 100) {
      int adjustment = 100 - total;

      // Add or subtract from the largest value
      if (_proteinPercentage >= _carbsPercentage &&
          _proteinPercentage >= _fatPercentage) {
        _proteinPercentage += adjustment;
      } else if (_carbsPercentage >= _proteinPercentage &&
          _carbsPercentage >= _fatPercentage) {
        _carbsPercentage += adjustment;
      } else {
        _fatPercentage += adjustment;
      }
    }
  }

  void _useRecommendedValues() {
    // Generate recommended nutrition goals based on stats and goal type
    final userStatsProvider =
        Provider.of<UserStatsProvider>(context, listen: false);
    final userStats = userStatsProvider.userStats;
    _calculatedTDEE = userStats.calculateTDEE();

    _updateCaloriesBasedOnGoal();
    _calorieController.text = _calculatedCalories.toString();

    // Set recommended macro distribution based on goal
    switch (_selectedGoalType) {
      case GoalType.loseWeight:
        _proteinPercentage = 40; // Higher protein for preserving muscle
        _carbsPercentage = 30;
        _fatPercentage = 30;
        break;
      case GoalType.maintainWeight:
        _proteinPercentage = 30;
        _carbsPercentage = 40;
        _fatPercentage = 30;
        break;
      case GoalType.gainWeight:
        _proteinPercentage = 30;
        _carbsPercentage = 45; // Higher carbs for energy and muscle gain
        _fatPercentage = 25;
        break;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate macro grams
    final calories =
        int.tryParse(_calorieController.text) ?? _calculatedCalories;
    final proteinGrams =
        (calories * (_proteinPercentage / 100) / 4).toStringAsFixed(0);
    final carbsGrams =
        (calories * (_carbsPercentage / 100) / 4).toStringAsFixed(0);
    final fatGrams = (calories * (_fatPercentage / 100) / 9).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Goals & Progress',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: AppTheme.textSecondaryColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(
                  context, AppRoutes.onboardingStats);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textSecondaryColor),
            onPressed: _handleSkip,
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Progress indicator
                const LinearProgressIndicator(
                  value: 1.0, // 2 of 2 steps
                  backgroundColor: Colors.grey,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step 2 of 2',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nutritional Goals Section
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nutrition Goals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _useRecommendedValues,
                      child: const Text(
                        'Use Recommended',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set your daily calorie and macronutrient targets to help track your nutrition goals.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Goal Type Selection
                const Text(
                  'Select Your Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoSlidingSegmentedControl<GoalType>(
                  groupValue: _selectedGoalType,
                  thumbColor: AppTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  children: const {
                    GoalType.loseWeight: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Lose',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GoalType.maintainWeight: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Maintain',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GoalType.gainWeight: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Gain',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (GoalType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGoalType = newValue;
                        _updateCaloriesBasedOnGoal();
                        _calorieController.text =
                            _calculatedCalories.toString();
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Daily Calorie Target
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange[400],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Daily Calorie Target',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _calorieController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter calories',
                          suffixText: 'kcal',
                          suffixStyle: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a calorie target';
                          }
                          final calories = int.tryParse(value);
                          if (calories == null) {
                            return 'Please enter a valid number';
                          }
                          if (calories < 1000) {
                            return 'Calorie target should be at least 1000';
                          }
                          if (calories > 10000) {
                            return 'Calorie target should be less than 10000';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recommended: $_calculatedCalories kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Macronutrient Breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Macronutrient Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Macro Pie Chart
                      SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            // Pie Chart
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    PieChartSectionData(
                                      value: _proteinPercentage.toDouble(),
                                      title: '$_proteinPercentage%',
                                      color: Colors.blue[400]!,
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: _carbsPercentage.toDouble(),
                                      title: '$_carbsPercentage%',
                                      color: Colors.orange[400]!,
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: _fatPercentage.toDouble(),
                                      title: '$_fatPercentage%',
                                      color: Colors.green[400]!,
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Legend
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem('Protein', '$proteinGrams g',
                                    Colors.blue[400]!),
                                const SizedBox(height: 12),
                                _buildLegendItem('Carbs', '$carbsGrams g',
                                    Colors.orange[400]!),
                                const SizedBox(height: 12),
                                _buildLegendItem(
                                    'Fat', '$fatGrams g', Colors.green[400]!),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Protein Slider
                      _buildMacroSlider(
                        label: 'Protein',
                        value: _proteinPercentage,
                        color: Colors.blue[400]!,
                        onChanged: (newValue) {
                          _updateMacroPercentage('protein', newValue.round());
                        },
                      ),

                      // Carbs Slider
                      _buildMacroSlider(
                        label: 'Carbs',
                        value: _carbsPercentage,
                        color: Colors.orange[400]!,
                        onChanged: (newValue) {
                          _updateMacroPercentage('carbs', newValue.round());
                        },
                      ),

                      // Fat Slider
                      _buildMacroSlider(
                        label: 'Fat',
                        value: _fatPercentage,
                        color: Colors.green[400]!,
                        onChanged: (newValue) {
                          _updateMacroPercentage('fat', newValue.round());
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Error message if any
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // Complete Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Complete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroSlider({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 10,
            max: 80,
            divisions: 70,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Handle completion logic
  Future<void> _handleComplete() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final goalProvider =
            Provider.of<NutritionGoalsProvider>(context, listen: false);

        // Create nutrition goals object
        final nutritionGoals = NutritionGoals(
          calorieGoal: int.parse(_calorieController.text),
          proteinPercentage: _proteinPercentage,
          carbsPercentage: _carbsPercentage,
          fatPercentage: _fatPercentage,
        );

        // Save to provider and storage
        await goalProvider.updateNutritionGoals(nutritionGoals);

        // Set selected goal type
        goalProvider.setGoalType(_selectedGoalType);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          // Show privacy terms screen before completing
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PrivacyTermsScreen(
                onComplete: (accepted) {
                  Navigator.of(context).pop(accepted);
                },
              ),
            ),
          );

          // Only complete onboarding if privacy terms were accepted
          if (result == true) {
            setState(() {
              _isLoading = true;
            });

            final mainController =
                Provider.of<MainAppController>(context, listen: false);

            // Mark onboarding as complete
            await mainController.completeOnboarding();

            // Set onboarding complete flag
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('has_completed_onboarding', true);
            await prefs.setBool('has_accepted_privacy_terms', true);

            if (mounted) {
              // Navigate to main app and clear history
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.main, (route) => false);
            }
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error saving goals: ${e.toString()}';
        });
      }
    }
  }

  /// Handle skip logic
  Future<void> _handleSkip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Show privacy terms screen before skipping
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrivacyTermsScreen(
              onComplete: (accepted) {
                Navigator.of(context).pop(accepted);
              },
            ),
          ),
        );

        // Only complete onboarding if privacy terms were accepted
        if (result == true) {
          setState(() {
            _isLoading = true;
          });

          // Set onboarding complete flag
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_completed_onboarding', true);
          await prefs.setBool('has_accepted_privacy_terms', true);

          if (mounted) {
            // Navigate to main app and clear history
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.main, (route) => false);
          }
        }
      }
    } catch (e) {
      // Handle errors if saving default goals
      debugPrint("Error skipping goals screen: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
