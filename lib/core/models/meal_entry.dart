import 'dart:convert';
import 'package:intl/intl.dart';

/// Represents a single meal/food entry in the nutrition log
class MealEntry {
  /// Unique identifier for this entry
  final String id;

  /// User ID this entry belongs to
  final String userId;

  /// Date and time of the meal
  final DateTime dateTime;

  /// ID for the food item (for lookup in database)
  final String? foodItemId;

  /// Name of the food consumed
  final String foodName;

  /// Amount consumed in grams
  final double amount;

  /// Calories per serving
  final double calories;

  /// Protein content in grams
  final double protein;

  /// Carbohydrate content in grams
  final double carbs;

  /// Fat content in grams
  final double fat;

  /// Type of meal (breakfast, lunch, dinner, snack, etc.)
  final String mealType;

  /// Optional notes about this meal
  final String? notes;

  /// Whether this entry is a favorite
  final bool isFavorite;

  /// Creates a new [MealEntry] instance
  const MealEntry({
    required this.id,
    required this.userId,
    required this.dateTime,
    this.foodItemId,
    required this.foodName,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    this.notes,
    this.isFavorite = false,
  });

  /// Gets the date string in format yyyy-MM-dd for grouping
  String get dateString => DateFormat('yyyy-MM-dd').format(dateTime);

  /// Gets the time string in 12-hour format
  String get timeString => DateFormat('h:mm a').format(dateTime);

  /// Creates a copy of this [MealEntry] with the given values
  MealEntry copyWith({
    String? id,
    String? userId,
    DateTime? dateTime,
    String? foodItemId,
    String? foodName,
    double? amount,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? mealType,
    String? notes,
    bool? isFavorite,
  }) {
    return MealEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      amount: amount ?? this.amount,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      mealType: mealType ?? this.mealType,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Converts the [MealEntry] to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'amount': amount,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'notes': notes,
      'isFavorite': isFavorite,
    };
  }

  /// Creates a [MealEntry] from a map
  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      foodItemId: map['foodItemId'],
      foodName: map['foodName'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      calories: map['calories']?.toDouble() ?? 0.0,
      protein: map['protein']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      fat: map['fat']?.toDouble() ?? 0.0,
      mealType: map['mealType'] ?? 'Snack',
      notes: map['notes'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  /// Converts the [MealEntry] to a JSON string
  String toJson() => json.encode(toMap());

  /// Creates a [MealEntry] from a JSON string
  factory MealEntry.fromJson(String source) =>
      MealEntry.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MealEntry(id: $id, foodName: $foodName, calories: $calories)';
  }
}

/// Available meal types in the application
class MealTypes {
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String snack = 'Snack';

  /// Returns a list of all meal types
  static List<String> get all => [breakfast, lunch, dinner, snack];
}
