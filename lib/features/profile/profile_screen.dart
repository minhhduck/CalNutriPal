import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/services/main_app_controller.dart';
import 'package:cal_nutri_pal/core/services/user_stats_provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';
import 'package:cal_nutri_pal/core/models/user_stats_model.dart';
import 'package:cal_nutri_pal/core/services/database_helper.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';
import 'package:cal_nutri_pal/core/services/user_provider.dart';
import 'package:cal_nutri_pal/features/privacy_policy/privacy_policy_screen.dart';

/// Profile screen for displaying and editing user information
class ProfileScreen extends StatefulWidget {
  /// Creates the [ProfileScreen] widget
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  // User data
  String _userName = 'User';
  // String? _userAvatarUrl; // Removed
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedUnit = 'Metric';

  // Body stats
  final Map<String, String> _bodyStats = {
    'Height': '175 cm',
    'Weight': '70 kg',
    'BMI': '22.9 (Normal)',
    'Age': '30 years',
    'Activity Level': 'Moderately Active',
  };

  // Activity levels for dropdown
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];

  // Height and weight controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();
  final TextEditingController _weightLbsController = TextEditingController();

  int _waterGoalMl = 2000; // Add state variable for water goal

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateControllers();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightLbsController.dispose();
    super.dispose();
  }

  // Load real user data from providers
  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_profile_name');
      final savedUnit = prefs.getString('user_unit_preference') ?? 'Metric';
      final savedWaterGoal =
          prefs.getInt('user_water_goal_ml') ?? 2000; // Load water goal

      final userStatsProvider =
          Provider.of<UserStatsProvider>(context, listen: false);
      final userStats = userStatsProvider.userStats;

      if (mounted) {
        // Convert activity level enum to display string (moved here)
        String activityLevelStr;
        switch (userStats.activityLevel) {
          case ActivityLevel.sedentary:
            activityLevelStr = 'Sedentary';
            break;
          case ActivityLevel.light:
            activityLevelStr = 'Lightly Active';
            break;
          case ActivityLevel.moderate:
            activityLevelStr = 'Moderately Active';
            break;
          case ActivityLevel.active:
            activityLevelStr = 'Very Active';
            break;
          case ActivityLevel.veryActive:
            activityLevelStr = 'Extremely Active';
            break;
        }

        // Calculate BMI with real data (moved here)
        double height = userStats.heightCm / 100; // convert to meters
        double weight = userStats.weightKg;
        double bmi = weight / (height * height);

        String category;
        if (bmi < 18.5) {
          category = 'Underweight';
        } else if (bmi < 25) {
          category = 'Normal';
        } else if (bmi < 30) {
          category = 'Overweight';
        } else {
          category = 'Obese';
        }

        setState(() {
          _userName = savedName ?? 'User';
          _selectedUnit = savedUnit;

          // Display stats based on selected unit
          if (_selectedUnit == 'Imperial') {
            final heightFtIn = userStats.getHeightInFeetAndInches();
            _bodyStats['Height'] =
                "${heightFtIn['feet']!.toStringAsFixed(0)} ft ${heightFtIn['inches']!.toStringAsFixed(1)} in";
            _bodyStats['Weight'] =
                '${userStats.getWeightInPounds().toStringAsFixed(1)} lbs';
          } else {
            // Metric
            _bodyStats['Height'] =
                '${userStats.heightCm.toStringAsFixed(1)} cm';
            _bodyStats['Weight'] =
                '${userStats.weightKg.toStringAsFixed(1)} kg';
          }
          _bodyStats['Age'] = '${userStats.age} years';
          _bodyStats['Activity Level'] = activityLevelStr;
          _bodyStats['BMI'] = '${bmi.toStringAsFixed(1)} ($category)';

          // Update water goal display value
          _waterGoalMl = savedWaterGoal;
        });
      }
    });
  }

  // Update text controllers with current values based on selected unit
  void _updateControllers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userStatsProvider =
          Provider.of<UserStatsProvider>(context, listen: false);
      final stats = userStatsProvider.userStats;

      // Use the current _selectedUnit state variable
      if (_selectedUnit == 'Imperial') {
        final heightFtIn = stats.getHeightInFeetAndInches();
        _heightFeetController.text = heightFtIn['feet']!.toStringAsFixed(0);
        _heightInchesController.text = heightFtIn['inches']!.toStringAsFixed(1);
        _weightLbsController.text =
            stats.getWeightInPounds().toStringAsFixed(1);
        // Clear metric fields if needed, or handle within validation/saving
        _heightController.clear();
        _weightController.clear();
      } else {
        // Metric
        _heightController.text = stats.heightCm.toStringAsFixed(1);
        _weightController.text = stats.weightKg.toStringAsFixed(1);
        // Clear imperial fields if needed
        _heightFeetController.clear();
        _heightInchesController.clear();
        _weightLbsController.clear();
      }
      _ageController.text = stats.age.toString();
    });
  }

  // Calculate BMI based on height and weight
  String _calculateBMI() {
    try {
      double height =
          double.parse(_heightController.text) / 100; // convert cm to meters
      double weight = double.parse(_weightController.text);
      double bmi = weight / (height * height);

      String category;
      if (bmi < 18.5) {
        category = 'Underweight';
      } else if (bmi < 25) {
        category = 'Normal';
      } else if (bmi < 30) {
        category = 'Overweight';
      } else {
        category = 'Obese';
      }

      return '${bmi.toStringAsFixed(1)} ($category)';
    } catch (e) {
      return '-- (Unknown)';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
            color: AppTheme.primaryColor,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(),

              const SizedBox(height: 24),

              // Body stats
              _buildSectionHeader('Body Stats'),
              _buildBodyStats(),

              const SizedBox(height: 24),

              // Nutrition goals
              _buildSectionHeader('Nutrition Goals'),
              _buildNutritionGoals(),

              const SizedBox(height: 24),

              // Account settings
              _buildSectionHeader('Account'),
              _buildAccountOptions(),

              const SizedBox(height: 24),

              // App settings
              _buildSectionHeader('App Settings'),
              _buildAppSettings(),

              const SizedBox(height: 24),

              // App info and version
              _buildAppInfo(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        children: [
          // GestureDetector(
          //   onTap: _selectProfileImage, // This would call the problematic functionality
          //   child: Stack(
          //     alignment: Alignment.bottomRight,
          //     children: [
          CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              // backgroundImage: _userAvatarUrl != null
              //     ? NetworkImage(_userAvatarUrl!) as ImageProvider
              //     : null,
              // child: _userAvatarUrl == null
              //     ? Text(
              child: Text(
                // Always show initials now
                _getInitials(_userName),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
              //     : null,
              ),
          //     Container(
          //       padding: const EdgeInsets.all(4),
          //       decoration: const BoxDecoration(
          //         color: AppTheme.primaryColor,
          //         shape: BoxShape.circle,
          //       ),
          //       child: const Icon(
          //         Icons.camera_alt,
          //         size: 20,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Name'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get initials from name
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials += nameParts.first.isNotEmpty ? nameParts.first[0] : '';
      if (nameParts.length > 1 && nameParts.last.isNotEmpty) {
        initials += nameParts.last[0];
      }
    }
    return initials.toUpperCase();
  }

  // void _selectProfileImage() { // Entire method removed
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.photo_camera),
  //             title: const Text('Take a photo'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               // Implement camera functionality
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text('Choose from gallery'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               // Implement gallery selection
  //             },
  //           ),
  //           if (_userAvatarUrl != null)
  //             ListTile(
  //               leading: const Icon(Icons.delete, color: Colors.red),
  //               title: const Text('Remove photo',
  //                   style: TextStyle(color: Colors.red)),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 setState(() => _userAvatarUrl = null);
  //               },
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _editProfile() {
    // Show edit profile dialog or navigate to edit profile screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: _userName),
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _userName = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save the name to SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_profile_name', _userName);

              setState(() {}); // Refresh UI with potentially new name
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBodyStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _bodyStats.entries.map((entry) {
          return Column(
            children: [
              _buildInfoRow(entry.key, entry.value),
              if (entry != _bodyStats.entries.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionGoals() {
    return Consumer<NutritionGoalsProvider>(
      builder: (context, nutritionGoalsProvider, child) {
        // Get goals from the provider
        final goals = nutritionGoalsProvider.nutritionGoals;

        // Create a map from the provider's goals
        final Map<String, String> nutritionGoals = {
          'Daily Calories': '${goals.calorieGoal} kcal',
          'Protein':
              '${goals.proteinGrams.toInt()} g (${goals.proteinPercentage}%)',
          'Carbs': '${goals.carbsGrams.toInt()} g (${goals.carbsPercentage}%)',
          'Fat': '${goals.fatGrams.toInt()} g (${goals.fatPercentage}%)',
          'Water': '${_waterGoalMl} ml', // Use state variable for water goal
        };

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: nutritionGoals.entries.map((entry) {
              return Column(
                children: [
                  _buildInfoRow(entry.key, entry.value),
                  if (entry != nutritionGoals.entries.last)
                    const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAccountOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionRow(
              'Privacy Settings', Icons.privacy_tip, _showPrivacySettings),
          const Divider(height: 1),
          _buildOptionRow(
            'Reset App Data',
            Icons.delete_forever,
            _showResetConfirmationDialog,
            isDestructive: true,
          ),
          const Divider(height: 1),
          _buildOptionRow(
            'Delete Account',
            Icons.no_accounts,
            _showDeleteAccountDialog,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchRow(
              'Notifications',
              Icons.notifications,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value)),
          const Divider(height: 1),
          _buildOptionRow('Units', Icons.straighten, _showUnitSelector,
              trailing: Text(_selectedUnit,
                  style: TextStyle(color: Colors.grey.shade600))),
          const Divider(height: 1),
          _buildOptionRow('Help & Support', Icons.help, _showHelpSupport),
          const Divider(height: 1),
          _buildOptionRow('About', Icons.info, _showAboutInfo),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'CalNutriPal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© 2023 CalNutriPal Team',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (label.contains('Calories') ||
                      label.contains('Protein') ||
                      label.contains('Carbs') ||
                      label.contains('Fat')) {
                    _editNutritionGoals();
                  } else if (label == 'Water') {
                    // Add condition for Water
                    _editWaterGoal();
                  } else if (_bodyStats.containsKey(label)) {
                    _editBodyStats();
                  } else {
                    // Handle other info row edits
                  }
                },
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(String label, IconData icon, VoidCallback onTap,
      {Widget? trailing, bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : AppTheme.primaryColor;
    final textColor = isDestructive ? Colors.red : AppTheme.textPrimaryColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const Spacer(),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: isDestructive ? Colors.red : Colors.grey,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
      String label, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Methods for handling settings interactions
  void _showPrivacySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  Future<void> _showResetConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All App Data?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action is irreversible.'),
                Text(
                    'All your logged meals, food items, stats, and goals will be permanently deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset Data'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with reset
    if (confirmed == true) {
      await _resetAppData();
    }
  }

  /// Perform the actual data reset
  Future<void> _resetAppData() async {
    try {
      // Show loading indicator (optional)
      // Consider showing a loading overlay while clearing

      // 1. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_stats');
      await prefs.remove('nutrition_goals');
      await prefs.remove('has_completed_onboarding');
      // Add any other keys you store in SharedPreferences here
      debugPrint("SharedPreferences cleared.");

      // 2. Clear SQLite Database
      final dbHelper = DatabaseHelper();
      await dbHelper.clearAllData();

      // 3. Reset relevant providers (optional, as navigation will rebuild anyway)
      // Provider.of<UserStatsProvider>(context, listen: false).initialize();
      // Provider.of<NutritionGoalsProvider>(context, listen: false).initialize();
      // Provider.of<NutritionLogProvider>(context, listen: false).initialize();

      // 4. Navigate back to the beginning
      if (mounted) {
        // Navigate to Splash which will then route to onboarding
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.splash, (route) => false);
      }
    } catch (e) {
      debugPrint("Error resetting app data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show dialog to edit water goal
  void _editWaterGoal() {
    final waterGoalController =
        TextEditingController(text: _waterGoalMl.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Water Goal'),
        content: TextField(
          controller: waterGoalController,
          decoration: const InputDecoration(
            labelText: 'Daily Water Goal (ml)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final String inputText = waterGoalController.text;
              final int? newGoal = int.tryParse(inputText);

              if (newGoal == null || newGoal <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Please enter a valid positive number for water goal.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Save to SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('user_water_goal_ml', newGoal);

              // Update local state and UI
              setState(() {
                _waterGoalMl = newGoal;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Water goal updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog before deleting account
  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Your Account?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action is permanent and cannot be undone.'),
                Text(
                    'All your account data, including personal information, logs, and settings will be permanently deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete Account'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
            ),
          ],
        );
      },
    );

    // If user confirmed, proceed with account deletion
    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  /// Perform the actual account deletion
  Future<void> _deleteAccount() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // 1. Call service to delete user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUserData();

      // 2. Clear other local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Clear database
      final dbHelper = DatabaseHelper();
      await dbHelper.clearAllData();

      // Remove loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // 4. Navigate to login/onboarding screen
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.splash, (route) => false);
      }
    } catch (e) {
      // Remove loading dialog if error
      if (mounted) {
        Navigator.pop(context);
      }

      debugPrint("Error deleting account: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show dialog to edit nutrition goals
  void _editNutritionGoals() {
    final nutritionGoalsProvider =
        Provider.of<NutritionGoalsProvider>(context, listen: false);
    final currentGoals = nutritionGoalsProvider.nutritionGoals;

    // Controllers for text fields
    final caloriesController =
        TextEditingController(text: currentGoals.calorieGoal.toString());
    final proteinController =
        TextEditingController(text: currentGoals.proteinPercentage.toString());
    final carbsController =
        TextEditingController(text: currentGoals.carbsPercentage.toString());
    final fatController =
        TextEditingController(text: currentGoals.fatPercentage.toString());

    // Helper to validate numeric input
    bool isNumeric(String? str) {
      if (str == null) return false;
      return int.tryParse(str) != null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nutrition Goals'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Daily Calories (kcal)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Macronutrient Distribution (%)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(
                  labelText: 'Carbs %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(
                  labelText: 'Fat %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Macronutrient percentages should add up to 100%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate input
              if (!isNumeric(caloriesController.text) ||
                  !isNumeric(proteinController.text) ||
                  !isNumeric(carbsController.text) ||
                  !isNumeric(fatController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid numbers'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Check percentages add up to 100
              final proteinPercent = int.parse(proteinController.text);
              final carbsPercent = int.parse(carbsController.text);
              final fatPercent = int.parse(fatController.text);

              if (proteinPercent + carbsPercent + fatPercent != 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Macronutrient percentages must add up to 100%'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Update goals
              final calorieGoal = int.parse(caloriesController.text);

              // Update using the provider
              nutritionGoalsProvider.updateCalorieGoal(calorieGoal);
              nutritionGoalsProvider.updateMacroPercentages(
                  proteinPercentage: proteinPercent,
                  carbsPercentage: carbsPercent,
                  fatPercentage: fatPercent);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nutrition goals updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Method to edit body stats
  void _editBodyStats() {
    // Use the current _selectedUnit state
    final bool isMetric = _selectedUnit == 'Metric';
    // Ensure controllers are updated before showing dialog
    _updateControllers();

    // Current activity level
    String selectedActivityLevel = _bodyStats['Activity Level']!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Body Stats'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Height Input (Conditional)
                if (isMetric)
                  TextFormField(
                    controller: _heightController, // cm controller
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    // validator: _validateHeightCm, // Add appropriate validator if needed
                  )
                else
                  Row(
                    // Feet/Inches input
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightFeetController,
                          decoration: const InputDecoration(
                            labelText: 'Height (ft)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          // validator: _validateHeightFeet,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _heightInchesController,
                          decoration: const InputDecoration(
                            labelText: 'Height (in)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          // validator: _validateHeightInches,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Weight Input (Conditional)
                if (isMetric)
                  TextFormField(
                    controller: _weightController, // kg controller
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    // validator: _validateWeightKg,
                  )
                else
                  TextFormField(
                    controller: _weightLbsController, // lbs controller
                    decoration: const InputDecoration(
                      labelText: 'Weight (lbs)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    // validator: _validateWeightLbs,
                  ),
                const SizedBox(height: 16),

                // Age field (remains the same)
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age (years)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Activity level dropdown (remains the same)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Activity Level',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedActivityLevel,
                  items: _activityLevels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Use setStateDialog provided by StatefulBuilder
                      setStateDialog(() => selectedActivityLevel = newValue);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // BMI preview (calculation needs input based on selected unit)
                // ... (BMI Preview Container) ...
                //  Text(_calculateBMI()), // We might need to adjust _calculateBMI to read from correct controllers based on isMetric
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save logic needs unit conversion
                try {
                  double heightCm;
                  double weightKg;
                  final int age = int.parse(_ageController.text);

                  if (isMetric) {
                    if (_heightController.text.isEmpty ||
                        _weightController.text.isEmpty)
                      throw Exception("Empty fields");
                    heightCm = double.parse(_heightController.text);
                    weightKg = double.parse(_weightController.text);
                  } else {
                    // Imperial
                    if (_heightFeetController.text.isEmpty ||
                        _heightInchesController.text.isEmpty ||
                        _weightLbsController.text.isEmpty)
                      throw Exception("Empty fields");
                    final double feet =
                        double.parse(_heightFeetController.text);
                    final double inches =
                        double.parse(_heightInchesController.text);
                    final double lbs = double.parse(_weightLbsController.text);
                    heightCm = ((feet * 12) + inches) * 2.54;
                    weightKg = lbs / 2.20462;
                  }

                  if (age <= 0 || heightCm <= 0 || weightKg <= 0)
                    throw Exception("Invalid values");

                  // Convert activity level string to enum (Restore this logic)
                  ActivityLevel activityLevel;
                  switch (selectedActivityLevel) {
                    case 'Sedentary':
                      activityLevel = ActivityLevel.sedentary;
                      break;
                    case 'Lightly Active':
                      activityLevel = ActivityLevel.light;
                      break;
                    case 'Moderately Active':
                      activityLevel = ActivityLevel.moderate;
                      break;
                    case 'Very Active':
                      activityLevel = ActivityLevel.active;
                      break;
                    case 'Extremely Active':
                      activityLevel = ActivityLevel.veryActive;
                      break;
                    default:
                      // Fallback or handle error, e.g., set a default
                      activityLevel = ActivityLevel.moderate;
                  }

                  // Update UserStatsProvider with METRIC values
                  final userStatsProvider =
                      Provider.of<UserStatsProvider>(context, listen: false);
                  final updatedStats = UserStats(
                    heightCm: heightCm, // Always save in metric
                    weightKg: weightKg, // Always save in metric
                    age: age,
                    gender: userStatsProvider.userStats.gender,
                    activityLevel: activityLevel,
                  );
                  userStatsProvider.updateUserStats(updatedStats);

                  // Update local UI state (_bodyStats) by reloading
                  _loadUserData(); // Reload to display correctly formatted units

                  Navigator.pop(context);
                  // ... (Show success SnackBar)
                } catch (e) {
                  // ... (Show error SnackBar for validation/parsing)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Error saving stats: ${e.toString()}'), // Improved error message
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport() {
    const supportOptions = [
      ListTile(
        leading: Icon(Icons.help_outline),
        title: Text('FAQ'),
      ),
      ListTile(
        leading: Icon(Icons.email),
        title: Text('Contact Support'),
        subtitle: Text('support@calnutripal.com'),
      ),
      ListTile(
        leading: Icon(Icons.feedback),
        title: Text('Send Feedback'),
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: supportOptions,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'CalNutriPal',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.local_dining,
        size: 50,
        color: AppTheme.primaryColor,
      ),
      children: const [
        SizedBox(height: 16),
        Text(
          'CalNutriPal helps you track your nutrition and reach your health goals with personalized recommendations.',
        ),
        SizedBox(height: 16),
        Text(
          '© 2023 CalNutriPal Team. All rights reserved.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showUnitSelector() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Unit System'),
        children: [
          RadioListTile<String>(
            title: const Text('Metric (kg, cm)'),
            value: 'Metric',
            groupValue: _selectedUnit,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedUnit = value);
                _saveUnitPreference(value).then((_) {
                  _loadUserData(); // Refresh UI
                  _updateControllers(); // Update controller values
                });
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Imperial (lb, inch)'),
            value: 'Imperial',
            groupValue: _selectedUnit,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedUnit = value);
                _saveUnitPreference(value).then((_) {
                  _loadUserData(); // Refresh UI
                  _updateControllers(); // Update controller values
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // Add method to save preference
  Future<void> _saveUnitPreference(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_unit_preference', unit);
    debugPrint("Unit preference saved: $unit");
    // Reload data to apply unit changes to display immediately
    _loadUserData();
  }

  @override
  bool get wantKeepAlive => true;
}
