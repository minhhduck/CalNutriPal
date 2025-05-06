import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A model for user's nutrition goals
class NutritionGoals {
  /// Daily calorie target
  final int calorieGoal;

  /// Protein percentage of total calories
  final int proteinPercentage;

  /// Carbohydrate percentage of total calories
  final int carbsPercentage;

  /// Fat percentage of total calories
  final int fatPercentage;

  /// Creates a new NutritionGoals instance
  const NutritionGoals({
    required this.calorieGoal,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  });

  /// Creates a default NutritionGoals object with standard values
  factory NutritionGoals.defaultValues() {
    return const NutritionGoals(
      calorieGoal: 2000,
      proteinPercentage: 30,
      carbsPercentage: 40,
      fatPercentage: 30,
    );
  }

  /// Creates a custom NutritionGoals based on daily calorie needs (TDEE)
  /// and a specified goal type
  factory NutritionGoals.fromTDEE(double tdee, GoalType goalType) {
    // Adjust calories based on goal
    int calorieGoal = tdee.round();

    switch (goalType) {
      case GoalType.loseWeight:
        calorieGoal = (tdee * 0.8).round(); // 20% deficit
        break;
      case GoalType.maintainWeight:
        // Keep TDEE as is
        break;
      case GoalType.gainWeight:
        calorieGoal = (tdee * 1.1).round(); // 10% surplus
        break;
    }

    // Adjust macros based on goal
    int proteinPercentage;
    int carbsPercentage;
    int fatPercentage;

    switch (goalType) {
      case GoalType.loseWeight:
        proteinPercentage = 40; // Higher protein for preserving muscle
        carbsPercentage = 30;
        fatPercentage = 30;
        break;
      case GoalType.maintainWeight:
        proteinPercentage = 30;
        carbsPercentage = 40;
        fatPercentage = 30;
        break;
      case GoalType.gainWeight:
        proteinPercentage = 30;
        carbsPercentage = 45; // Higher carbs for energy and muscle gain
        fatPercentage = 25;
        break;
    }

    return NutritionGoals(
      calorieGoal: calorieGoal,
      proteinPercentage: proteinPercentage,
      carbsPercentage: carbsPercentage,
      fatPercentage: fatPercentage,
    );
  }

  /// Convert to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'calorieGoal': calorieGoal,
      'proteinPercentage': proteinPercentage,
      'carbsPercentage': carbsPercentage,
      'fatPercentage': fatPercentage,
    };
  }

  /// Create from a JSON map
  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calorieGoal: json['calorieGoal'] as int,
      proteinPercentage: json['proteinPercentage'] as int,
      carbsPercentage: json['carbsPercentage'] as int,
      fatPercentage: json['fatPercentage'] as int,
    );
  }

  /// Check if macronutrient percentages sum to 100%
  bool validateMacros() {
    return proteinPercentage + carbsPercentage + fatPercentage == 100;
  }

  /// Calculate grams of protein based on calorie goal and protein percentage
  double get proteinGrams {
    // 4 calories per gram of protein
    return (calorieGoal * (proteinPercentage / 100)) / 4;
  }

  /// Calculate grams of carbs based on calorie goal and carbs percentage
  double get carbsGrams {
    // 4 calories per gram of carbs
    return (calorieGoal * (carbsPercentage / 100)) / 4;
  }

  /// Calculate grams of fat based on calorie goal and fat percentage
  double get fatGrams {
    // 9 calories per gram of fat
    return (calorieGoal * (fatPercentage / 100)) / 9;
  }

  /// Create a copy with updated values
  NutritionGoals copyWith({
    int? calorieGoal,
    int? proteinPercentage,
    int? carbsPercentage,
    int? fatPercentage,
  }) {
    return NutritionGoals(
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      carbsPercentage: carbsPercentage ?? this.carbsPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
    );
  }

  /// Save nutrition goals to shared preferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_goals', jsonEncode(toJson()));
  }

  /// Load nutrition goals from shared preferences
  static Future<NutritionGoals> load() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString('nutrition_goals');

    if (goalsJson != null) {
      return NutritionGoals.fromJson(jsonDecode(goalsJson));
    }

    return NutritionGoals.defaultValues();
  }
}

/// Enum for different weight goals
enum GoalType {
  /// Goal to lose weight (calorie deficit)
  loseWeight,

  /// Goal to maintain current weight
  maintainWeight,

  /// Goal to gain weight (calorie surplus)
  gainWeight,
}
