import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';

/// A card widget that displays progress for a particular nutrient
class NutrientProgressCard extends StatelessWidget {
  /// The title of the nutrient (e.g., "Protein", "Carbs")
  final String title;

  /// The current value of the nutrient
  final double currentValue;

  /// The target/goal value of the nutrient
  final double goalValue;

  /// The color for the progress indicator
  final Color color;

  /// The unit of measurement (e.g., "g", "kcal")
  final String unit;

  /// Creates a [NutrientProgressCard] widget
  const NutrientProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.goalValue,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final percent =
        goalValue > 0 ? (currentValue / goalValue).clamp(0.0, 1.0) : 0.0;
    final percentText = (percent * 100).toStringAsFixed(0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            CircularPercentIndicator(
              radius: 42.0,
              lineWidth: 8.0,
              percent: percent,
              center: Text(
                '$percentText%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              progressColor: color,
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '${currentValue.toStringAsFixed(1)} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '$unit / '),
                    TextSpan(
                      text: '${goalValue.toStringAsFixed(0)} $unit',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
