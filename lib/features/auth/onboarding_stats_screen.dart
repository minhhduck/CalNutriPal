import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/models/user_stats_model.dart';
import 'package:cal_nutri_pal/core/services/user_stats_provider.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';

/// Onboarding screen for collecting user's physical statistics
class OnboardingStatsScreen extends StatefulWidget {
  /// Function to call when user completes this screen
  final VoidCallback onComplete;

  /// Function to call when user skips this screen
  final VoidCallback onSkip;

  /// Creates an [OnboardingStatsScreen] widget
  const OnboardingStatsScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<OnboardingStatsScreen> createState() => _OnboardingStatsScreenState();
}

class _OnboardingStatsScreenState extends State<OnboardingStatsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Height controllers
  final _heightCmController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();

  // Weight controllers
  final _weightKgController = TextEditingController();
  final _weightLbsController = TextEditingController();

  // Age controller
  final _ageController = TextEditingController();

  // Form values
  Gender _selectedGender = Gender.other;
  ActivityLevel _selectedActivityLevel = ActivityLevel.moderate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormValues();
    });
  }

  void _initializeFormValues() {
    final userStatsProvider =
        Provider.of<UserStatsProvider>(context, listen: false);
    final stats = userStatsProvider.userStats;

    // Set default values
    _heightCmController.text = stats.heightCm.toStringAsFixed(1);

    final feetInches = stats.getHeightInFeetAndInches();
    _heightFeetController.text = feetInches['feet']!.toStringAsFixed(0);
    _heightInchesController.text = feetInches['inches']!.toStringAsFixed(1);

    _weightKgController.text = stats.weightKg.toStringAsFixed(1);
    _weightLbsController.text = stats.getWeightInPounds().toStringAsFixed(1);

    _ageController.text = stats.age.toString();

    _selectedGender = stats.gender;
    _selectedActivityLevel = stats.activityLevel;
  }

  @override
  void dispose() {
    _heightCmController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightKgController.dispose();
    _weightLbsController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStatsProvider = Provider.of<UserStatsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Body Stats',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: AppTheme.textSecondaryColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.splash);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Progress indicator
                const LinearProgressIndicator(
                  value: 0.5, // 1 of 2 steps
                  backgroundColor: Colors.grey,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '50%',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Intro text
                const Text(
                  'Let\'s set up your profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'ll use this information to calculate your daily calorie and nutrient targets.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // Height input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    CupertinoSlidingSegmentedControl<bool>(
                      groupValue: userStatsProvider.useMetricHeight,
                      thumbColor: AppTheme.primaryColor,
                      backgroundColor: Colors.grey.shade200,
                      children: const {
                        true: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'cm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        false: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ft/in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (value) {
                        userStatsProvider.toggleHeightUnit();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Height input fields
                if (userStatsProvider.useMetricHeight)
                  _buildHeightCmInput()
                else
                  _buildHeightFeetInchesInput(),
                const SizedBox(height: 24),

                // Weight input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    CupertinoSlidingSegmentedControl<bool>(
                      groupValue: userStatsProvider.useMetricWeight,
                      thumbColor: AppTheme.primaryColor,
                      backgroundColor: Colors.grey.shade200,
                      children: const {
                        true: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'kg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        false: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'lbs',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (value) {
                        userStatsProvider.toggleWeightUnit();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weight input fields
                userStatsProvider.useMetricWeight
                    ? _buildWeightKgInput()
                    : _buildWeightLbsInput(),
                const SizedBox(height: 24),

                // Age input
                const Text(
                  'Age',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    hintText: 'Enter your age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateAge,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // Gender selection
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildGenderSelection(),
                const SizedBox(height: 24),

                // Activity level
                const Text(
                  'Activity Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildActivityLevelDropdown(),
                const SizedBox(height: 32),

                // Next button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Height in cm input field
  Widget _buildHeightCmInput() {
    return TextFormField(
      controller: _heightCmController,
      decoration: InputDecoration(
        hintText: 'Height in cm',
        suffixText: 'cm',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateHeightCm,
      textInputAction: TextInputAction.next,
    );
  }

  // Height in feet and inches input fields
  Widget _buildHeightFeetInchesInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _heightFeetController,
            decoration: InputDecoration(
              hintText: 'Feet',
              suffixText: 'ft',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            keyboardType: TextInputType.number,
            validator: _validateHeightFeet,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _heightInchesController,
            decoration: InputDecoration(
              hintText: 'Inches',
              suffixText: 'in',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateHeightInches,
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }

  // Weight in kg input field
  Widget _buildWeightKgInput() {
    return TextFormField(
      controller: _weightKgController,
      decoration: InputDecoration(
        hintText: 'Weight in kg',
        suffixText: 'kg',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateWeightKg,
      textInputAction: TextInputAction.next,
    );
  }

  // Weight in lbs input field
  Widget _buildWeightLbsInput() {
    return TextFormField(
      controller: _weightLbsController,
      decoration: InputDecoration(
        hintText: 'Weight in lbs',
        suffixText: 'lbs',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateWeightLbs,
      textInputAction: TextInputAction.next,
    );
  }

  // Gender selection UI
  Widget _buildGenderSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildGenderOption(Gender.male, 'Male', Icons.male),
          Divider(height: 1, color: Colors.grey.shade300),
          _buildGenderOption(Gender.female, 'Female', Icons.female),
          Divider(height: 1, color: Colors.grey.shade300),
          _buildGenderOption(
              Gender.other, 'Other/Prefer not to say', Icons.person),
        ],
      ),
    );
  }

  // Single gender option
  Widget _buildGenderOption(Gender gender, String label, IconData icon) {
    return RadioListTile<Gender>(
      title: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      value: gender,
      groupValue: _selectedGender,
      onChanged: (Gender? value) {
        if (value != null) {
          setState(() {
            _selectedGender = value;
          });
        }
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  // Activity level dropdown
  Widget _buildActivityLevelDropdown() {
    final Map<ActivityLevel, String> activityLevelLabels = {
      ActivityLevel.sedentary: 'Sedentary (little or no exercise)',
      ActivityLevel.light: 'Light (exercise 1-3 times/week)',
      ActivityLevel.moderate: 'Moderate (exercise 3-5 times/week)',
      ActivityLevel.active: 'Active (exercise 6-7 times/week)',
      ActivityLevel.veryActive: 'Very Active (hard exercise 6-7 times/week)',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ActivityLevel>(
          value: _selectedActivityLevel,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: activityLevelLabels.entries.map((entry) {
            return DropdownMenuItem<ActivityLevel>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (ActivityLevel? value) {
            if (value != null) {
              setState(() {
                _selectedActivityLevel = value;
              });
            }
          },
        ),
      ),
    );
  }

  // Validation methods
  String? _validateHeightCm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your height';
    }
    try {
      final height = double.parse(value);
      if (height <= 0) {
        return 'Height must be greater than 0';
      }
      if (height > 300) {
        return 'Height seems too high';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _validateHeightFeet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    try {
      final feet = int.parse(value);
      if (feet < 0) {
        return 'Cannot be negative';
      }
      if (feet > 9) {
        return 'Too high';
      }
    } catch (e) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _validateHeightInches(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    try {
      final inches = double.parse(value);
      if (inches < 0) {
        return 'Cannot be negative';
      }
      if (inches >= 12) {
        return 'Must be less than 12';
      }
    } catch (e) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _validateWeightKg(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    try {
      final weight = double.parse(value);
      if (weight <= 0) {
        return 'Weight must be greater than 0';
      }
      if (weight > 300) {
        return 'Weight seems too high';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _validateWeightLbs(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    try {
      final weight = double.parse(value);
      if (weight <= 0) {
        return 'Weight must be greater than 0';
      }
      if (weight > 660) {
        // ~300kg in lbs
        return 'Weight seems too high';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    try {
      final age = int.parse(value);
      if (age <= 0) {
        return 'Age must be greater than 0';
      }
      if (age > 120) {
        return 'Age cannot be greater than 120';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  // Handler methods
  void _handleComplete() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final statsProvider =
            Provider.of<UserStatsProvider>(context, listen: false);

        // Create and save user stats
        final userStats = UserStats(
          gender: _selectedGender,
          age: int.parse(_ageController.text),
          heightCm: double.parse(_heightCmController.text),
          weightKg: double.parse(_weightKgController.text),
          activityLevel: _selectedActivityLevel,
        );

        // Save user stats
        await statsProvider.updateUserStats(userStats);

        setState(() {
          _isLoading = false;
        });

        // Navigate to next screen (Goals)
        if (mounted) {
          // Use pushReplacementNamed to prevent going back to this screen
          Navigator.pushReplacementNamed(context, AppRoutes.onboardingGoals);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to save user stats: $e';
        });
      }
    }
  }

  void _handleSkip() async {
    setState(() {
      _isLoading = true; // Show loading indicator while saving defaults
    });

    try {
      // Use default values
      final userStatsProvider =
          Provider.of<UserStatsProvider>(context, listen: false);
      await userStatsProvider.updateUserStats(UserStats.defaultValues());

      if (mounted) {
        // Navigate to next screen (Goals) even when skipping
        Navigator.pushReplacementNamed(context, AppRoutes.onboardingGoals);
      }
    } catch (e) {
      // Handle potential error saving defaults
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to save default stats: $e';
      });
    } finally {
      // Ensure loading is turned off if mounted
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }
}
