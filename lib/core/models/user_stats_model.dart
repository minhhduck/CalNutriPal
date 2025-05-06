import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for gender selection
enum Gender {
  /// Male gender
  male,

  /// Female gender
  female,

  /// Other gender
  other,
}

/// Enum for activity level
enum ActivityLevel {
  /// Sedentary (little or no exercise)
  sedentary,

  /// Light (exercise 1-3 times/week)
  light,

  /// Moderate (exercise 3-5 times/week)
  moderate,

  /// Active (exercise 6-7 times/week)
  active,

  /// Very active (hard exercise 6-7 times/week)
  veryActive,
}

/// Model for user's physical statistics
class UserStats {
  /// User's height in centimeters
  final double heightCm;

  /// User's weight in kilograms
  final double weightKg;

  /// User's age in years
  final int age;

  /// User's gender
  final Gender gender;

  /// User's activity level
  final ActivityLevel activityLevel;

  /// Creates a new [UserStats] instance
  const UserStats({
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    required this.activityLevel,
  });

  /// Creates a [UserStats] instance with default values
  factory UserStats.defaultValues() {
    return const UserStats(
      heightCm: 170.0,
      weightKg: 70.0,
      age: 30,
      gender: Gender.other,
      activityLevel: ActivityLevel.moderate,
    );
  }

  /// Convert height from centimeters to feet and inches
  Map<String, double> getHeightInFeetAndInches() {
    final totalInches = heightCm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return {'feet': feet.toDouble(), 'inches': inches};
  }

  /// Convert weight from kilograms to pounds
  double getWeightInPounds() {
    return weightKg * 2.20462;
  }

  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  double calculateBMR() {
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  double calculateTDEE() {
    final bmr = calculateBMR();
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2;
      case ActivityLevel.light:
        return bmr * 1.375;
      case ActivityLevel.moderate:
        return bmr * 1.55;
      case ActivityLevel.active:
        return bmr * 1.725;
      case ActivityLevel.veryActive:
        return bmr * 1.9;
    }
  }

  /// Convert [UserStats] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'gender': gender.toString().split('.').last,
      'activityLevel': activityLevel.toString().split('.').last,
    };
  }

  /// Create a [UserStats] from a JSON map
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      heightCm: json['heightCm'] as double,
      weightKg: json['weightKg'] as double,
      age: json['age'] as int,
      gender: Gender.values.firstWhere(
          (e) => e.toString().split('.').last == json['gender'],
          orElse: () => Gender.other),
      activityLevel: ActivityLevel.values.firstWhere(
          (e) => e.toString().split('.').last == json['activityLevel'],
          orElse: () => ActivityLevel.moderate),
    );
  }

  /// Create a copy of [UserStats] with optional new values
  UserStats copyWith({
    double? heightCm,
    double? weightKg,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
  }) {
    return UserStats(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  /// Save [UserStats] to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_stats', jsonEncode(toJson()));
  }

  /// Load [UserStats] from SharedPreferences
  static Future<UserStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('user_stats');

    if (statsJson != null) {
      return UserStats.fromJson(jsonDecode(statsJson));
    }

    return UserStats.defaultValues();
  }
}
