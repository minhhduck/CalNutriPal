import 'package:flutter/material.dart';

/// A widget that displays a nutrient value with a label and color indicator
class NutrientIndicator extends StatelessWidget {
  /// Creates a NutrientIndicator
  const NutrientIndicator({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.indicatorSize = 8.0,
  }) : super(key: key);

  /// The label for the nutrient (e.g., "Protein")
  final String label;

  /// The numeric value of the nutrient
  final double value;

  /// The unit of measurement (e.g., "g")
  final String unit;

  /// The color associated with this nutrient
  final Color color;

  /// The size of the color indicator dot
  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
