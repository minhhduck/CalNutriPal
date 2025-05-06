import 'package:shared_preferences/shared_preferences.dart';

/// Represents user's nutrition goals
class NutritionGoals {
  /// Daily calorie target
  final int calorieTarget;

  /// Protein percentage target (0-100)
  final int proteinPercentage;

  /// Carbohydrates percentage target (0-100)
  final int carbsPercentage;

  /// Fat percentage target (0-100)
  final int fatPercentage;

  /// Creates a new [NutritionGoals] instance
  const NutritionGoals({
    required this.calorieTarget,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  });

  /// Creates a [NutritionGoals] with default values
  factory NutritionGoals.defaultGoals() {
    return const NutritionGoals(
      calorieTarget: 2000,
      proteinPercentage: 30,
      carbsPercentage: 40,
      fatPercentage: 30,
    );
  }

  /// Creates recommended [NutritionGoals] based on general guidelines
  factory NutritionGoals.recommended() {
    return const NutritionGoals(
      calorieTarget: 2000,
      proteinPercentage: 30,
      carbsPercentage: 40,
      fatPercentage: 30,
    );
  }

  /// Validates whether the macronutrient percentages add up to 100%
  bool get isValid =>
      proteinPercentage + carbsPercentage + fatPercentage == 100;

  /// Converts protein percentage to grams based on calorie target
  double get proteinGrams => (calorieTarget * proteinPercentage / 100) / 4;

  /// Converts carbs percentage to grams based on calorie target
  double get carbsGrams => (calorieTarget * carbsPercentage / 100) / 4;

  /// Converts fat percentage to grams based on calorie target
  double get fatGrams => (calorieTarget * fatPercentage / 100) / 9;

  /// Creates a copy of this [NutritionGoals] with the given values
  NutritionGoals copyWith({
    int? calorieTarget,
    int? proteinPercentage,
    int? carbsPercentage,
    int? fatPercentage,
  }) {
    return NutritionGoals(
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      carbsPercentage: carbsPercentage ?? this.carbsPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
    );
  }

  /// Converts the [NutritionGoals] to a map
  Map<String, dynamic> toMap() {
    return {
      'calorieTarget': calorieTarget,
      'proteinPercentage': proteinPercentage,
      'carbsPercentage': carbsPercentage,
      'fatPercentage': fatPercentage,
    };
  }

  /// Creates a [NutritionGoals] from a map
  factory NutritionGoals.fromMap(Map<String, dynamic> map) {
    return NutritionGoals(
      calorieTarget: map['calorieTarget'] ?? 2000,
      proteinPercentage: map['proteinPercentage'] ?? 30,
      carbsPercentage: map['carbsPercentage'] ?? 40,
      fatPercentage: map['fatPercentage'] ?? 30,
    );
  }

  /// Saves the goals to local storage
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calorieTarget', calorieTarget);
    await prefs.setInt('proteinPercentage', proteinPercentage);
    await prefs.setInt('carbsPercentage', carbsPercentage);
    await prefs.setInt('fatPercentage', fatPercentage);
  }

  /// Loads goals from local storage
  static Future<NutritionGoals> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NutritionGoals(
      calorieTarget: prefs.getInt('calorieTarget') ?? 2000,
      proteinPercentage: prefs.getInt('proteinPercentage') ?? 30,
      carbsPercentage: prefs.getInt('carbsPercentage') ?? 40,
      fatPercentage: prefs.getInt('fatPercentage') ?? 30,
    );
  }
}
