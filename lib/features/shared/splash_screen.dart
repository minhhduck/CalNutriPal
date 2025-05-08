import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';

/// Splash screen shown on app startup
class SplashScreen extends StatefulWidget {
  /// Creates the [SplashScreen] widget
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatusAndNavigate();
  }

  Future<void> _checkOnboardingStatusAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      debugPrint(
          "SplashScreen: hasCompletedOnboarding flag is: $hasCompletedOnboarding");

      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      if (hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking onboarding status: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.onboardingStats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                const SizedBox(height: 20),
                const Text(
                  'CalNutriPal',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Let's Reach our Goals!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : ElevatedButton(
                        onPressed: () => _navigateToOnboarding(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Let\'s Go',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
