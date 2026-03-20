import 'package:fit_route/services/ai_service.dart';

void main() async {
  print('Starting API test...');
  final result = await AiService.generatePlan(
    height: 180,
    weight: 80,
    goalWeight: 75,
    duration: '12 weeks',
    gender: 'Male',
    workoutMode: 'Gym',
    intensity: 'Intermediate',
    dietPreference: 'Non-veg',
    availableFoods: ['Chicken', 'Rice', 'Oats', 'Eggs'],
    age: 25,
  );
  if (result != null) {
      print('Parsed successfully!');
      print(result);
  } else {
      print('Failed to parse or null');
  }
}
