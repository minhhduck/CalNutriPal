import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/nutrition_goals_model.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';

/// Tab for displaying and updating nutrition goals
///
/// This component receives goals and the update callback as props.
/// In a real application, these are provided by the NutritionGoalsService
/// through Provider/Consumer pattern used in the parent component.
class NutritionGoalsTab extends StatefulWidget {
  /// Creates the [NutritionGoalsTab] widget
  const NutritionGoalsTab({
    super.key,
  });

  @override
  State<NutritionGoalsTab> createState() => _NutritionGoalsTabState();
}

class _NutritionGoalsTabState extends State<NutritionGoalsTab> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controller for calorie input
  late TextEditingController _calorieController;

  // Current values for sliders
  late int _proteinPercentage;
  late int _carbsPercentage;
  late int _fatPercentage;

  // UI state
  bool _isEditing = false;
  bool _sliderError = false;

  @override
  void initState() {
    super.initState();
    // Will be initialized when provider data is available
    _calorieController = TextEditingController();
    _proteinPercentage = 30;
    _carbsPercentage = 40;
    _fatPercentage = 30;

    // Initialize from provider in post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromProvider();
    });
  }

  void _initializeFromProvider() {
    final nutritionGoalsProvider =
        Provider.of<NutritionGoalsProvider>(context, listen: false);
    final goals = nutritionGoalsProvider.nutritionGoals;

    setState(() {
      _calorieController.text = goals.calorieGoal.toString();
      _proteinPercentage = goals.proteinPercentage;
      _carbsPercentage = goals.carbsPercentage;
      _fatPercentage = goals.fatPercentage;
    });
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  /// Validate slider values add up to 100%
  bool _validateSliders() {
    final total = _proteinPercentage + _carbsPercentage + _fatPercentage;
    return total == 100;
  }

  /// Handle save button press
  void _handleSave() {
    if (_formKey.currentState!.validate() && _validateSliders()) {
      final calorieGoal = int.tryParse(_calorieController.text) ?? 2000;

      final nutritionGoalsProvider =
          Provider.of<NutritionGoalsProvider>(context, listen: false);

      // Update the goals using the provider
      nutritionGoalsProvider.updateMacroPercentages(
        proteinPercentage: _proteinPercentage,
        carbsPercentage: _carbsPercentage,
        fatPercentage: _fatPercentage,
      );

      nutritionGoalsProvider.updateCalorieGoal(calorieGoal);

      setState(() {
        _isEditing = false;
        _sliderError = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nutrition goals updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _sliderError = !_validateSliders();
      });
    }
  }

  /// Handle cancel button press
  void _handleCancel() {
    _initializeFromProvider();
    setState(() {
      _isEditing = false;
      _sliderError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionGoalsProvider>(
      builder: (context, nutritionGoalsProvider, child) {
        final goals = nutritionGoalsProvider.nutritionGoals;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header section
                _buildHeaderSection(),
                const SizedBox(height: 24),

                // Main content based on editing state
                _isEditing ? _buildEditForm() : _buildGoalsDisplay(goals),

                // Buttons section
                const SizedBox(height: 16),
                _buildButtonsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the header section with title and description
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition Goals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your daily calorie and macronutrient targets to help track your nutrition goals.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build the goals display section (non-editing state)
  Widget _buildGoalsDisplay(NutritionGoals goals) {
    return Column(
      children: [
        // Calorie target card
        _buildInfoCard(
          title: 'Daily Calorie Target',
          value: '${goals.calorieGoal}',
          unit: 'kcal',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),

        // Macronutrient breakdown card
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
                    Icon(Icons.pie_chart, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Macronutrient Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Protein progress bar
                _buildMacroProgressBar(
                  label: 'Protein',
                  percentage: goals.proteinPercentage,
                  color: Colors.blue,
                  grams: goals.proteinGrams.toInt(),
                ),
                const SizedBox(height: 12),

                // Carbs progress bar
                _buildMacroProgressBar(
                  label: 'Carbs',
                  percentage: goals.carbsPercentage,
                  color: Colors.orange,
                  grams: goals.carbsGrams.toInt(),
                ),
                const SizedBox(height: 12),

                // Fat progress bar
                _buildMacroProgressBar(
                  label: 'Fat',
                  percentage: goals.fatPercentage,
                  color: Colors.red,
                  grams: goals.fatGrams.toInt(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the edit form for updating goals
  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie input
          const Text(
            'Daily Calorie Target',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _calorieController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter calorie target',
              suffixText: 'kcal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a calorie target';
              }

              final calories = int.tryParse(value);
              if (calories == null || calories <= 0) {
                return 'Please enter a valid calorie amount';
              }

              if (calories < 1000 || calories > 5000) {
                return 'Please enter a value between 1000-5000';
              }

              return null;
            },
          ),
          const SizedBox(height: 24),

          // Macronutrient sliders
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Macronutrient Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_proteinPercentage + _carbsPercentage + _fatPercentage}%',
                    style: TextStyle(
                      color: _validateSliders() ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_sliderError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Percentages must add up to 100%',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Protein slider
              _buildMacroSlider(
                label: 'Protein',
                color: Colors.blue,
                value: _proteinPercentage,
                onChanged: (value) {
                  setState(() {
                    _proteinPercentage = value.round();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Carbs slider
              _buildMacroSlider(
                label: 'Carbs',
                color: Colors.orange,
                value: _carbsPercentage,
                onChanged: (value) {
                  setState(() {
                    _carbsPercentage = value.round();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Fat slider
              _buildMacroSlider(
                label: 'Fat',
                color: Colors.red,
                value: _fatPercentage,
                onChanged: (value) {
                  setState(() {
                    _fatPercentage = value.round();
                  });
                },
              ),

              // Helper text
              const SizedBox(height: 8),
              Text(
                'Adjust the sliders so that protein, carbs, and fat percentages add up to 100%.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the buttons section
  Widget _buildButtonsSection() {
    if (_isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: AppTheme.primaryColor),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Save'),
          ),
        ],
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Edit Goals'),
        ),
      );
    }
  }

  /// Build a card for displaying a single info item
  Widget _buildInfoCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a macronutrient progress bar
  Widget _buildMacroProgressBar({
    required String label,
    required int percentage,
    required int grams,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '$grams g',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// Build a macronutrient slider
  Widget _buildMacroSlider({
    required String label,
    required Color color,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Text(
              '$value%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
