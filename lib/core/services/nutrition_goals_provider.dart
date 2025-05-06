import 'package:flutter/foundation.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals_model.dart';
import 'package:cal_nutri_pal/core/models/user_stats_model.dart';

/// Provider class that manages nutrition goals
class NutritionGoalsProvider extends ChangeNotifier {
  /// Current nutrition goals
  NutritionGoals? _nutritionGoals;

  /// Whether the provider is currently loading
  bool _isLoading = false;

  /// Error message if any
  String? _errorMessage;

  /// Currently selected goal type
  GoalType _selectedGoalType = GoalType.maintainWeight;

  /// Get current nutrition goals
  NutritionGoals get nutritionGoals =>
      _nutritionGoals ?? NutritionGoals.defaultValues();

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get selected goal type
  GoalType get selectedGoalType => _selectedGoalType;

  /// Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _nutritionGoals = await NutritionGoals.load();
    } catch (e) {
      _setError('Failed to load nutrition goals: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate nutrition goals based on user stats and goal type
  Future<void> generateGoalsFromStats(
      UserStats userStats, GoalType goalType) async {
    _setLoading(true);
    try {
      final tdee = userStats.calculateTDEE();
      _selectedGoalType = goalType;
      _nutritionGoals = NutritionGoals.fromTDEE(tdee, goalType);
      await _nutritionGoals!.save();
      _clearError();
    } catch (e) {
      _setError('Failed to generate nutrition goals: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update calorie goal
  Future<void> updateCalorieGoal(int calorieGoal) async {
    if (calorieGoal < 1000) {
      _setError('Calorie goal should be at least 1000 calories');
      return;
    }
    if (calorieGoal > 10000) {
      _setError('Calorie goal should be less than 10000 calories');
      return;
    }

    final updatedGoals = nutritionGoals.copyWith(calorieGoal: calorieGoal);
    await _updateNutritionGoals(updatedGoals);
  }

  /// Update protein percentage
  Future<void> updateProteinPercentage(int percentage) async {
    // Ensure macros still add up to 100%
    final currentTotal = nutritionGoals.proteinPercentage +
        nutritionGoals.carbsPercentage +
        nutritionGoals.fatPercentage;
    final difference = percentage - nutritionGoals.proteinPercentage;

    // Adjust carbs and fats to maintain 100% total
    int newCarbsPercentage = nutritionGoals.carbsPercentage;
    int newFatPercentage = nutritionGoals.fatPercentage;

    if (currentTotal + difference != 100) {
      // Remove the difference from carbs and fats proportionally
      final carbsRatio = nutritionGoals.carbsPercentage /
          (nutritionGoals.carbsPercentage + nutritionGoals.fatPercentage);
      final carbsAdjustment = (difference * carbsRatio).round();
      final fatAdjustment = difference - carbsAdjustment;

      newCarbsPercentage = nutritionGoals.carbsPercentage - carbsAdjustment;
      newFatPercentage = nutritionGoals.fatPercentage - fatAdjustment;

      // Ensure minimums
      if (newCarbsPercentage < 10) {
        newCarbsPercentage = 10;
        newFatPercentage = 90 - percentage;
      }
      if (newFatPercentage < 10) {
        newFatPercentage = 10;
        newCarbsPercentage = 90 - percentage;
      }
    }

    final updatedGoals = nutritionGoals.copyWith(
      proteinPercentage: percentage,
      carbsPercentage: newCarbsPercentage,
      fatPercentage: newFatPercentage,
    );

    if (!updatedGoals.validateMacros()) {
      _setError('Macronutrient percentages must sum to 100%');
      return;
    }

    await _updateNutritionGoals(updatedGoals);
  }

  /// Update carbohydrate percentage
  Future<void> updateCarbsPercentage(int percentage) async {
    // Ensure macros still add up to 100%
    final currentTotal = nutritionGoals.proteinPercentage +
        nutritionGoals.carbsPercentage +
        nutritionGoals.fatPercentage;
    final difference = percentage - nutritionGoals.carbsPercentage;

    // Adjust protein and fats to maintain 100% total
    int newProteinPercentage = nutritionGoals.proteinPercentage;
    int newFatPercentage = nutritionGoals.fatPercentage;

    if (currentTotal + difference != 100) {
      // Remove the difference from protein and fats proportionally
      final proteinRatio = nutritionGoals.proteinPercentage /
          (nutritionGoals.proteinPercentage + nutritionGoals.fatPercentage);
      final proteinAdjustment = (difference * proteinRatio).round();
      final fatAdjustment = difference - proteinAdjustment;

      newProteinPercentage =
          nutritionGoals.proteinPercentage - proteinAdjustment;
      newFatPercentage = nutritionGoals.fatPercentage - fatAdjustment;

      // Ensure minimums
      if (newProteinPercentage < 10) {
        newProteinPercentage = 10;
        newFatPercentage = 90 - percentage;
      }
      if (newFatPercentage < 10) {
        newFatPercentage = 10;
        newProteinPercentage = 90 - percentage;
      }
    }

    final updatedGoals = nutritionGoals.copyWith(
      proteinPercentage: newProteinPercentage,
      carbsPercentage: percentage,
      fatPercentage: newFatPercentage,
    );

    if (!updatedGoals.validateMacros()) {
      _setError('Macronutrient percentages must sum to 100%');
      return;
    }

    await _updateNutritionGoals(updatedGoals);
  }

  /// Update fat percentage
  Future<void> updateFatPercentage(int percentage) async {
    // Ensure macros still add up to 100%
    final currentTotal = nutritionGoals.proteinPercentage +
        nutritionGoals.carbsPercentage +
        nutritionGoals.fatPercentage;
    final difference = percentage - nutritionGoals.fatPercentage;

    // Adjust protein and carbs to maintain 100% total
    int newProteinPercentage = nutritionGoals.proteinPercentage;
    int newCarbsPercentage = nutritionGoals.carbsPercentage;

    if (currentTotal + difference != 100) {
      // Remove the difference from protein and carbs proportionally
      final proteinRatio = nutritionGoals.proteinPercentage /
          (nutritionGoals.proteinPercentage + nutritionGoals.carbsPercentage);
      final proteinAdjustment = (difference * proteinRatio).round();
      final carbsAdjustment = difference - proteinAdjustment;

      newProteinPercentage =
          nutritionGoals.proteinPercentage - proteinAdjustment;
      newCarbsPercentage = nutritionGoals.carbsPercentage - carbsAdjustment;

      // Ensure minimums
      if (newProteinPercentage < 10) {
        newProteinPercentage = 10;
        newCarbsPercentage = 90 - percentage;
      }
      if (newCarbsPercentage < 10) {
        newCarbsPercentage = 10;
        newProteinPercentage = 90 - percentage;
      }
    }

    final updatedGoals = nutritionGoals.copyWith(
      proteinPercentage: newProteinPercentage,
      carbsPercentage: newCarbsPercentage,
      fatPercentage: percentage,
    );

    if (!updatedGoals.validateMacros()) {
      _setError('Macronutrient percentages must sum to 100%');
      return;
    }

    await _updateNutritionGoals(updatedGoals);
  }

  /// Update all macro percentages directly
  Future<void> updateMacroPercentages(
      {required int proteinPercentage,
      required int carbsPercentage,
      required int fatPercentage}) async {
    if (proteinPercentage + carbsPercentage + fatPercentage != 100) {
      _setError('Macronutrient percentages must sum to 100%');
      return;
    }

    if (proteinPercentage < 10 || carbsPercentage < 10 || fatPercentage < 10) {
      _setError('Each macronutrient must be at least 10%');
      return;
    }

    final updatedGoals = nutritionGoals.copyWith(
      proteinPercentage: proteinPercentage,
      carbsPercentage: carbsPercentage,
      fatPercentage: fatPercentage,
    );

    await _updateNutritionGoals(updatedGoals);
  }

  /// Set the selected goal type
  void setGoalType(GoalType goalType) {
    _selectedGoalType = goalType;
    notifyListeners();
  }

  /// Update nutrition goals with completely new values
  Future<void> updateNutritionGoals(NutritionGoals newGoals) async {
    await _updateNutritionGoals(newGoals);
  }

  /// Helper method to update goals and save to storage
  Future<void> _updateNutritionGoals(NutritionGoals updatedGoals) async {
    _setLoading(true);
    try {
      _nutritionGoals = updatedGoals;
      await updatedGoals.save();
      _clearError();
    } catch (e) {
      _setError('Failed to save nutrition goals: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
