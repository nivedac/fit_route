import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/goal_setup_screen.dart';
import 'screens/workout_selection_screen.dart';
import 'screens/difficulty_selection_screen.dart';
import 'screens/diet_selection_screen.dart';
import 'screens/food_selection_screen.dart';
import 'screens/generating_plan_screen.dart';
import 'screens/plan_result_screen.dart';
import 'screens/terms_conditions_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const FitRouteApp(),
    ),
  );
}

class FitRouteApp extends StatelessWidget {
  const FitRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitRoute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/goal-setup': (context) => const GoalSetupScreen(),
        '/workout-selection': (context) => const WorkoutSelectionScreen(),
        '/difficulty-selection': (context) => const DifficultySelectionScreen(),
        '/diet-selection': (context) => const DietSelectionScreen(),
        '/food-selection': (context) => const FoodSelectionScreen(),
        '/generating-plan': (context) => const GeneratingPlanScreen(),
        '/plan-result': (context) => const PlanResultScreen(),
        '/terms': (context) => const TermsConditionsScreen(),
        '/home': (context) => const HomeDashboardScreen(),
        '/tracker': (context) => const TrackerScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
