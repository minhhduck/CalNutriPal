import 'package:flutter/foundation.dart';
import 'package:cal_nutri_pal/core/models/user.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals.dart';

/// Provider that manages the current user state
class UserProvider extends ChangeNotifier {
  /// Current user instance
  User? _user;

  /// Loading state
  bool _isLoading = false;

  /// Error message if any
  String? _errorMessage;

  /// Get the current user
  User get user => _user ?? User.defaultUser();

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get nutrition goals
  NutritionGoals get nutritionGoals =>
      user.nutritionGoals ?? NutritionGoals.recommended();

  /// Initialize the provider and load user data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final loadedUser = await User.load();
      _user = loadedUser;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load user data: ${e.toString()}');
    }
  }

  /// Update user with new values
  Future<void> updateUser(User updatedUser) async {
    _setLoading(true);
    try {
      _user = updatedUser;
      await updatedUser.save();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update user: ${e.toString()}');
    }
  }

  /// Update specific user fields
  Future<void> updateUserFields({
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
  }) async {
    final updatedUser = user.copyWith(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      height: height,
      weight: weight,
      age: age,
      activityLevel: activityLevel,
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      unitSystem: unitSystem,
      nutritionGoals: nutritionGoals,
    );

    await updateUser(updatedUser);
  }

  /// Update the nutrition goals
  Future<void> updateNutritionGoals(NutritionGoals goals) async {
    await updateUserFields(nutritionGoals: goals);
  }

  /// Toggle dark mode setting
  Future<void> toggleDarkMode() async {
    await updateUserFields(isDarkMode: !user.isDarkMode);
  }

  /// Toggle notifications setting
  Future<void> toggleNotifications() async {
    await updateUserFields(notificationsEnabled: !user.notificationsEnabled);
  }

  /// Clear stored user data (logout)
  Future<void> clearUserData() async {
    _setLoading(true);
    try {
      _user = User.defaultUser();
      // Clear stored data
      await user.clearStorage();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear user data: ${e.toString()}');
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}
