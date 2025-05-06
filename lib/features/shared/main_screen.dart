import 'package:flutter/material.dart';
import 'package:cal_nutri_pal/shared/widgets/bottom_navigation_bar.dart';
import 'package:cal_nutri_pal/features/dashboard/dashboard_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/food_log_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/add_meal_screen.dart';
import 'package:cal_nutri_pal/features/dashboard/reports_screen.dart';
import 'package:cal_nutri_pal/features/profile/profile_screen.dart';

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  /// Creates a [MainScreen] widget
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FoodLogScreen(),
    const AddMealScreen(), // This will be shown as a modal, not as a tab
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: _screens[_currentIndex == 2
            ? 0
            : _currentIndex], // Skip "Add" tab in direct navigation
      ),
      bottomNavigationBar: CalNutriPalBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // The center "Add" button - show a modal instead of navigating
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const AddMealScreen(),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
