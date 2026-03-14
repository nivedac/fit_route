import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for generating AI-powered workout and diet plans
/// using the NVIDIA OpenAI-compatible API.
class AiService {
  static const String _baseUrl = 'https://integrate.api.nvidia.com/v1';
  static const String _model = 'openai/gpt-oss-20b';

  // TODO: Replace with your actual NVIDIA API key
  static const String _apiKey = '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';

  /// Generates a personalized workout and diet plan based on user metrics.
  ///
  /// Returns a [Map] with 'workout' and 'diet' keys containing the parsed plan data,
  /// or null on failure.
  static Future<Map<String, dynamic>?> generatePlan({
    required double height,
    required double weight,
    required double goalWeight,
    required String duration,
    required String gender,
    required String workoutMode,
    required String intensity,
    required String dietPreference,
    required List<String> availableFoods,
  }) async {
    final prompt = _buildPrompt(
      height: height,
      weight: weight,
      goalWeight: goalWeight,
      duration: duration,
      gender: gender,
      workoutMode: workoutMode,
      intensity: intensity,
      dietPreference: dietPreference,
      availableFoods: availableFoods,
    );

    try {
      final response = await _callApi(prompt);
      if (response != null) {
        return _parseResponse(response);
      }
    } catch (e) {
      debugPrint('AI Service Error: $e');
    }
    return null;
  }

  /// Build the prompt for AI plan generation.
  static String _buildPrompt({
    required double height,
    required double weight,
    required double goalWeight,
    required String duration,
    required String gender,
    required String workoutMode,
    required String intensity,
    required String dietPreference,
    required List<String> availableFoods,
  }) {
    return '''Create a personalized workout and diet plan. Return the response ONLY as a valid JSON object with no additional text, markdown, or explanation.

User details:
- Height: ${height.toStringAsFixed(0)} cm
- Weight: ${weight.toStringAsFixed(0)} kg
- Goal Weight: ${goalWeight.toStringAsFixed(0)} kg
- Duration: $duration
- Gender: $gender
- Workout Mode: $workoutMode
- Intensity Level: $intensity
- Diet Preference: $dietPreference
- Available Foods: ${availableFoods.join(', ')}

Return this exact JSON structure:
{
  "dailyCalories": 2000,
  "macros": {
    "protein": {"grams": 150, "percentage": 30},
    "carbs": {"grams": 250, "percentage": 50},
    "fats": {"grams": 45, "percentage": 20}
  },
  "workout": {
    "weeklySchedule": [
      {
        "day": "Monday",
        "sessionName": "Upper Body Strength",
        "duration": "45 mins",
        "difficulty": "Intermediate",
        "exercises": [
          {"name": "Push-ups", "sets": 3, "reps": "12", "rest": "60s"},
          {"name": "Dumbbell Rows", "sets": 3, "reps": "10", "rest": "60s"}
        ]
      }
    ]
  },
  "diet": {
    "meals": [
      {
        "type": "Breakfast",
        "name": "Protein Oatmeal Bowl",
        "calories": 450,
        "protein": 30,
        "carbs": 55,
        "fats": 12,
        "items": ["Oats", "Eggs", "Banana"]
      },
      {
        "type": "Lunch",
        "name": "Grilled Chicken Plate",
        "calories": 650,
        "protein": 45,
        "carbs": 60,
        "fats": 18,
        "items": ["Chicken Breast", "Rice", "Broccoli"]
      },
      {
        "type": "Dinner",
        "name": "Lean Dinner Bowl",
        "calories": 550,
        "protein": 40,
        "carbs": 50,
        "fats": 15,
        "items": ["Fish", "Sweet Potato", "Salad"]
      },
      {
        "type": "Snack",
        "name": "Recovery Snack",
        "calories": 250,
        "protein": 20,
        "carbs": 25,
        "fats": 8,
        "items": ["Greek Yogurt", "Mixed Berries"]
      }
    ]
  }
}

Provide a complete 7-day workout schedule and realistic nutritional values. Adjust all values based on the user's details above. Use ONLY the available foods listed.''';
  }

  /// Calls the NVIDIA OpenAI-compatible API with streaming disabled for simplicity.
  static Future<String?> _callApi(String prompt) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');

      final body = jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional fitness coach and nutritionist. You always respond with valid JSON only, no markdown or extra text.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'top_p': 1,
        'max_tokens': 4096,
        'stream': false,
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        return content as String?;
      } else {
        debugPrint('API Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('HTTP Error: $e');
      return null;
    }
  }

  /// Parses the raw AI response string into structured plan data.
  /// Handles cases where the AI wraps JSON in markdown code blocks.
  static Map<String, dynamic>? _parseResponse(String raw) {
    try {
      // Remove any markdown code block wrapping
      String cleaned = raw.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return parsed;
    } catch (e) {
      debugPrint('JSON Parse Error: $e');
      debugPrint('Raw response: $raw');

      // Fallback: return a default plan if parsing fails
      return getDefaultPlan();
    }
  }

  /// Returns a sensible default plan when AI fails or returns invalid data.
  static Map<String, dynamic> getDefaultPlan() {
    return {
      'dailyCalories': 2200,
      'macros': {
        'protein': {'grams': 165, 'percentage': 30},
        'carbs': {'grams': 275, 'percentage': 50},
        'fats': {'grams': 49, 'percentage': 20},
      },
      'workout': {
        'weeklySchedule': [
          {
            'day': 'Monday',
            'sessionName': 'Upper Body Push',
            'duration': '45 mins',
            'difficulty': 'Intermediate',
            'exercises': [
              {'name': 'Push-ups', 'sets': 3, 'reps': '15', 'rest': '60s'},
              {'name': 'Shoulder Press', 'sets': 3, 'reps': '12', 'rest': '60s'},
              {'name': 'Tricep Dips', 'sets': 3, 'reps': '12', 'rest': '45s'},
              {'name': 'Lateral Raises', 'sets': 3, 'reps': '15', 'rest': '45s'},
            ],
          },
          {
            'day': 'Tuesday',
            'sessionName': 'Lower Body',
            'duration': '40 mins',
            'difficulty': 'Intermediate',
            'exercises': [
              {'name': 'Squats', 'sets': 4, 'reps': '12', 'rest': '90s'},
              {'name': 'Lunges', 'sets': 3, 'reps': '10 each', 'rest': '60s'},
              {'name': 'Calf Raises', 'sets': 3, 'reps': '20', 'rest': '45s'},
              {'name': 'Glute Bridges', 'sets': 3, 'reps': '15', 'rest': '60s'},
            ],
          },
          {
            'day': 'Wednesday',
            'sessionName': 'Active Recovery',
            'duration': '30 mins',
            'difficulty': 'Easy',
            'exercises': [
              {'name': 'Yoga Flow', 'sets': 1, 'reps': '15 mins', 'rest': '-'},
              {'name': 'Foam Rolling', 'sets': 1, 'reps': '10 mins', 'rest': '-'},
              {'name': 'Light Stretching', 'sets': 1, 'reps': '5 mins', 'rest': '-'},
            ],
          },
          {
            'day': 'Thursday',
            'sessionName': 'Upper Body Pull',
            'duration': '45 mins',
            'difficulty': 'Intermediate',
            'exercises': [
              {'name': 'Pull-ups / Band Pulls', 'sets': 3, 'reps': '8-10', 'rest': '90s'},
              {'name': 'Bent-over Rows', 'sets': 3, 'reps': '12', 'rest': '60s'},
              {'name': 'Bicep Curls', 'sets': 3, 'reps': '12', 'rest': '45s'},
              {'name': 'Face Pulls', 'sets': 3, 'reps': '15', 'rest': '45s'},
            ],
          },
          {
            'day': 'Friday',
            'sessionName': 'Full Body HIIT',
            'duration': '35 mins',
            'difficulty': 'Advanced',
            'exercises': [
              {'name': 'Burpees', 'sets': 4, 'reps': '10', 'rest': '30s'},
              {'name': 'Mountain Climbers', 'sets': 4, 'reps': '20', 'rest': '30s'},
              {'name': 'Jump Squats', 'sets': 3, 'reps': '15', 'rest': '45s'},
              {'name': 'Plank Hold', 'sets': 3, 'reps': '45s', 'rest': '30s'},
            ],
          },
          {
            'day': 'Saturday',
            'sessionName': 'Core & Mobility',
            'duration': '30 mins',
            'difficulty': 'Intermediate',
            'exercises': [
              {'name': 'Plank Variations', 'sets': 3, 'reps': '30s each', 'rest': '30s'},
              {'name': 'Russian Twists', 'sets': 3, 'reps': '20', 'rest': '30s'},
              {'name': 'Leg Raises', 'sets': 3, 'reps': '15', 'rest': '30s'},
              {'name': 'Dead Bugs', 'sets': 3, 'reps': '12 each', 'rest': '30s'},
            ],
          },
          {
            'day': 'Sunday',
            'sessionName': 'Rest Day',
            'duration': '0 mins',
            'difficulty': 'Rest',
            'exercises': [
              {'name': 'Rest & Recovery', 'sets': 0, 'reps': '-', 'rest': '-'},
            ],
          },
        ],
      },
      'diet': {
        'meals': [
          {
            'type': 'Breakfast',
            'name': 'Power Oatmeal Bowl',
            'calories': 450,
            'protein': 30,
            'carbs': 55,
            'fats': 12,
            'items': ['Rolled Oats', 'Eggs', 'Mixed Berries'],
          },
          {
            'type': 'Lunch',
            'name': 'Grilled Chicken Rice Bowl',
            'calories': 650,
            'protein': 45,
            'carbs': 70,
            'fats': 18,
            'items': ['Chicken Breast', 'Basmati Rice', 'Broccoli'],
          },
          {
            'type': 'Dinner',
            'name': 'Balanced Dinner Plate',
            'calories': 550,
            'protein': 40,
            'carbs': 50,
            'fats': 15,
            'items': ['Chicken Breast', 'Sweet Potato', 'Spinach'],
          },
          {
            'type': 'Snack',
            'name': 'Recovery Snack',
            'calories': 250,
            'protein': 18,
            'carbs': 28,
            'fats': 8,
            'items': ['Mixed Berries', 'Greek Yogurt'],
          },
        ],
      },
    };
  }
}
