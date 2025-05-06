import 'package:flutter/material.dart';
import 'package:cal_nutri_pal/core/models/food_item.dart';
import 'package:cal_nutri_pal/shared/widgets/animated_card.dart';
import 'package:cal_nutri_pal/shared/theme/app_colors.dart';
import 'nutrient_indicator.dart';

/// A card that displays a food item with its nutritional information
class FoodItemCard extends StatelessWidget {
  /// Creates a FoodItemCard
  const FoodItemCard({
    Key? key,
    required this.foodItem,
    this.onTap,
    this.showAmount = true,
    this.animationDelay = Duration.zero,
  }) : super(key: key);

  /// The food item to display
  final FoodItem foodItem;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether to show the amount of the food item
  final bool showAmount;

  /// Delay before the card animation starts
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      delay: animationDelay,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      foodItem.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${foodItem.calories.toStringAsFixed(0)} kcal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (showAmount) ...[
                const SizedBox(height: 4),
                Text(
                  '${foodItem.servingSize.toStringAsFixed(0)} ${foodItem.servingUnit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NutrientIndicator(
                    label: 'Protein',
                    value: foodItem.proteins,
                    unit: 'g',
                    color: Colors.blue,
                  ),
                  NutrientIndicator(
                    label: 'Carbs',
                    value: foodItem.carbs,
                    unit: 'g',
                    color: Colors.orange,
                  ),
                  NutrientIndicator(
                    label: 'Fat',
                    value: foodItem.fats,
                    unit: 'g',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label that displays a nutritional value with its name
class _NutritionLabel extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _NutritionLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}g',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
