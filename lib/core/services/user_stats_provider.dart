import 'package:flutter/foundation.dart';
import 'package:cal_nutri_pal/core/models/user_stats_model.dart';

/// Provider class for managing user statistics
class UserStatsProvider extends ChangeNotifier {
  /// Current user stats
  UserStats? _userStats;

  /// Whether the provider is currently loading data
  bool _isLoading = false;

  /// Any error message that occurred during operations
  String? _errorMessage;

  /// Height unit (cm or feet)
  bool _useMetricHeight = true;

  /// Weight unit (kg or lbs)
  bool _useMetricWeight = true;

  /// Get current user stats
  UserStats get userStats => _userStats ?? UserStats.defaultValues();

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get whether to use metric for height (cm vs feet/inches)
  bool get useMetricHeight => _useMetricHeight;

  /// Get whether to use metric for weight (kg vs lbs)
  bool get useMetricWeight => _useMetricWeight;

  /// Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _userStats = await UserStats.load();
    } catch (e) {
      _setError('Failed to load user stats: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle height unit between metric and imperial
  void toggleHeightUnit() {
    _useMetricHeight = !_useMetricHeight;
    notifyListeners();
  }

  /// Toggle weight unit between metric and imperial
  void toggleWeightUnit() {
    _useMetricWeight = !_useMetricWeight;
    notifyListeners();
  }

  /// Update height in centimeters
  Future<void> updateHeightCm(double heightCm) async {
    if (heightCm < 0) {
      _setError('Height cannot be negative');
      return;
    }

    final updatedStats = userStats.copyWith(heightCm: heightCm);
    await _updateUserStats(updatedStats);
  }

  /// Update height in feet and inches
  Future<void> updateHeightFeetInches(double feet, double inches) async {
    if (feet < 0 || inches < 0) {
      _setError('Height cannot be negative');
      return;
    }

    final totalInches = (feet * 12) + inches;
    final heightCm = totalInches * 2.54;

    final updatedStats = userStats.copyWith(heightCm: heightCm);
    await _updateUserStats(updatedStats);
  }

  /// Update weight in kilograms
  Future<void> updateWeightKg(double weightKg) async {
    if (weightKg < 0) {
      _setError('Weight cannot be negative');
      return;
    }

    final updatedStats = userStats.copyWith(weightKg: weightKg);
    await _updateUserStats(updatedStats);
  }

  /// Update weight in pounds
  Future<void> updateWeightLbs(double weightLbs) async {
    if (weightLbs < 0) {
      _setError('Weight cannot be negative');
      return;
    }

    final weightKg = weightLbs / 2.20462;

    final updatedStats = userStats.copyWith(weightKg: weightKg);
    await _updateUserStats(updatedStats);
  }

  /// Update age
  Future<void> updateAge(int age) async {
    if (age < 0 || age > 120) {
      _setError('Please enter a valid age between 0-120');
      return;
    }

    final updatedStats = userStats.copyWith(age: age);
    await _updateUserStats(updatedStats);
  }

  /// Update gender
  Future<void> updateGender(Gender gender) async {
    final updatedStats = userStats.copyWith(gender: gender);
    await _updateUserStats(updatedStats);
  }

  /// Update activity level
  Future<void> updateActivityLevel(ActivityLevel activityLevel) async {
    final updatedStats = userStats.copyWith(activityLevel: activityLevel);
    await _updateUserStats(updatedStats);
  }

  /// Update user stats with completely new values
  Future<void> updateUserStats(UserStats newStats) async {
    await _updateUserStats(newStats);
  }

  /// Helper method to update user stats and save to storage
  Future<void> _updateUserStats(UserStats updatedStats) async {
    _setLoading(true);
    try {
      _userStats = updatedStats;
      await updatedStats.save();
      _clearError();
    } catch (e) {
      _setError('Failed to save user stats: ${e.toString()}');
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
