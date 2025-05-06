import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:cal_nutri_pal/features/nutrition_log/add_meal_screen.dart';
import 'package:intl/intl.dart';
import 'meal_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_log_provider.dart';

/// Food log screen for displaying meal entries
class FoodLogScreen extends StatefulWidget {
  /// Creates the [FoodLogScreen] widget
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen>
    with AutomaticKeepAliveClientMixin {
  // Selected date for filtering
  DateTime _selectedDate = DateTime.now();

  // Filter and sort options
  bool _showFilters = false;
  String _sortBy = 'Time';
  final List<String> _sortOptions = ['Time', 'Calories', 'Name'];

  // Selected meal type and available meal types
  int _selectedTabIndex = 0;
  final List<String> _mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks'
  ];
  bool _groupByMealType = false; // Whether to group entries by meal type

  @override
  void initState() {
    super.initState();
    // Load today's log on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<NutritionLogProvider>(context, listen: false);
      provider.loadLogForDate(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Food Log'),
            const SizedBox(width: 8),
            // Date display that opens picker when tapped
            GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM d').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        actions: [
          // Sort button
          GestureDetector(
            onTap: _showSortPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sort: $_sortBy',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.sort,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Meal type tabs
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                height: 40,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedTabIndex,
                  children: {
                    for (int i = 0; i < _mealTypes.length; i++)
                      i: Text(
                        _mealTypes[i],
                        style: TextStyle(
                          fontSize: 13,
                          color: _selectedTabIndex == i
                              ? AppTheme.primaryColor
                              : Colors.grey.shade700,
                        ),
                      ),
                  },
                  onValueChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTabIndex = value;
                      });
                    }
                  },
                ),
              ),
            ),

            // Content area
            Expanded(
              child: Consumer<NutritionLogProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Get entries for the selected meal type
                  List<NutritionLogEntry> entries = [];
                  switch (_selectedTabIndex) {
                    case 0: // All meals
                      entries = provider.currentDailyLog.entries;
                      break;
                    case 1: // Breakfast
                      entries = provider.breakfastEntries;
                      break;
                    case 2: // Lunch
                      entries = provider.lunchEntries;
                      break;
                    case 3: // Dinner
                      entries = provider.dinnerEntries;
                      break;
                    case 4: // Snacks
                      entries = provider.snackEntries;
                      break;
                  }

                  // Show empty state if no entries
                  if (entries.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Show entries
                  return _buildMealList(entries, provider);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Add Food or Water',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build the meal list
  Widget _buildMealList(
      List<NutritionLogEntry> entries, NutritionLogProvider provider) {
    // Sort entries by time
    _sortEntries(entries);

    // Check if we have entries to display
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    // When 'All' is selected, automatically group by meal type for better organization
    final bool shouldGroupByMealType =
        _selectedTabIndex == 0 || _groupByMealType;

    // If grouping by meal type is enabled or 'All' is selected
    if (shouldGroupByMealType) {
      // Group entries by meal type
      final Map<MealType, List<NutritionLogEntry>> groupedEntries = {};

      for (final entry in entries) {
        if (!groupedEntries.containsKey(entry.mealType)) {
          groupedEntries[entry.mealType] = [];
        }
        groupedEntries[entry.mealType]!.add(entry);
      }

      // Build a list of sections, one for each meal type with entries
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: groupedEntries.keys.length,
        itemBuilder: (context, index) {
          final mealType = groupedEntries.keys.elementAt(index);
          final entriesForType = groupedEntries[mealType]!;

          // Sort entries within each group
          _sortEntries(entriesForType);

          // Create a section for each meal type
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                child: Text(
                  _getMealTypeString(mealType),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entriesForType
                  .map((entry) => _buildMealCard(entry, provider))
                  .toList(),
            ],
          );
        },
      );
    } else {
      // Regular list, no grouping
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return _buildMealCard(entries[index], provider);
        },
      );
    }
  }

  // Build a meal card with swipe actions
  Widget _buildMealCard(
      NutritionLogEntry entry, NutritionLogProvider provider) {
    return Dismissible(
      key: Key(entry.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  Text('Are you sure you want to remove ${entry.foodName}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('DELETE'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        provider.removeEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${entry.foodName} removed'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Re-add the entry
                provider.addEntry(entry);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to meal detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealDetailScreen(entry: entry),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Food icon or image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.foodName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.amount} ${entry.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Calories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.calories.round()} cal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${entry.proteins.round()} | C: ${entry.carbs.round()} | F: ${entry.fats.round()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get meal type string
  String _getMealTypeString(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snacks';
    }
  }

  // Show date picker
  void _showDatePicker() {
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
                      // Load the log for the selected date when done
                      _loadSelectedDateLog();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: _selectedDate,
                mode: CupertinoDatePickerMode.date,
                use24hFormat: true,
                // This is called when the user changes the date.
                onDateTimeChanged: (DateTime newDate) {
                  setState(() => _selectedDate = newDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show sort picker
  void _showSortPicker() {
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
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _sortBy = _sortOptions[value];
                  });
                },
                scrollController: FixedExtentScrollController(
                  initialItem: _sortOptions.indexOf(_sortBy),
                ),
                children: [
                  for (var option in _sortOptions)
                    Text(
                      option,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty state widget
  Widget _buildEmptyState() {
    String mealTypeText = _selectedTabIndex == 0
        ? 'meal'
        : _mealTypes[_selectedTabIndex].toLowerCase();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTabIndex == 0
                ? 'No meals logged today'
                : 'No ${_mealTypes[_selectedTabIndex]} entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your nutrition by adding meals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddMealScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Meal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sort entries by time
  void _sortEntries(List<NutritionLogEntry> entries) {
    // Sort based on the selected sort option
    switch (_sortBy) {
      case 'Time':
        entries.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
        break;
      case 'Calories':
        entries.sort((a, b) => b.calories.compareTo(a.calories));
        break;
      case 'Name':
        entries.sort((a, b) =>
            a.foodName.toLowerCase().compareTo(b.foodName.toLowerCase()));
        break;
      default:
        entries.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    }
  }

  // Load log for the selected date
  void _loadSelectedDateLog() {
    final provider = Provider.of<NutritionLogProvider>(context, listen: false);
    provider.loadLogForDate(_selectedDate);
  }

  /// Show options to add food or log water.
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Add Food Item'),
              onTap: () {
                Navigator.pop(context); // Dismiss sheet
                _navigateToAddFood(); // Navigate to add food screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_drink),
              title: const Text('Log Water Intake'),
              onTap: () {
                Navigator.pop(context); // Dismiss sheet
                _showLogWaterDialog(); // Show log water dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to log water intake.
  void _showLogWaterDialog() {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Water Intake'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              border: OutlineInputBorder(),
              suffixText: 'ml',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = int.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                final provider =
                    Provider.of<NutritionLogProvider>(context, listen: false);
                provider.logWater(amount, _selectedDate).then((_) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged ${amount.toInt()}ml of water.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // No need to call _loadSelectedDateLog explicitly,
                  // logWater calls notifyListeners which updates the UI.
                }).catchError((error) {
                  Navigator.pop(context); // Close dialog even on error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging water: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  /// Navigates to the screen for adding a new meal/food item.
  void _navigateToAddFood() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMealScreen(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
