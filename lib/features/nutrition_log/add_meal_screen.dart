import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_log_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

/// Screen for adding new meal entries
class AddMealScreen extends StatefulWidget {
  /// Creates the [AddMealScreen] widget
  const AddMealScreen({super.key, this.entryToEdit});

  /// Optional entry to edit, if provided the screen will be in edit mode
  final NutritionLogEntry? entryToEdit;

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _foodNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  // Unit selection
  final List<String> _units = ['g', 'ml', 'oz', 'cup', 'tbsp', 'tsp', 'piece'];
  String _selectedUnit = 'g';

  // Meal type selection
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  int _selectedMealTypeIndex = 0;

  // Date and time
  DateTime _selectedDateTime = DateTime.now();

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSuccess = false;

  // Auto-validation mode
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Focus nodes for form fields
  final _foodNameFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _caloriesFocus = FocusNode();
  final _proteinsFocus = FocusNode();
  final _carbsFocus = FocusNode();
  final _fatsFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize form fields with entry data if in edit mode
    if (widget.entryToEdit != null) {
      _foodNameController.text = widget.entryToEdit!.foodName;
      _amountController.text = widget.entryToEdit!.amount.toString();
      _selectedUnit = widget.entryToEdit!.unit;
      _caloriesController.text = widget.entryToEdit!.calories.toString();
      _proteinsController.text = widget.entryToEdit!.proteins.toString();
      _carbsController.text = widget.entryToEdit!.carbs.toString();
      _fatsController.text = widget.entryToEdit!.fats.toString();

      // Set meal type
      switch (widget.entryToEdit!.mealType) {
        case MealType.breakfast:
          _selectedMealTypeIndex = 0;
          break;
        case MealType.lunch:
          _selectedMealTypeIndex = 1;
          break;
        case MealType.dinner:
          _selectedMealTypeIndex = 2;
          break;
        case MealType.snack:
          _selectedMealTypeIndex = 3;
          break;
      }

      _selectedDateTime = widget.entryToEdit!.loggedAt;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    _foodNameController.dispose();
    _amountController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();

    _foodNameFocus.dispose();
    _amountFocus.dispose();
    _caloriesFocus.dispose();
    _proteinsFocus.dispose();
    _carbsFocus.dispose();
    _fatsFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside of text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.entryToEdit == null ? 'Add Meal' : 'Edit Meal'),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
        body: _showSuccess ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // Build the form view
  Widget _buildFormView() {
    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error message (if any)
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),

            // Food image section
            // _buildImageSection(),
            // const SizedBox(height: 24),

            // Basic info section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),

            // Food name field
            _buildTextFormField(
              controller: _foodNameController,
              focusNode: _foodNameFocus,
              label: 'Food Name',
              placeholder: 'Enter food name',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a food name';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_amountFocus);
              },
            ),
            const SizedBox(height: 16),

            // Amount and unit row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount field
                Expanded(
                  flex: 2,
                  child: _buildTextFormField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    label: 'Amount',
                    placeholder: 'Enter amount',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final double? amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Invalid amount';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_caloriesFocus);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Unit dropdown
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: _units.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedUnit = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nutrition section
            _buildSectionHeader('Nutrition Information'),
            const SizedBox(height: 16),

            // Calories field
            _buildTextFormField(
              controller: _caloriesController,
              focusNode: _caloriesFocus,
              label: 'Calories (kcal)',
              placeholder: 'Enter calories',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final double? calories = double.tryParse(value);
                if (calories == null || calories < 0) {
                  return 'Invalid value';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_proteinsFocus);
              },
            ),
            const SizedBox(height: 16),

            // Protein, carbs, and fats fields (3 in a row)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Proteins field
                Expanded(
                  child: _buildTextFormField(
                    controller: _proteinsController,
                    focusNode: _proteinsFocus,
                    label: 'Protein (g)',
                    placeholder: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final double? protein = double.tryParse(value);
                        if (protein == null || protein < 0) {
                          return 'Invalid';
                        }
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_carbsFocus);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Carbs field
                Expanded(
                  child: _buildTextFormField(
                    controller: _carbsController,
                    focusNode: _carbsFocus,
                    label: 'Carbs (g)',
                    placeholder: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final double? carbs = double.tryParse(value);
                        if (carbs == null || carbs < 0) {
                          return 'Invalid';
                        }
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_fatsFocus);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Fats field
                Expanded(
                  child: _buildTextFormField(
                    controller: _fatsController,
                    focusNode: _fatsFocus,
                    label: 'Fats (g)',
                    placeholder: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final double? fats = double.tryParse(value);
                        if (fats == null || fats < 0) {
                          return 'Invalid';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Meal details section
            _buildSectionHeader('Meal Details'),
            const SizedBox(height: 16),

            // Meal type selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedMealTypeIndex,
                  children: {
                    for (int i = 0; i < _mealTypes.length; i++)
                      i: Text(_mealTypes[i]),
                  },
                  onValueChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        _selectedMealTypeIndex = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DateTime selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date & Time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showDateTimePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('MMM d, yyyy - h:mm a')
                                .format(_selectedDateTime),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Space at the bottom
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Build text form field with consistent styling
  Widget _buildTextFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: placeholder,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            errorStyle: TextStyle(color: Colors.red.shade700),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // Build success view
  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade400,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Meal Added Successfully!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your meal has been added to your food log.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Return true to indicate success
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Back to Food Log'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                // Reset the form
                _resetForm();
                _showSuccess = false;
              });
            },
            child: const Text('Add Another Meal'),
          ),
        ],
      ),
    );
  }

  // Show date and time picker
  void _showDateTimePicker() {
    // Use Cupertino date picker for iOS style
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: _selectedDateTime,
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: false,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() => _selectedDateTime = newDateTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Submit the form
  void _submitForm() async {
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parse form values
        final double amount = double.parse(_amountController.text);
        final double calories = double.parse(_caloriesController.text);
        final double proteins = double.parse(
            _proteinsController.text.isEmpty ? '0' : _proteinsController.text);
        final double carbs = double.parse(
            _carbsController.text.isEmpty ? '0' : _carbsController.text);
        final double fats = double.parse(
            _fatsController.text.isEmpty ? '0' : _fatsController.text);

        // Get meal type
        MealType mealType;
        switch (_selectedMealTypeIndex) {
          case 0:
            mealType = MealType.breakfast;
            break;
          case 1:
            mealType = MealType.lunch;
            break;
          case 2:
            mealType = MealType.dinner;
            break;
          case 3:
            mealType = MealType.snack;
            break;
          default:
            mealType = MealType.snack;
        }

        // Get provider
        final provider =
            Provider.of<NutritionLogProvider>(context, listen: false);

        if (widget.entryToEdit != null) {
          // Update existing entry
          final updatedEntry = NutritionLogEntry(
            id: widget.entryToEdit!.id,
            foodItemId: widget.entryToEdit!.foodItemId,
            foodName: _foodNameController.text,
            amount: amount,
            unit: _selectedUnit,
            calories: calories,
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            mealType: mealType,
            loggedAt: _selectedDateTime,
          );

          await provider.updateEntry(updatedEntry);

          setState(() {
            _isLoading = false;
            _showSuccess = true;
          });

          // Return to previous screen after 1 second
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          // Create new entry
          final entry = NutritionLogEntry.create(
            foodItemId: 'manual-entry-${DateTime.now().millisecondsSinceEpoch}',
            foodName: _foodNameController.text,
            amount: amount,
            unit: _selectedUnit,
            calories: calories,
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            mealType: mealType,
          );

          await provider.addEntry(entry);

          setState(() {
            _isLoading = false;
            _showSuccess = true;
          });

          // Reset form
          _formKey.currentState?.reset();
          _foodNameController.clear();
          _amountController.clear();
          _caloriesController.clear();
          _proteinsController.clear();
          _carbsController.clear();
          _fatsController.clear();

          // Go back to previous screen after 1 second
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    } else {
      // Show validation errors
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }

  // Reset form fields
  void _resetForm() {
    _formKey.currentState?.reset();
    _foodNameController.clear();
    _amountController.clear();
    _caloriesController.clear();
    _proteinsController.clear();
    _carbsController.clear();
    _fatsController.clear();
    _selectedUnit = 'g';
    _selectedMealTypeIndex = 0;
    _selectedDateTime = DateTime.now();
    _errorMessage = null;
    _autovalidateMode = AutovalidateMode.disabled;
  }
}
