import 'package:flutter/foundation.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:cal_nutri_pal/core/models/food_item.dart';
import 'package:cal_nutri_pal/core/services/database_helper.dart';

/// Provider that manages nutrition log entries
class NutritionLogProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Current daily log
  DailyNutritionLog? _currentDailyLog;

  // Loading state
  bool _isLoading = false;

  // Error message if any
  String? _errorMessage;

  // Get current daily log (creates one for today if null)
  DailyNutritionLog get currentDailyLog =>
      _currentDailyLog ?? DailyNutritionLog.today();

  // Get loading state
  bool get isLoading => _isLoading;

  // Get error message
  String? get errorMessage => _errorMessage;

  // Get entries for breakfast
  List<NutritionLogEntry> get breakfastEntries =>
      currentDailyLog.getEntriesByMealType(MealType.breakfast);

  // Get entries for lunch
  List<NutritionLogEntry> get lunchEntries =>
      currentDailyLog.getEntriesByMealType(MealType.lunch);

  // Get entries for dinner
  List<NutritionLogEntry> get dinnerEntries =>
      currentDailyLog.getEntriesByMealType(MealType.dinner);

  // Get entries for snacks
  List<NutritionLogEntry> get snackEntries =>
      currentDailyLog.getEntriesByMealType(MealType.snack);

  // Initialize the provider and load today's log
  Future<void> initialize() async {
    await loadLogForDate(DateTime.now());
  }

  // Load log for a specific date
  Future<void> loadLogForDate(DateTime date) async {
    _setLoading(true);
    try {
      // Normalize date to start of day
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Try to load from database
      final dailyLog = await _databaseHelper.getDailyLogByDate(normalizedDate);

      // If log exists, use it; otherwise create a new one
      _currentDailyLog =
          dailyLog ?? DailyNutritionLog.create(date: normalizedDate);

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load nutrition log: ${e.toString()}');
    }
  }

  // Add a new entry to the current log
  Future<void> addEntry(NutritionLogEntry entry) async {
    _setLoading(true);
    try {
      // Add entry to current log
      final updatedLog = currentDailyLog.addEntry(entry);
      _currentDailyLog = updatedLog;

      // Save to database
      await _databaseHelper.saveDailyLog(updatedLog);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add nutrition entry: ${e.toString()}');
    }
  }

  // Update water intake for the current log
  Future<void> updateWaterIntake(double waterIntake) async {
    _setLoading(true);
    try {
      // Update water intake in current log
      final updatedLog = currentDailyLog.copyWith(waterIntake: waterIntake);
      _currentDailyLog = updatedLog;

      // Save to database
      await _databaseHelper.saveDailyLog(updatedLog);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update water intake: ${e.toString()}');
    }
  }

  // Update steps for the current log
  Future<void> updateSteps(int steps) async {
    _setLoading(true);
    try {
      // Update steps in current log
      final updatedLog = currentDailyLog.copyWith(steps: steps);
      _currentDailyLog = updatedLog;

      // Save to database
      await _databaseHelper.saveDailyLog(updatedLog);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update steps: ${e.toString()}');
    }
  }

  // Remove an entry from the current log
  Future<void> removeEntry(String entryId) async {
    _setLoading(true);
    try {
      // Remove entry from current log
      final updatedLog = currentDailyLog.removeEntry(entryId);
      _currentDailyLog = updatedLog;

      // Update database
      await _databaseHelper.deleteNutritionLogEntry(entryId);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove entry: ${e.toString()}');
    }
  }

  // Update an existing entry
  Future<void> updateEntry(NutritionLogEntry updatedEntry) async {
    _setLoading(true);
    try {
      // First remove the old entry
      final logWithoutOldEntry = currentDailyLog.removeEntry(updatedEntry.id);

      // Then add the updated entry
      final updatedLog = logWithoutOldEntry.addEntry(updatedEntry);
      _currentDailyLog = updatedLog;

      // Update in database
      await _databaseHelper.updateNutritionLogEntry(updatedEntry);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update entry: ${e.toString()}');
    }
  }

  // Get logs in a date range (for reports)
  Future<List<DailyNutritionLog>> getLogsInRange(
      DateTime startDate, DateTime endDate) async {
    _setLoading(true);
    try {
      final logs = await _databaseHelper.getLogsInDateRange(startDate, endDate);
      _setLoading(false);
      return logs;
    } catch (e) {
      _setError('Failed to load logs in range: ${e.toString()}');
      return [];
    }
  }

  // Add or update a food item in the database
  Future<void> saveFoodItem(FoodItem foodItem) async {
    try {
      await _databaseHelper.insertFoodItem(foodItem);
    } catch (e) {
      _setError('Failed to save food item: ${e.toString()}');
    }
  }

  /// Logs a specific amount of water for a given date.
  Future<void> logWater(double amountMl, DateTime date) async {
    _setLoading(true);
    try {
      // 1. Get the special 'Water' food item
      final waterItem = await _databaseHelper.getOrCreateWaterFoodItem();

      // 2. Normalize the date
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // 3. Get the existing log or create a new one
      final existingLog =
          await _databaseHelper.getDailyLogByDate(normalizedDate);
      final logToUpdate =
          existingLog ?? DailyNutritionLog.create(date: normalizedDate);

      // 4. Create the water log entry
      final waterEntry = NutritionLogEntry.create(
        foodItemId: waterItem.id,
        foodName: waterItem.name,
        amount: amountMl,
        unit: waterItem.servingUnit, // Use unit from FoodItem ('ml')
        calories: 0,
        proteins: 0,
        carbs: 0,
        fats: 0,
        mealType:
            MealType.snack, // Log water under snacks, or create MealType.water
      );

      // 5. Add the entry to the log
      final logWithEntry = logToUpdate.addEntry(waterEntry);

      // 6. Update the total water intake for the day
      final newTotalWater = (logToUpdate.waterIntake ?? 0) + amountMl;
      final updatedLog = logWithEntry.copyWith(waterIntake: newTotalWater);

      // 6. Save the updated log to the database
      await _databaseHelper.saveDailyLog(updatedLog);

      // 7. Update the provider state if it's the currently viewed date
      if (_currentDailyLog != null &&
          _currentDailyLog!.date.year == normalizedDate.year &&
          _currentDailyLog!.date.month == normalizedDate.month &&
          _currentDailyLog!.date.day == normalizedDate.day) {
        _currentDailyLog = updatedLog;
      }

      _setLoading(false); // Also calls notifyListeners()
    } catch (e) {
      _setError('Failed to log water: ${e.toString()}');
    }
  }

  // Search food items by name
  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      return await _databaseHelper.searchFoodItems(query);
    } catch (e) {
      _setError('Failed to search food items: ${e.toString()}');
      return [];
    }
  }

  // Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  // Set error message and notify listeners
  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}
