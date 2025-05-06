import 'package:flutter/foundation.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals.dart';

/// A service that provides nutrition goals data throughout the app
class NutritionGoalsService extends ChangeNotifier {
  /// The current nutrition goals
  NutritionGoals _goals = NutritionGoals.defaultGoals();

  /// Constructor
  NutritionGoalsService() {
    _initializeGoals();
  }

  /// Initialize goals from storage
  Future<void> _initializeGoals() async {
    try {
      _goals = await NutritionGoals.load();
      notifyListeners();
    } catch (e) {
      // If loading fails, default goals will be used
      print('Error loading nutrition goals: $e');
    }
  }

  /// Get the current nutrition goals
  NutritionGoals get goals => _goals;

  /// Update the nutrition goals
  Future<void> updateGoals(NutritionGoals newGoals) async {
    _goals = newGoals;
    notifyListeners();

    try {
      await newGoals.save();
    } catch (e) {
      print('Error saving nutrition goals: $e');
      // You could add error handling or retry logic here
    }
  }

  /// Returns the nutrition goal for calories
  String get calorieGoal => '${_goals.calorieTarget} kcal';

  /// Returns the nutrition goal for protein
  String get proteinGoal => '${_goals.proteinGrams.toStringAsFixed(0)} g';

  /// Returns the nutrition goal for carbs
  String get carbsGoal => '${_goals.carbsGrams.toStringAsFixed(0)} g';

  /// Returns the nutrition goal for fat
  String get fatGoal => '${_goals.fatGrams.toStringAsFixed(0)} g';

  /// Returns the macronutrient percentages as a map
  Map<String, int> get macroPercentages => {
        'protein': _goals.proteinPercentage,
        'carbs': _goals.carbsPercentage,
        'fat': _goals.fatPercentage,
      };
}
