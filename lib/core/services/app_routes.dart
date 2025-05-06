import 'package:flutter/material.dart';
import 'package:cal_nutri_pal/features/shared/splash_screen.dart';
import 'package:cal_nutri_pal/features/shared/main_screen.dart';
import 'package:cal_nutri_pal/features/dashboard/dashboard_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/food_log_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/add_meal_screen.dart';
import 'package:cal_nutri_pal/features/dashboard/reports_screen.dart';
import 'package:cal_nutri_pal/features/profile/profile_screen.dart';
import 'package:cal_nutri_pal/features/auth/onboarding_stats_screen.dart';
import 'package:cal_nutri_pal/features/auth/onboarding_goals_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/meal_detail_screen.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';

/// Route transition types
enum RouteType { fromRight, fromLeft, fromBottom, fromTop, fade, scale }

/// App routes management
class AppRoutes {
  /// Routes names
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String foodLog = '/food-log';
  static const String addMeal = '/add-meal';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String onboardingStats = '/onboarding-stats';
  static const String onboardingGoals = '/onboarding-goals';
  static const String main = '/main';
  static const String mealDetail = '/meal_detail';

  /// Initial route
  static const String initialRoute = splash;

  /// App routes
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboardingStats: (context) => OnboardingStatsScreen(
          onComplete: () =>
              Navigator.pushReplacementNamed(context, onboardingGoals),
          onSkip: () =>
              Navigator.pushReplacementNamed(context, onboardingGoals),
        ),
    onboardingGoals: (context) => OnboardingGoalsScreen(
          onComplete: () => _completeOnboarding(context),
          onSkip: () => _completeOnboarding(context),
        ),
    main: (context) => const MainScreen(),
    dashboard: (context) => const DashboardScreen(),
    foodLog: (context) => const FoodLogScreen(),
    addMeal: (context) => const AddMealScreen(),
    reports: (context) => const ReportsScreen(),
    profile: (context) => const ProfileScreen(),
  };

  /// Function to handle onboarding completion navigation
  static void _completeOnboarding(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, main, (route) => false);
  }

  /// Page transitions
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return _buildRoute(settings, const SplashScreen(), RouteType.fade);
      case dashboard:
        return _buildRoute(settings, const DashboardScreen(), RouteType.fade);
      case foodLog:
        return _buildRoute(settings, const FoodLogScreen(), RouteType.fade);
      case addMeal:
        if (args is NutritionLogEntry) {
          return _buildRoute(
              settings, AddMealScreen(entryToEdit: args), RouteType.fromBottom);
        } else {
          return _buildRoute(
              settings, const AddMealScreen(), RouteType.fromBottom);
        }
      case reports:
        return _buildRoute(
            settings, const ReportsScreen(), RouteType.fromRight);
      case profile:
        return _buildRoute(
            settings, const ProfileScreen(), RouteType.fromRight);
      case onboardingStats:
        return _buildRoute(
            settings,
            Builder(
              builder: (context) => OnboardingStatsScreen(
                onComplete: () =>
                    Navigator.pushReplacementNamed(context, onboardingGoals),
                onSkip: () =>
                    Navigator.pushReplacementNamed(context, onboardingGoals),
              ),
            ),
            RouteType.fromRight);

      case onboardingGoals:
        return _buildRoute(
            settings,
            Builder(
              builder: (context) => OnboardingGoalsScreen(
                onComplete: () => _completeOnboarding(context),
                onSkip: () => _completeOnboarding(context),
              ),
            ),
            RouteType.fromRight);
      case main:
        return _buildRoute(settings, const MainScreen(), RouteType.fade);

      case mealDetail:
        if (args is MealDetailArgs) {
          return _buildRoute(
            settings,
            MealDetailScreen(entry: args.entry),
            RouteType.fromRight,
          );
        }
        return _errorRoute();
      default:
        if (routes.containsKey(settings.name)) {
          return null;
        }
        return _errorRoute();
    }
  }

  /// Build iOS-style page route with enhanced transitions
  static PageRouteBuilder _buildRoute(
      RouteSettings settings, Widget page, RouteType type) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
          reverseCurve: Curves.easeInExpo,
        );

        switch (type) {
          case RouteType.fromRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case RouteType.fromLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case RouteType.fromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: child,
              ),
            );

          case RouteType.fromTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case RouteType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );

          case RouteType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Error route for unknown paths
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}

/// Argument class for MealDetailScreen
class MealDetailArgs {
  final NutritionLogEntry entry;
  MealDetailArgs({required this.entry});
}
