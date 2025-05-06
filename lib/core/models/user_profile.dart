/// Gender enumeration for user profile
enum Gender {
  male,
  female,
  other,
}

/// Activity level enumeration for user profile
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive,
}

/// Represents a user profile with personal information and nutrition goals
class UserProfile {
  final String? id;
  final String? name;
  final int? age;
  final double? height; // in centimeters
  final double? weight; // in kilograms
  final Gender? gender;
  final ActivityLevel activityLevel;
  final double calorieGoal;
  final double proteinGoal;
  final double carbGoal;
  final double fatGoal;
  final double waterGoal; // in milliliters
  final int stepGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Creates a new [UserProfile] with the given parameters
  UserProfile({
    this.id,
    this.name,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.calorieGoal = 2000,
    this.proteinGoal = 50,
    this.carbGoal = 250,
    this.fatGoal = 70,
    this.waterGoal = 2000,
    this.stepGoal = 10000,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a default [UserProfile] with preset goals
  factory UserProfile.defaultProfile() {
    return UserProfile(
      calorieGoal: 2000,
      proteinGoal: 50,
      carbGoal: 250,
      fatGoal: 70,
      waterGoal: 2000,
      stepGoal: 10000,
    );
  }

  /// Creates a copy of this [UserProfile] with the given parameters
  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    double? height,
    double? weight,
    Gender? gender,
    ActivityLevel? activityLevel,
    double? calorieGoal,
    double? proteinGoal,
    double? carbGoal,
    double? fatGoal,
    double? waterGoal,
    int? stepGoal,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbGoal: carbGoal ?? this.carbGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      stepGoal: stepGoal ?? this.stepGoal,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculates BMI (Body Mass Index) if height and weight are available
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  /// Gets BMI category based on calculated BMI
  String? get bmiCategory {
    final calculatedBmi = bmi;
    if (calculatedBmi == null) return null;

    if (calculatedBmi < 18.5) {
      return 'Underweight';
    } else if (calculatedBmi < 25) {
      return 'Normal';
    } else if (calculatedBmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation
  double? get bmr {
    if (weight == null || height == null || age == null || gender == null) {
      return null;
    }

    if (gender == Gender.male) {
      return (10 * weight!) + (6.25 * height!) - (5 * age!) + 5;
    } else {
      return (10 * weight!) + (6.25 * height!) - (5 * age!) - 161;
    }
  }

  /// Calculates Total Daily Energy Expenditure (TDEE)
  double? get tdee {
    final calculatedBmr = bmr;
    if (calculatedBmr == null) return null;

    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return calculatedBmr * 1.2;
      case ActivityLevel.lightlyActive:
        return calculatedBmr * 1.375;
      case ActivityLevel.moderatelyActive:
        return calculatedBmr * 1.55;
      case ActivityLevel.veryActive:
        return calculatedBmr * 1.725;
      case ActivityLevel.extremelyActive:
        return calculatedBmr * 1.9;
    }
  }

  /// Converts the [UserProfile] to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender?.index,
      'activityLevel': activityLevel.index,
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbGoal': carbGoal,
      'fatGoal': fatGoal,
      'waterGoal': waterGoal,
      'stepGoal': stepGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [UserProfile] from a map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      height: map['height'],
      weight: map['weight'],
      gender: map['gender'] != null ? Gender.values[map['gender']] : null,
      activityLevel: ActivityLevel
          .values[map['activityLevel'] ?? ActivityLevel.moderatelyActive.index],
      calorieGoal: map['calorieGoal'] ?? 2000,
      proteinGoal: map['proteinGoal'] ?? 50,
      carbGoal: map['carbGoal'] ?? 250,
      fatGoal: map['fatGoal'] ?? 70,
      waterGoal: map['waterGoal'] ?? 2000,
      stepGoal: map['stepGoal'] ?? 10000,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }
}
