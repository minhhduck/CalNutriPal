import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a food item with its nutritional information
class FoodItem extends Equatable {
  final String id;
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double servingSize; // in grams
  final String servingUnit; // e.g., g, ml, oz
  final String? imageUrl;
  final String? barcode;
  final bool isFavorite;
  final DateTime createdAt;

  /// Creates a new [FoodItem] with the given parameters
  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    required this.servingUnit,
    this.imageUrl,
    this.barcode,
    this.isFavorite = false,
    required this.createdAt,
  });

  /// Creates a new [FoodItem] with a random UUID
  factory FoodItem.create({
    required String name,
    required double calories,
    required double proteins,
    required double carbs,
    required double fats,
    required double servingSize,
    String servingUnit = 'g',
    String? imageUrl,
    String? barcode,
    bool isFavorite = false,
  }) {
    return FoodItem(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      proteins: proteins,
      carbs: carbs,
      fats: fats,
      servingSize: servingSize,
      servingUnit: servingUnit,
      imageUrl: imageUrl,
      barcode: barcode,
      isFavorite: isFavorite,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a copy of this [FoodItem] with the given parameters
  FoodItem copyWith({
    String? name,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? servingSize,
    String? servingUnit,
    String? imageUrl,
    String? barcode,
    bool? isFavorite,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  /// Scales nutritional values based on the given amount
  FoodItem scale(double amount) {
    final scaleFactor = amount / servingSize;
    return FoodItem(
      id: id,
      name: name,
      calories: calories * scaleFactor,
      proteins: proteins * scaleFactor,
      carbs: carbs * scaleFactor,
      fats: fats * scaleFactor,
      servingSize: amount,
      servingUnit: servingUnit,
      imageUrl: imageUrl,
      barcode: barcode,
      isFavorite: isFavorite,
      createdAt: createdAt,
    );
  }

  /// Converts the [FoodItem] to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a [FoodItem] from a map
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      proteins: map['proteins'],
      carbs: map['carbs'],
      fats: map['fats'],
      servingSize: map['servingSize'],
      servingUnit: map['servingUnit'],
      imageUrl: map['imageUrl'],
      barcode: map['barcode'],
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        calories,
        proteins,
        carbs,
        fats,
        servingSize,
        servingUnit,
        imageUrl,
        barcode,
        isFavorite,
        createdAt,
      ];
}
