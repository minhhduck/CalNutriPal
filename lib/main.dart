import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cal_nutri_pal/shared/theme/app_theme.dart';
import 'package:cal_nutri_pal/core/services/navigation_service.dart';
import 'package:cal_nutri_pal/core/services/app_routes.dart';
import 'package:cal_nutri_pal/core/services/user_provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_log_provider.dart';
import 'package:cal_nutri_pal/core/services/user_stats_provider.dart';
import 'package:cal_nutri_pal/core/services/nutrition_goals_provider.dart';
import 'package:cal_nutri_pal/core/services/main_app_controller.dart';
import 'package:cal_nutri_pal/features/shared/splash_screen.dart';
import 'package:cal_nutri_pal/features/shared/main_screen.dart';
import 'package:cal_nutri_pal/features/dashboard/dashboard_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/food_log_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/add_meal_screen.dart';
import 'package:cal_nutri_pal/features/nutrition_log/meal_detail_screen.dart';
import 'package:cal_nutri_pal/features/dashboard/reports_screen.dart';
import 'package:cal_nutri_pal/features/profile/profile_screen.dart';
import 'package:cal_nutri_pal/features/auth/onboarding_stats_screen.dart';
import 'package:cal_nutri_pal/features/auth/onboarding_goals_screen.dart';
import 'package:cal_nutri_pal/shared/widgets/bottom_navigation_bar.dart';
import 'package:cal_nutri_pal/core/models/nutrition_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

// Set this to true to enable the test harness for development
// Set to false for normal app behavior
const bool _useTestHarness = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Log app open event (optional, but good practice)
  FirebaseAnalytics.instance.logAppOpen();

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CalNutriPal());
}

/// The main app widget
class CalNutriPal extends StatelessWidget {
  /// Creates the [CalNutriPal] app
  const CalNutriPal({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = NavigationService();
    final UserStatsProvider userStatsProvider = UserStatsProvider();
    final NutritionGoalsProvider nutritionGoalsProvider =
        NutritionGoalsProvider();

    return MultiProvider(
      providers: [
        Provider<NavigationService>.value(
          value: navigationService,
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionLogProvider()..initialize(),
        ),
        ChangeNotifierProvider<UserStatsProvider>.value(
          value: userStatsProvider,
        ),
        ChangeNotifierProvider<NutritionGoalsProvider>.value(
          value: nutritionGoalsProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => MainAppController(
            userStatsProvider: userStatsProvider,
            nutritionGoalsProvider: nutritionGoalsProvider,
            navigationService: navigationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CalNutriPal',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigationService.navigatorKey,
        initialRoute: '/', // Set initial route
        routes: {
          '/': (context) => _useTestHarness
              ? const TestHarnessScreen()
              : const SplashScreen(),
          ...AppRoutes.routes,
        },
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

/// Screen for testing different screens during development
class TestHarnessScreen extends StatefulWidget {
  const TestHarnessScreen({super.key});

  @override
  State<TestHarnessScreen> createState() => _TestHarnessScreenState();
}

class _TestHarnessScreenState extends State<TestHarnessScreen> {
  Widget? _currentScreen;
  final Map<String, List<ScreenOption>> _screenCategories = {};

  @override
  void initState() {
    super.initState();
    _initScreenOptions();
  }

  void _initScreenOptions() {
    // Onboarding Screens
    _screenCategories['Onboarding'] = [
      ScreenOption(
        name: 'Body Stats Screen',
        builder: () => OnboardingStatsScreen(
          onComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Completed onboarding step 1')),
            );
            // Show the goals screen next
            setState(() {
              _currentScreen = OnboardingGoalsScreen(
                onComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completed onboarding')),
                  );
                  setState(() {
                    _currentScreen = const MainScreen();
                  });
                },
                onSkip: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Skipped goals setup')),
                  );
                  setState(() {
                    _currentScreen = const MainScreen();
                  });
                },
              );
            });
          },
          onSkip: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Skipped onboarding')),
            );
          },
        ),
      ),
      ScreenOption(
        name: 'Nutrition Goals Screen',
        builder: () => OnboardingGoalsScreen(
          onComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Completed goals setup')),
            );
          },
          onSkip: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Skipped goals setup')),
            );
          },
        ),
      ),
    ];

    // Main App
    _screenCategories['Main App'] = [
      ScreenOption(
        name: 'Main App Flow',
        builder: () => const MainScreen(),
      ),
    ];

    // Nutrition Log Screens
    _screenCategories['Nutrition Log'] = [
      ScreenOption(
        name: 'Food Log Screen',
        builder: () => const FoodLogScreen(),
      ),
      ScreenOption(
        name: 'Add Meal Screen',
        builder: () => const AddMealScreen(),
      ),
      ScreenOption(
        name: 'Edit Meal (Example)',
        builder: () => AddMealScreen(
          entryToEdit: NutritionLogEntry.create(
            foodItemId: 'test-food-id',
            foodName: 'Test Food Item',
            amount: 100,
            unit: 'g',
            calories: 250,
            proteins: 10,
            carbs: 30,
            fats: 12,
            mealType: MealType.lunch,
          ),
        ),
      ),
      ScreenOption(
        name: 'Meal Details (Example)',
        builder: () => MealDetailScreen(
          entry: NutritionLogEntry.create(
            foodItemId: 'test-food-id',
            foodName: 'Test Food Item',
            amount: 100,
            unit: 'g',
            calories: 250,
            proteins: 10,
            carbs: 30,
            fats: 12,
            mealType: MealType.lunch,
          ),
        ),
      ),
    ];

    // Other Feature Screens
    _screenCategories['Other Screens'] = [
      ScreenOption(
        name: 'Dashboard',
        builder: () => const DashboardScreen(),
      ),
      ScreenOption(
        name: 'Reports',
        builder: () => const ReportsScreen(),
      ),
      ScreenOption(
        name: 'Profile',
        builder: () => const ProfileScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_currentScreen != null) {
      return Stack(
        children: [
          _currentScreen!,
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentScreen = null;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Harness'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _screenCategories.length,
        itemBuilder: (context, categoryIndex) {
          final category = _screenCategories.keys.elementAt(categoryIndex);
          final categoryScreens = _screenCategories[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              ...categoryScreens
                  .map((option) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(option.name),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            setState(() {
                              _currentScreen = option.builder();
                            });
                          },
                        ),
                      ))
                  .toList(),
              if (categoryIndex < _screenCategories.length - 1)
                const Divider(height: 24),
            ],
          );
        },
      ),
    );
  }
}

/// Represents a screen option in the test harness
class ScreenOption {
  final String name;
  final Widget Function() builder;

  ScreenOption({
    required this.name,
    required this.builder,
  });
}

/// The main screen with the bottom navigation bar
class MainScreen extends StatefulWidget {
  /// Creates the [MainScreen] widget
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FoodLogScreen(),
    const AddMealScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: _screens[_currentIndex],
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

/// A placeholder screen for demonstration purposes
class PlaceholderScreen extends StatelessWidget {
  /// The title of the screen
  final String title;

  /// The icon to display
  final IconData icon;

  /// Creates a [PlaceholderScreen] widget
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon!',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Explore Features'),
            ),
          ],
        ),
      ),
    );
  }
}
