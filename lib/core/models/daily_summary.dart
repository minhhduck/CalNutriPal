import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cal_nutri_pal/core/models/meal_entry.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals.dart';

/// Represents a daily summary of nutrition data
class DailySummary {
  /// Date for this summary (yyyy-MM-dd)
  final String date;

  /// User ID this summary belongs to
  final String userId;

  /// Total calories consumed
  final double totalCalories;

  /// Total protein consumed in grams
  final double totalProtein;

  /// Total carbs consumed in grams
  final double totalCarbs;

  /// Total fat consumed in grams
  final double totalFat;

  /// Water intake in ml
  final double waterIntake;

  /// Number of meals logged this day
  final int mealCount;

  /// Meal entries for this day by meal type
  final Map<String, List<MealEntry>> mealsByType;

  /// Creates a new [DailySummary] instance
  const DailySummary({
    required this.date,
    required this.userId,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.waterIntake = 0,
    required this.mealCount,
    required this.mealsByType,
  });

  /// Creates an empty [DailySummary] for a specific date
  factory DailySummary.empty({
    required String date,
    required String userId,
  }) {
    return DailySummary(
      date: date,
      userId: userId,
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
      waterIntake: 0,
      mealCount: 0,
      mealsByType: {},
    );
  }

  /// Creates a [DailySummary] from a list of meal entries
  factory DailySummary.fromMealEntries({
    required String date,
    required String userId,
    required List<MealEntry> entries,
    double waterIntake = 0,
  }) {
    // Group entries by meal type
    final Map<String, List<MealEntry>> mealsByType = {};

    for (final entry in entries) {
      if (!mealsByType.containsKey(entry.mealType)) {
        mealsByType[entry.mealType] = [];
      }
      mealsByType[entry.mealType]!.add(entry);
    }

    // Calculate totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalCarbs += entry.carbs;
      totalFat += entry.fat;
    }

    return DailySummary(
      date: date,
      userId: userId,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      waterIntake: waterIntake,
      mealCount: entries.length,
      mealsByType: mealsByType,
    );
  }

  /// Gets the date as a DateTime object
  DateTime get dateTime => DateFormat('yyyy-MM-dd').parse(date);

  /// Gets the date in a readable format
  String get formattedDate => DateFormat.yMMMd().format(dateTime);

  /// Gets the percentage of protein from total calories
  double get proteinPercentage =>
      totalCalories > 0 ? (totalProtein * 4 / totalCalories) * 100 : 0;

  /// Gets the percentage of carbs from total calories
  double get carbsPercentage =>
      totalCalories > 0 ? (totalCarbs * 4 / totalCalories) * 100 : 0;

  /// Gets the percentage of fat from total calories
  double get fatPercentage =>
      totalCalories > 0 ? (totalFat * 9 / totalCalories) * 100 : 0;

  /// Gets breakfast entries
  List<MealEntry> get breakfastEntries =>
      mealsByType[MealTypes.breakfast] ?? [];

  /// Gets lunch entries
  List<MealEntry> get lunchEntries => mealsByType[MealTypes.lunch] ?? [];

  /// Gets dinner entries
  List<MealEntry> get dinnerEntries => mealsByType[MealTypes.dinner] ?? [];

  /// Gets snack entries
  List<MealEntry> get snackEntries => mealsByType[MealTypes.snack] ?? [];

  /// Gets all entries as a flat list
  List<MealEntry> get allEntries =>
      mealsByType.values.expand((entries) => entries).toList();

  /// Calculates if goals were met based on nutrition goals
  Map<String, bool> goalsMet(NutritionGoals goals) {
    return {
      'calories': totalCalories <= goals.calorieTarget,
      'protein': totalProtein >= goals.proteinGrams,
      'carbs': totalCarbs <= goals.carbsGrams,
      'fat': totalFat <= goals.fatGrams,
    };
  }

  /// Creates a copy of this [DailySummary] with the given values
  DailySummary copyWith({
    String? date,
    String? userId,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? waterIntake,
    int? mealCount,
    Map<String, List<MealEntry>>? mealsByType,
  }) {
    return DailySummary(
      date: date ?? this.date,
      userId: userId ?? this.userId,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      waterIntake: waterIntake ?? this.waterIntake,
      mealCount: mealCount ?? this.mealCount,
      mealsByType: mealsByType ?? this.mealsByType,
    );
  }

  /// Converts the [DailySummary] to a map (excludes meal entries for storage)
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'userId': userId,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'waterIntake': waterIntake,
      'mealCount': mealCount,
    };
  }

  /// Creates a [DailySummary] from a map (without meal entries)
  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      date: map['date'] ?? '',
      userId: map['userId'] ?? '',
      totalCalories: map['totalCalories']?.toDouble() ?? 0.0,
      totalProtein: map['totalProtein']?.toDouble() ?? 0.0,
      totalCarbs: map['totalCarbs']?.toDouble() ?? 0.0,
      totalFat: map['totalFat']?.toDouble() ?? 0.0,
      waterIntake: map['waterIntake']?.toDouble() ?? 0.0,
      mealCount: map['mealCount'] ?? 0,
      mealsByType: {},
    );
  }

  /// Converts the [DailySummary] to a JSON string
  String toJson() => json.encode(toMap());

  /// Creates a [DailySummary] from a JSON string
  factory DailySummary.fromJson(String source) =>
      DailySummary.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DailySummary(date: $date, totalCalories: $totalCalories)';
  }
}
