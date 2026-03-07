import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'theme.dart';
import 'app/auth_gate.dart';
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
import 'screens/tracker_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/main_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'screens/meal_detail_screen.dart';
import 'screens/active_workout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      onGenerateRoute: (settings) {
        // Handle routes that need arguments
        switch (settings.name) {
          case '/workout-detail':
            final args = settings.arguments as Map<String, String>? ?? {};
            return MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(
                title: args['title'] ?? 'Core Stability',
                duration: args['duration'] ?? '15 MINS',
                difficulty: args['difficulty'] ?? 'INTERMEDIATE',
              ),
            );
          case '/meal-detail':
            final args = settings.arguments as Map<String, String>? ?? {};
            return MaterialPageRoute(
              builder: (_) => MealDetailScreen(
                title: args['title'] ?? 'Protein-Rich Breakfast',
                calories: args['calories'] ?? '450 kcal',
              ),
            );
          case '/main':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const MainScreen(),
            );
          default:
            return null; // Fallback to routes map
        }
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth-gate': (context) => const AuthGate(),
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
        '/home': (context) => const MainScreen(),
        '/tracker': (context) => const TrackerScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/privacy-security': (context) => const PrivacySecurityScreen(),
        '/active-workout': (context) => const ActiveWorkoutScreen(),
      },
    );
  }
}
