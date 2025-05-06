import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_nutri_pal/core/services/user_stats_provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';
import 'package:cal_nutri_pal/core/services/navigation_service.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';

/// Controller managing the main application state and navigation
class MainAppController extends ChangeNotifier {
  final UserStatsProvider _userStatsProvider;
  final NutritionGoalsProvider _nutritionGoalsProvider;
  final NavigationService _navigationService;

  AppState _appState = AppState.initializing;
  bool _hasCompletedOnboarding = false;

  /// Creates the main app controller
  MainAppController({
    required UserStatsProvider userStatsProvider,
    required NutritionGoalsProvider nutritionGoalsProvider,
    required NavigationService navigationService,
  })  : _userStatsProvider = userStatsProvider,
        _nutritionGoalsProvider = nutritionGoalsProvider,
        _navigationService = navigationService {
    initialize();
  }

  /// Current application state
  AppState get appState => _appState;

  /// Initialize the controller and check onboarding state
  Future<void> initialize() async {
    _appState = AppState.initializing;
    notifyListeners();

    try {
      // Initialize providers
      await _userStatsProvider.initialize();
      await _nutritionGoalsProvider.initialize();

      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      // Determine app state based on onboarding
      if (_hasCompletedOnboarding) {
        _appState = AppState.onboarded;
      } else {
        _appState = AppState.needsOnboarding;
      }
    } catch (e) {
      debugPrint('Error initializing MainAppController: $e');
      _appState = AppState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Navigate based on the current app state
  void navigateBasedOnState() {
    switch (_appState) {
      case AppState.needsOnboarding:
        _navigationService.navigateToAndRemoveUntil(AppRoutes.onboardingStats);
        break;
      case AppState.onboarded:
        _navigationService.navigateToAndRemoveUntil(AppRoutes.main);
        break;
      case AppState.initializing:
      case AppState.error:
        // Stay on splash screen or show error screen
        break;
    }
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    _hasCompletedOnboarding = true;
    _appState = AppState.onboarded;
    notifyListeners();
    navigateBasedOnState();
  }
}

/// Enum representing the current state of the app (Simplified)
enum AppState {
  /// App is initializing
  initializing,

  /// User hasn't completed onboarding
  needsOnboarding,

  /// User has completed onboarding
  onboarded,

  /// App encountered an error
  error,
}
