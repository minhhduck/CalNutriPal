import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals.dart';

/// Represents a user of the app
class User {
  /// Unique identifier for the user
  final String id;

  /// User's display name
  final String name;

  /// User's email address
  final String email;

  /// URL to user's profile picture
  final String? avatarUrl;

  /// User's height in cm
  final double height;

  /// User's weight in kg
  final double weight;

  /// User's age
  final int age;

  /// User's activity level from 1 (sedentary) to 5 (very active)
  final int activityLevel;

  /// Whether user prefers dark mode UI
  final bool isDarkMode;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// User's preferred unit system ('Metric' or 'Imperial')
  final String unitSystem;

  /// User's nutrition goals
  final NutritionGoals? nutritionGoals;

  /// Creates a new [User] instance
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.height,
    required this.weight,
    required this.age,
    required this.activityLevel,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.unitSystem,
    this.nutritionGoals,
  });

  /// Creates a default user instance
  factory User.defaultUser() {
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'New User',
      email: 'user@example.com',
      height: 170.0,
      weight: 70.0,
      age: 30,
      activityLevel: 2,
      isDarkMode: false,
      notificationsEnabled: true,
      unitSystem: 'Metric',
      nutritionGoals: null,
    );
  }

  /// Gets the calculated BMI value
  double get bmi => weight / ((height / 100) * (height / 100));

  /// Gets the BMI category as string
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Creates a copy of this [User] with the given values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    double? height,
    double? weight,
    int? age,
    int? activityLevel,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? unitSystem,
    NutritionGoals? nutritionGoals,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      unitSystem: unitSystem ?? this.unitSystem,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
    );
  }

  /// Converts the [User] to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'height': height,
      'weight': weight,
      'age': age,
      'activityLevel': activityLevel,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'unitSystem': unitSystem,
      'nutritionGoals': nutritionGoals?.toMap(),
    };
  }

  /// Creates a [User] from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? 'New User',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'],
      height: map['height']?.toDouble() ?? 170.0,
      weight: map['weight']?.toDouble() ?? 70.0,
      age: map['age'] ?? 30,
      activityLevel: map['activityLevel'] ?? 2,
      isDarkMode: map['isDarkMode'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      unitSystem: map['unitSystem'] ?? 'Metric',
      nutritionGoals: map['nutritionGoals'] != null
          ? NutritionGoals.fromMap(map['nutritionGoals'])
          : null,
    );
  }

  /// Converts the [User] to a JSON string
  String toJson() => json.encode(toMap());

  /// Creates a [User] from a JSON string
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  /// Saves the user data to local storage
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', toJson());
  }

  /// Clears all user data from local storage
  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  /// Loads user data from local storage
  static Future<User> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      try {
        return User.fromJson(userJson);
      } catch (e) {
        return User.defaultUser();
      }
    }

    return User.defaultUser();
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}
