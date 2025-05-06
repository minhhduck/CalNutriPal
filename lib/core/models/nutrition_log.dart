import 'package:uuid/uuid.dart';

/// Represents a meal type
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

/// Represents a nutrition log entry for a specific meal
class NutritionLogEntry {
  final String id;
  final String foodItemId;
  final String foodName;
  final double amount;
  final String unit;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final MealType mealType;
  final DateTime loggedAt;

  /// Creates a new [NutritionLogEntry] with the given parameters
  const NutritionLogEntry({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.mealType,
    required this.loggedAt,
  });

  /// Creates a new [NutritionLogEntry] with a random UUID
  factory NutritionLogEntry.create({
    required String foodItemId,
    required String foodName,
    required double amount,
    required String unit,
    required double calories,
    required double proteins,
    required double carbs,
    required double fats,
    required MealType mealType,
  }) {
    return NutritionLogEntry(
      id: const Uuid().v4(),
      foodItemId: foodItemId,
      foodName: foodName,
      amount: amount,
      unit: unit,
      calories: calories,
      proteins: proteins,
      carbs: carbs,
      fats: fats,
      mealType: mealType,
      loggedAt: DateTime.now(),
    );
  }

  /// Converts the [NutritionLogEntry] to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodItemId': foodItemId,
      'foodName': foodName,
      'amount': amount,
      'unit': unit,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType.index,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  /// Creates a [NutritionLogEntry] from a map
  factory NutritionLogEntry.fromMap(Map<String, dynamic> map) {
    return NutritionLogEntry(
      id: map['id'],
      foodItemId: map['foodItemId'],
      foodName: map['foodName'],
      amount: map['amount'],
      unit: map['unit'],
      calories: map['calories'],
      proteins: map['proteins'],
      carbs: map['carbs'],
      fats: map['fats'],
      mealType: MealType.values[map['mealType']],
      loggedAt: DateTime.parse(map['loggedAt']),
    );
  }
}

/// Represents a daily nutrition log containing all meals for a specific day
class DailyNutritionLog {
  final String id;
  final DateTime date;
  final List<NutritionLogEntry> entries;
  final double? waterIntake; // in milliliters
  final int? steps;

  /// Creates a new [DailyNutritionLog] with the given parameters
  DailyNutritionLog({
    required this.id,
    required this.date,
    required this.entries,
    this.waterIntake,
    this.steps,
  });

  /// Creates a new [DailyNutritionLog] with a random UUID
  factory DailyNutritionLog.create({
    required DateTime date,
    List<NutritionLogEntry> entries = const [],
    double? waterIntake,
    int? steps,
  }) {
    return DailyNutritionLog(
      id: const Uuid().v4(),
      date: DateTime(date.year, date.month, date.day),
      entries: entries,
      waterIntake: waterIntake,
      steps: steps,
    );
  }

  /// Creates a [DailyNutritionLog] for today
  factory DailyNutritionLog.today() {
    final now = DateTime.now();
    return DailyNutritionLog.create(
      date: DateTime(now.year, now.month, now.day),
    );
  }

  /// Gets all entries for a specific meal type
  List<NutritionLogEntry> getEntriesByMealType(MealType mealType) {
    return entries.where((entry) => entry.mealType == mealType).toList();
  }

  /// Gets total calories for the day
  double get totalCalories {
    return entries.fold(0, (sum, entry) => sum + entry.calories);
  }

  /// Gets total proteins for the day
  double get totalProteins {
    return entries.fold(0, (sum, entry) => sum + entry.proteins);
  }

  /// Gets total carbs for the day
  double get totalCarbs {
    return entries.fold(0, (sum, entry) => sum + entry.carbs);
  }

  /// Gets total fats for the day
  double get totalFats {
    return entries.fold(0, (sum, entry) => sum + entry.fats);
  }

  /// Creates a copy of this [DailyNutritionLog] with the given parameters
  DailyNutritionLog copyWith({
    List<NutritionLogEntry>? entries,
    double? waterIntake,
    int? steps,
  }) {
    return DailyNutritionLog(
      id: id,
      date: date,
      entries: entries ?? this.entries,
      waterIntake: waterIntake ?? this.waterIntake,
      steps: steps ?? this.steps,
    );
  }

  /// Adds a new entry to the log
  DailyNutritionLog addEntry(NutritionLogEntry entry) {
    return copyWith(entries: [...entries, entry]);
  }

  /// Removes an entry from the log by ID
  DailyNutritionLog removeEntry(String entryId) {
    return copyWith(
      entries: entries.where((entry) => entry.id != entryId).toList(),
    );
  }

  /// Converts the [DailyNutritionLog] to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'waterIntake': waterIntake,
      'steps': steps,
    };
  }

  /// Creates a [DailyNutritionLog] from a map and entries
  factory DailyNutritionLog.fromMap(
    Map<String, dynamic> map,
    List<NutritionLogEntry> entries,
  ) {
    return DailyNutritionLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      entries: entries,
      waterIntake: map['waterIntake'],
      steps: map['steps'],
    );
  }
}
