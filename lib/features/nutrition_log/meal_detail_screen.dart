import 'package:flutter/material.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_log_provider.dart';
import 'package:cal_nutri_pal/features/nutrition_log/add_meal_screen.dart';

/// Screen displaying detailed information about a specific meal entry
class MealDetailScreen extends StatelessWidget {
  /// The nutrition log entry to display
  final NutritionLogEntry entry;

  /// Creates a [MealDetailScreen] with the given entry
  const MealDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getMealTypeString(entry.mealType)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _getMealTypeString(entry.mealType),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDateTime(entry.loggedAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${entry.amount} ${entry.unit}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Nutrition breakdown
              const Text(
                'Nutrition Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // Calories
              _buildNutrientRow(
                label: 'Calories',
                value: '${entry.calories.toStringAsFixed(0)} kcal',
                color: Colors.red,
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // Macronutrients
              _buildNutrientRow(
                label: 'Protein',
                value: '${entry.proteins.toStringAsFixed(1)} g',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              _buildNutrientRow(
                label: 'Carbohydrates',
                value: '${entry.carbs.toStringAsFixed(1)} g',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              _buildNutrientRow(
                label: 'Fats',
                value: '${entry.fats.toStringAsFixed(1)} g',
                color: Colors.green,
              ),

              const SizedBox(height: 32),

              // Macro distribution chart
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Macronutrient Distribution',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMacroDistributionChart(),
                      const SizedBox(height: 16),
                      _buildMacroLegend(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a circular representation of macronutrient distribution
  Widget _buildMacroDistributionChart() {
    // Calculate total macros
    final totalMacros = entry.proteins + entry.carbs + entry.fats;
    final proteinPercentage =
        totalMacros > 0 ? entry.proteins / totalMacros : 0.0;
    final carbsPercentage = totalMacros > 0 ? entry.carbs / totalMacros : 0.0;
    final fatsPercentage = totalMacros > 0 ? entry.fats / totalMacros : 0.0;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey.shade300),
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value:
                        (proteinPercentage + carbsPercentage + fatsPercentage)
                            .toDouble(),
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: (proteinPercentage + carbsPercentage).toDouble(),
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: proteinPercentage.toDouble(),
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.calories.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build a legend for the macronutrient chart
  Widget _buildMacroLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          color: Colors.blue,
          label: 'Protein',
          value: '${entry.proteins.toStringAsFixed(1)}g',
        ),
        _buildLegendItem(
          color: Colors.orange,
          label: 'Carbs',
          value: '${entry.carbs.toStringAsFixed(1)}g',
        ),
        _buildLegendItem(
          color: Colors.green,
          label: 'Fats',
          value: '${entry.fats.toStringAsFixed(1)}g',
        ),
      ],
    );
  }

  // Build a legend item with color indicator, label, and value
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build a nutrient row with label, value and visual indicator
  Widget _buildNutrientRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Show confirmation dialog before deleting an entry
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();

              // Get the provider and delete the entry
              final provider =
                  Provider.of<NutritionLogProvider>(context, listen: false);
              provider.removeEntry(entry.id);

              // Return to previous screen and show a confirmation message
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${entry.foodName} deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Get a formatted meal type string from the enum
  String _getMealTypeString(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      default:
        return 'Meal';
    }
  }

  // Format the date and time for display
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
  }

  // Navigate to edit screen with current entry data
  void _navigateToEditScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMealScreen(entryToEdit: entry),
      ),
    );
  }
}
