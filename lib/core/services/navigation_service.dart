import 'package:flutter/material.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';

/// Navigation service to manage routing throughout the app
class NavigationService {
  /// Global key for navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current BuildContext
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get the current NavigatorState
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a named route and remove all previous routes
  Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace the current route
  Future<dynamic> navigateToAndReplace(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate back
  void goBack() {
    navigator!.pop();
  }

  /// Navigate back with result
  void goBackWithResult(dynamic result) {
    navigator!.pop(result);
  }

  /// Navigate back until a specific route
  void goBackUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }

  /// Navigate to onboarding flow
  Future<dynamic> startOnboarding() {
    return navigateToAndRemoveUntil(AppRoutes.onboardingStats);
  }
}
