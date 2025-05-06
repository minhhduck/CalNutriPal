import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:cal_nutri_pal/core/models/food_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';

/// Database helper class for Cal Nutri Pal app
/// Handles SQLite operations for nutrition logs and food items
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Tables
  static const String foodItemsTable = 'food_items';
  static const String nutritionLogTable = 'nutrition_log';
  static const String dailyLogTable = 'daily_logs';

  // Singleton pattern
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database, create tables if they don't exist
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'cal_nutri_pal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create food items table
    await db.execute('''
      CREATE TABLE $foodItemsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        carbs REAL NOT NULL,
        fats REAL NOT NULL,
        servingSize REAL NOT NULL,
        servingUnit TEXT NOT NULL,
        imageUrl TEXT,
        barcode TEXT,
        isFavorite INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create nutrition log entries table
    await db.execute('''
      CREATE TABLE $nutritionLogTable (
        id TEXT PRIMARY KEY,
        foodItemId TEXT NOT NULL,
        foodName TEXT NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        carbs REAL NOT NULL,
        fats REAL NOT NULL,
        mealType INTEGER NOT NULL,
        loggedAt TEXT NOT NULL,
        dailyLogId TEXT NOT NULL,
        FOREIGN KEY (dailyLogId) REFERENCES $dailyLogTable(id)
      )
    ''');

    // Create daily logs table
    await db.execute('''
      CREATE TABLE $dailyLogTable (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        waterIntake REAL,
        steps INTEGER
      )
    ''');
  }

  // ------------ Food Item Operations ------------

  /// Insert a new food item
  Future<void> insertFoodItem(FoodItem foodItem) async {
    final db = await database;
    await db.insert(
      foodItemsTable,
      foodItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all food items
  Future<List<FoodItem>> getFoodItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(foodItemsTable);
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  /// Get food item by id
  Future<FoodItem?> getFoodItem(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      foodItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FoodItem.fromMap(maps.first);
    }
    return null;
  }

  /// Search food items by name
  Future<List<FoodItem>> searchFoodItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      foodItemsTable,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  /// Update food item
  Future<void> updateFoodItem(FoodItem foodItem) async {
    final db = await database;
    await db.update(
      foodItemsTable,
      foodItem.toMap(),
      where: 'id = ?',
      whereArgs: [foodItem.id],
    );
  }

  /// Delete food item
  Future<void> deleteFoodItem(String id) async {
    final db = await database;
    await db.delete(
      foodItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final db = await database;
    final foodItem = await getFoodItem(id);
    if (foodItem != null) {
      final updatedItem = foodItem.copyWith(isFavorite: !foodItem.isFavorite);
      await updateFoodItem(updatedItem);
    }
  }

  // ------------ Nutrition Log Operations ------------

  /// Insert a daily log
  Future<String> insertDailyLog(DailyNutritionLog log) async {
    final db = await database;
    await db.insert(
      dailyLogTable,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return log.id;
  }

  /// Insert a nutrition log entry
  Future<void> insertNutritionLogEntry(
      NutritionLogEntry entry, String dailyLogId) async {
    final db = await database;
    final Map<String, dynamic> entryMap = entry.toMap();
    entryMap['dailyLogId'] = dailyLogId;

    await db.insert(
      nutritionLogTable,
      entryMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get daily log by date
  Future<DailyNutritionLog?> getDailyLogByDate(DateTime date) async {
    final db = await database;

    // Normalize the date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];

    // First find the log record
    final List<Map<String, dynamic>> logMaps = await db.query(
      dailyLogTable,
      where: "date LIKE ?",
      whereArgs: ['$normalizedDate%'],
    );

    if (logMaps.isEmpty) {
      return null;
    }

    // Then get all entries for this log
    final List<Map<String, dynamic>> entryMaps = await db.query(
      nutritionLogTable,
      where: 'dailyLogId = ?',
      whereArgs: [logMaps.first['id']],
    );

    final List<NutritionLogEntry> entries =
        entryMaps.map((map) => NutritionLogEntry.fromMap(map)).toList();

    return DailyNutritionLog.fromMap(logMaps.first, entries);
  }

  /// Save or update a complete daily log with entries
  Future<void> saveDailyLog(DailyNutritionLog log) async {
    final db = await database;
    await db.transaction((txn) async {
      // First insert/update the daily log
      await txn.insert(
        dailyLogTable,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete existing entries for this log
      await txn.delete(
        nutritionLogTable,
        where: 'dailyLogId = ?',
        whereArgs: [log.id],
      );

      // Insert all entries
      for (var entry in log.entries) {
        final Map<String, dynamic> entryMap = entry.toMap();
        entryMap['dailyLogId'] = log.id;

        await txn.insert(
          nutritionLogTable,
          entryMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Get all daily logs
  Future<List<DailyNutritionLog>> getAllDailyLogs() async {
    final db = await database;

    // Get all daily logs
    final List<Map<String, dynamic>> logMaps = await db.query(dailyLogTable);

    // For each log, get its entries
    final List<DailyNutritionLog> logs = [];

    for (var logMap in logMaps) {
      final List<Map<String, dynamic>> entryMaps = await db.query(
        nutritionLogTable,
        where: 'dailyLogId = ?',
        whereArgs: [logMap['id']],
      );

      final List<NutritionLogEntry> entries =
          entryMaps.map((map) => NutritionLogEntry.fromMap(map)).toList();

      logs.add(DailyNutritionLog.fromMap(logMap, entries));
    }

    return logs;
  }

  /// Delete a nutrition log entry
  Future<void> deleteNutritionLogEntry(String entryId) async {
    final db = await database;
    await db.delete(
      nutritionLogTable,
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  /// Update a nutrition log entry
  Future<void> updateNutritionLogEntry(NutritionLogEntry entry) async {
    final db = await database;

    // Get the dailyLogId for this entry
    final List<Map<String, dynamic>> maps = await db.query(
      nutritionLogTable,
      columns: ['dailyLogId'],
      where: 'id = ?',
      whereArgs: [entry.id],
    );

    if (maps.isNotEmpty) {
      final String dailyLogId = maps.first['dailyLogId'];

      // Create a map with the entry data and the dailyLogId
      final Map<String, dynamic> entryMap = entry.toMap();
      entryMap['dailyLogId'] = dailyLogId;

      // Update the entry
      await db.update(
        nutritionLogTable,
        entryMap,
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
  }

  /// Delete a daily log and all its entries
  Future<void> deleteDailyLog(String logId) async {
    final db = await database;
    await db.transaction((txn) async {
      // First delete all entries
      await txn.delete(
        nutritionLogTable,
        where: 'dailyLogId = ?',
        whereArgs: [logId],
      );

      // Then delete the log
      await txn.delete(
        dailyLogTable,
        where: 'id = ?',
        whereArgs: [logId],
      );
    });
  }

  /// Get logs between date range
  Future<List<DailyNutritionLog>> getLogsInDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await database;

    final normalizedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day)
            .toIso8601String();
    final normalizedEndDate =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
            .toIso8601String();

    // Get all daily logs in range
    final List<Map<String, dynamic>> logMaps = await db.query(
      dailyLogTable,
      where: "date BETWEEN ? AND ?",
      whereArgs: [normalizedStartDate, normalizedEndDate],
    );

    // For each log, get its entries
    final List<DailyNutritionLog> logs = [];

    for (var logMap in logMaps) {
      final List<Map<String, dynamic>> entryMaps = await db.query(
        nutritionLogTable,
        where: 'dailyLogId = ?',
        whereArgs: [logMap['id']],
      );

      final List<NutritionLogEntry> entries =
          entryMaps.map((map) => NutritionLogEntry.fromMap(map)).toList();

      logs.add(DailyNutritionLog.fromMap(logMap, entries));
    }

    return logs;
  }

  /// Clears all data from the specified tables.
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(nutritionLogTable); // Clear nutrition entries
      await txn.delete(dailyLogTable); // Clear daily log summaries
      await txn.delete(foodItemsTable); // Clear custom food items
    });
    debugPrint("DatabaseHelper: All tables cleared.");
  }

  /// Retrieves or creates a specific 'Water' food item.
  Future<FoodItem> getOrCreateWaterFoodItem() async {
    final db = await database;
    const waterName = 'Water';
    final List<Map<String, dynamic>> maps = await db.query(
      foodItemsTable,
      where: 'name = ?',
      whereArgs: [waterName],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      // Water item exists
      return FoodItem.fromMap(maps.first);
    } else {
      // Create Water item
      // Assuming FoodItem has these parameters based on table structure
      final String newId = UniqueKey().toString(); // Or use UUID package
      final waterItem = FoodItem(
        id: newId, // Assuming ID is required and should be unique
        name: waterName,
        calories: 0,
        proteins: 0, // Use plural based on table schema
        carbs: 0,
        fats: 0, // Use plural based on table schema
        servingSize: 1, // Default serving size 1
        servingUnit: 'ml', // Default serving unit ml
        imageUrl: null, // Assuming nullable
        isFavorite: false, // Assuming default false
        createdAt: DateTime.now(), // Assuming required
      );
      await insertFoodItem(waterItem); // Use correct insert method

      // Fetch the newly created item to return it with the ID
      final newItemMap = await db.query(
        foodItemsTable,
        where: 'id = ?',
        whereArgs: [newId],
        limit: 1,
      );
      if (newItemMap.isNotEmpty) {
        return FoodItem.fromMap(newItemMap.first);
      } else {
        // Should not happen, but handle defensively
        throw Exception("Failed to create or retrieve Water food item");
      }
    }
  }
}
