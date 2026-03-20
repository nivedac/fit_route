import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for generating AI-powered workout and diet plans
/// using the Google Gemini API (REST).
class AiService {
  // Gemini API configuration
  static const String _apiKey = 'AIzaSyBGHJzWVOST-K47EXVclBPB5RXHuH5zypo';
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Generates a personalized workout and diet plan based on user metrics.
  ///
  /// Returns a [Map] with the full parsed plan data, or null on failure.
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
    required int age,
  }) async {
    // Determine goal from weight difference
    final String goal;
    if (goalWeight < weight - 2) {
      goal = 'Fat Loss';
    } else if (goalWeight > weight + 2) {
      goal = 'Muscle Gain';
    } else {
      goal = 'Maintenance';
    }

    // Determine activity level from intensity
    final String activityLevel;
    switch (intensity.toLowerCase()) {
      case 'beginner':
        activityLevel = 'Lightly Active';
        break;
      case 'intermediate':
        activityLevel = 'Moderately Active';
        break;
      case 'advanced':
        activityLevel = 'Very Active';
        break;
      default:
        activityLevel = 'Moderately Active';
    }

    // Determine workout type (home vs gym)
    final String workoutType;
    if (workoutMode.toLowerCase().contains('home')) {
      workoutType = 'home';
    } else if (workoutMode.toLowerCase().contains('gym')) {
      workoutType = 'gym';
    } else if (workoutMode.toLowerCase().contains('outdoor')) {
      workoutType = 'outdoor';
    } else {
      workoutType = 'home';
    }

    final prompt = _buildPrompt(
      height: height,
      weight: weight,
      goalWeight: goalWeight,
      duration: duration,
      gender: gender,
      workoutType: workoutType,
      workoutMode: workoutMode,
      intensity: intensity,
      dietPreference: dietPreference,
      availableFoods: availableFoods,
      age: age,
      goal: goal,
      activityLevel: activityLevel,
    );

    try {
      debugPrint('=== AI SERVICE: Sending prompt to Gemini ===');
      debugPrint('User data: age=$age, gender=$gender, height=$height, weight=$weight, goal=$goal');
      debugPrint('Workout: type=$workoutType, mode=$workoutMode, intensity=$intensity');
      debugPrint('Diet: pref=$dietPreference, foods=${availableFoods.join(", ")}');
      
      final response = await _callGeminiApi(prompt);
      if (response != null) {
        debugPrint('=== AI SERVICE: Got response from Gemini ===');
        return _parseResponse(response);
      }
    } catch (e) {
      debugPrint('AI Service Error: $e');
    }
    return null;
  }

  /// Build the dynamic prompt for Gemini API.
  static String _buildPrompt({
    required double height,
    required double weight,
    required double goalWeight,
    required String duration,
    required String gender,
    required String workoutType,
    required String workoutMode,
    required String intensity,
    required String dietPreference,
    required List<String> availableFoods,
    required int age,
    required String goal,
    required String activityLevel,
  }) {
    return '''You are an advanced AI fitness coach inside the FitRoute app.

CRITICAL RULES:
- Every response MUST be UNIQUE based on the user input below
- DO NOT return constant or generic values
- All calculations MUST be done using the EXACT numbers provided
- DO NOT give the same plan to different users

INPUT DATA:
- Age: $age years
- Gender: $gender
- Height: ${height.toStringAsFixed(0)} cm
- Weight: ${weight.toStringAsFixed(0)} kg
- Goal Weight: ${goalWeight.toStringAsFixed(0)} kg
- Goal: $goal
- Activity Level: $activityLevel
- Duration: $duration
- Workout Type: $workoutType ($workoutMode)
- Workout Intensity: $intensity
- Food Preference: $dietPreference
- Available Foods: ${availableFoods.join(', ')}

--------------------------------------------------

STEP 1: CALCULATIONS (MUST CHANGE PER USER — use the EXACT input numbers)

1. Calculate BMI = weight / (height_in_meters)^2
   - Height in meters = ${height.toStringAsFixed(0)} / 100 = ${(height / 100).toStringAsFixed(2)}
   - BMI = ${weight.toStringAsFixed(0)} / (${(height / 100).toStringAsFixed(2)})^2
   - Round to 1 decimal place

2. Calculate BMR using Mifflin-St Jeor equation:
   - Male: BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
   - Female: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161

3. Calculate TDEE = BMR × activity multiplier:
   - Sedentary = 1.2
   - Lightly Active = 1.375
   - Moderately Active = 1.55
   - Very Active = 1.725

4. Goal-adjusted calories:
   - Fat Loss: TDEE - 400 to -500 kcal
   - Muscle Gain: TDEE + 300 to +400 kcal
   - Maintenance: same as TDEE

5. Calculate macros dynamically:
   - Protein: 1.6-2.2g per kg bodyweight
   - Fats: 25% of total calories ÷ 9
   - Carbs: remaining calories ÷ 4

--------------------------------------------------

STEP 2: WORKOUT PLAN (STRICT EQUIPMENT LOGIC)

${workoutType == 'home' ? '''WORKOUT TYPE IS HOME — STRICT RULES:
- Use ONLY bodyweight exercises (push-ups, squats, lunges, planks, burpees, mountain climbers, etc.)
- NO gym equipment whatsoever (no dumbbells, barbells, machines, cables)
- Can include resistance bands only if mentioned
- Focus on calisthenics and bodyweight movements''' : workoutType == 'gym' ? '''WORKOUT TYPE IS GYM — STRICT RULES:
- Use gym equipment (dumbbells, barbells, machines, cables, bench, pull-up bar)
- Include compound movements (bench press, deadlift, squat, overhead press)
- DO NOT specify exact weight (kg)
- Instead use intensity cues: "light", "moderate", "heavy", or "choose weight that challenges last 2 reps"''' : '''WORKOUT TYPE IS OUTDOOR — STRICT RULES:
- Use outdoor exercises (running, sprints, park bench exercises, hill training, bodyweight)
- Can mix bodyweight with outdoor terrain features
- Include cardio-heavy exercises'''}

- Intensity level is "$intensity" — adjust volume and difficulty accordingly:
  - Beginner: fewer sets (2-3), lower reps, longer rest
  - Intermediate: moderate sets (3-4), moderate reps
  - Advanced: higher sets (4-5), higher reps, shorter rest, supersets

- Plan MUST include:
  - 7-day weekly split (Monday to Sunday)
  - Each day with a specific focus (e.g., Upper Body, Lower Body, Core, Cardio, Rest)
  - At least 1-2 rest/active recovery days
  - 4-6 exercises per training day
  - Sets and reps for each exercise

--------------------------------------------------

STEP 3: DIET PLAN (STRICT FOOD PREFERENCE)

- Food preference is "$dietPreference" — follow STRICTLY:
  - Vegetarian: NO meat, NO fish, NO eggs (use paneer, dal, soya, tofu, milk, curd)
  - Non-Vegetarian: Can include chicken, eggs, fish, mutton along with veg items
  - Vegan: NO dairy, NO eggs, NO meat (use soya, tofu, legumes, nuts, seeds)

- Use INDIAN foods primarily (dal, roti, rice, sabzi, paratha, idli, dosa, poha, upma, etc.)
- Prioritize user's available foods: ${availableFoods.join(', ')}
- Total meal calories MUST align with the goal-adjusted calorie target
- Ensure protein intake is at least 1.2g per kg bodyweight
- Include portion sizes (e.g., "150g Paneer Tikka", "2 Roti", "1 Bowl Dal")

Meals required:
  - Breakfast
  - Lunch
  - Dinner
  - Snacks (2 items)

--------------------------------------------------

OUTPUT FORMAT (STRICT JSON — return ONLY this, no other text):

{
  "bmi": "<calculated BMI as string>",
  "bmr": "<calculated BMR as string>",
  "tdee": "<calculated TDEE as string>",
  "target_calories": "<goal-adjusted calories as string>",
  "macros": {
    "protein": "<grams>g",
    "carbs": "<grams>g",
    "fats": "<grams>g"
  },
  "workout_plan": [
    {
      "day": "Monday",
      "type": "$workoutType",
      "focus": "<muscle group or theme>",
      "exercises": [
        {
          "name": "<exercise name>",
          "sets": "<number>",
          "reps": "<number or duration>",
          "intensity": "<light/moderate/heavy or bodyweight>"
        }
      ]
    }
  ],
  "diet_plan": {
    "calories": "<same as target_calories>",
    "macros": {
      "protein": "<grams>g",
      "carbs": "<grams>g",
      "fats": "<grams>g"
    },
    "meals": {
      "breakfast": ["<item with portion>", "<item>"],
      "lunch": ["<item with portion>", "<item>"],
      "dinner": ["<item with portion>", "<item>"],
      "snacks": ["<item>", "<item>"]
    }
  }
}

FINAL STRICT RULES:
- Return ONLY raw JSON. NO markdown. NO backticks. NO explanation.
- All values MUST be calculated from the EXACT user input numbers.
- Values MUST differ when input changes.
- workout_plan MUST have exactly 7 entries (Monday-Sunday).
- All numeric values in JSON must be STRING type.
- Exercise names must match the workout type ($workoutType).''';
  }

  /// Calls the Google Gemini API via REST.
  static Future<String?> _callGeminiApi(String prompt) async {
    try {
      final uri = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.9,
          'topP': 0.95,
          'topK': 40,
          'maxOutputTokens': 8192,
          'responseMimeType': 'application/json',
        },
      });

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String?;
          }
        }
        debugPrint('Gemini API: No candidates in response');
        return null;
      } else {
        debugPrint('Gemini API Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Gemini HTTP Error: $e');
      return null;
    }
  }

  /// Parses the raw AI response string into structured plan data.
  static Map<String, dynamic>? _parseResponse(String raw) {
    try {
      String jsonString = raw.trim();

      // Clean up markdown code blocks if AI ignores instructions
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      } else if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }

      jsonString = jsonString.trim();

      // Extract JSON from braces
      final startIndex = jsonString.indexOf('{');
      final endIndex = jsonString.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        jsonString = jsonString.substring(startIndex, endIndex + 1);
      }

      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate required keys
      if (!parsed.containsKey('workout_plan') ||
          !parsed.containsKey('diet_plan')) {
        throw FormatException(
            'Generated JSON missing required keys (workout_plan, diet_plan)');
      }

      // Convert to the format expected by the UI
      return _normalizeResponse(parsed);
    } catch (e) {
      debugPrint('JSON Parse Error: $e');
      debugPrint('Raw response: $raw');
      return null;
    }
  }

  /// Normalizes the Gemini response into a unified format
  /// that the UI can consume consistently.
  static Map<String, dynamic> _normalizeResponse(Map<String, dynamic> parsed) {
    // Parse calculated values from new format
    final bmi = parsed['bmi']?.toString() ?? '0';
    final bmr = parsed['bmr']?.toString() ?? '0';
    final tdee = parsed['tdee']?.toString() ?? '0';
    final targetCalories = parsed['target_calories']?.toString() ?? '0';

    // Parse top-level macros
    final topMacros = parsed['macros'] as Map<String, dynamic>? ?? {};

    // Parse diet plan
    final dietPlan = parsed['diet_plan'] as Map<String, dynamic>? ?? {};
    final dietMacros = dietPlan['macros'] as Map<String, dynamic>? ?? topMacros;

    final proteinStr = dietMacros['protein']?.toString() ?? topMacros['protein']?.toString() ?? '0g';
    final carbsStr = dietMacros['carbs']?.toString() ?? topMacros['carbs']?.toString() ?? '0g';
    final fatsStr = dietMacros['fats']?.toString() ?? topMacros['fats']?.toString() ?? '0g';

    final proteinG = _extractNumber(proteinStr);
    final carbsG = _extractNumber(carbsStr);
    final fatsG = _extractNumber(fatsStr);

    final totalMacroG = proteinG + carbsG + fatsG;
    final proteinPct =
        totalMacroG > 0 ? ((proteinG / totalMacroG) * 100).round() : 30;
    final carbsPct =
        totalMacroG > 0 ? ((carbsG / totalMacroG) * 100).round() : 50;
    final fatsPct =
        totalMacroG > 0 ? ((fatsG / totalMacroG) * 100).round() : 20;

    // Parse workout plan
    final workoutPlan = parsed['workout_plan'] as List<dynamic>? ?? [];
    final weeklySchedule = workoutPlan.map((day) {
      final d = day as Map<String, dynamic>;
      final exercises = (d['exercises'] as List<dynamic>? ?? []).map((ex) {
        final e = ex as Map<String, dynamic>;
        return {
          'name': e['name']?.toString() ?? 'Exercise',
          'sets': _extractNumber(e['sets']?.toString() ?? '3').toInt(),
          'reps': e['reps']?.toString() ?? '12',
          'rest': '60s',
          'intensity': e['intensity']?.toString() ?? '',
        };
      }).toList();

      return {
        'day': d['day']?.toString() ?? 'Day',
        'sessionName': d['focus']?.toString() ?? 'Workout',
        'type': d['type']?.toString() ?? 'home',
        'duration': '${(exercises.length * 5 + 10)} mins',
        'difficulty': 'Intermediate',
        'exercises': exercises,
      };
    }).toList();

    // Parse meals
    final mealsData = dietPlan['meals'] as Map<String, dynamic>? ?? {};
    final breakfastItems = (mealsData['breakfast'] as List<dynamic>? ?? []);
    final lunchItems = (mealsData['lunch'] as List<dynamic>? ?? []);
    final dinnerItems = (mealsData['dinner'] as List<dynamic>? ?? []);
    final snackItems = (mealsData['snacks'] as List<dynamic>? ?? []);

    final goalCal = int.tryParse(targetCalories.replaceAll(RegExp(r'[^0-9]'), '')) ?? 2000;

    final meals = [
      _buildMealEntry('Breakfast', breakfastItems, (goalCal * 0.25).round()),
      _buildMealEntry('Lunch', lunchItems, (goalCal * 0.35).round()),
      _buildMealEntry('Dinner', dinnerItems, (goalCal * 0.30).round()),
      _buildMealEntry('Snack', snackItems, (goalCal * 0.10).round()),
    ];

    debugPrint('=== NORMALIZED PLAN ===');
    debugPrint('BMI: $bmi, BMR: $bmr, TDEE: $tdee, Target: $targetCalories');
    debugPrint('Macros: P=${proteinG}g, C=${carbsG}g, F=${fatsG}g');
    debugPrint('Workout days: ${weeklySchedule.length}');
    debugPrint('Meals: ${meals.length}');

    return {
      // New fields from Gemini
      'bmi': bmi,
      'bmr': bmr,
      'tdeeCalories': tdee,
      'goalAdjustedCalories': targetCalories,

      // Backward-compatible fields for existing UI
      'dailyCalories': goalCal,
      'macros': {
        'protein': {'grams': proteinG.toInt(), 'percentage': proteinPct},
        'carbs': {'grams': carbsG.toInt(), 'percentage': carbsPct},
        'fats': {'grams': fatsG.toInt(), 'percentage': fatsPct},
      },
      'workout': {
        'weeklySchedule': weeklySchedule,
      },
      'diet': {
        'meals': meals,
      },
    };
  }

  /// Build a meal entry from a list of food items.
  static Map<String, dynamic> _buildMealEntry(
      String type, List<dynamic> foodItems, int estimatedCalories) {
    final items = foodItems.map((item) {
      return {
        'item': item.toString(),
        'grams': '',
        'calories': '',
      };
    }).toList();

    // Distribute macros proportionally
    final protein = (estimatedCalories * 0.30 / 4).round(); // 30% protein
    final carbs = (estimatedCalories * 0.50 / 4).round(); // 50% carbs
    final fats = (estimatedCalories * 0.20 / 9).round(); // 20% fats

    return {
      'type': type,
      'name': _getMealName(type, foodItems),
      'calories': estimatedCalories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'items': items,
    };
  }

  /// Generate a descriptive meal name from food items.
  static String _getMealName(String type, List<dynamic> items) {
    if (items.isEmpty) return '$type Meal';
    // Use first 2 items for the name
    final nameItems = items.take(2).map((e) {
      final s = e.toString();
      // Remove quantity prefixes like "2 " or "150g "
      return s.replaceAll(RegExp(r'^\d+\s*g?\s*'), '');
    }).join(' & ');
    return nameItems.isEmpty ? '$type Meal' : nameItems;
  }

  /// Extract a numeric value from a string like "120g" or "55".
  static double _extractNumber(String s) {
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(s);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  /// Returns a dynamically calculated fallback plan when AI fails.
  /// Uses the SAME user data to compute BMI, BMR, TDEE, and macros
  /// so that every user gets unique values even on API failure.
  static Map<String, dynamic> getCalculatedFallbackPlan({
    required double height,
    required double weight,
    required double goalWeight,
    required String duration,
    required String gender,
    required String workoutMode,
    required String intensity,
    required String dietPreference,
    required List<String> availableFoods,
    required int age,
  }) {
    // ---------- CALCULATE BMI ----------
    final heightM = height / 100.0;
    final bmi = weight / (heightM * heightM);

    // ---------- CALCULATE BMR (Mifflin-St Jeor) ----------
    double bmr;
    if (gender.toLowerCase() == 'female') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    }

    // ---------- CALCULATE TDEE ----------
    double activityMultiplier;
    switch (intensity.toLowerCase()) {
      case 'beginner':
        activityMultiplier = 1.375;
        break;
      case 'advanced':
        activityMultiplier = 1.725;
        break;
      default: // intermediate
        activityMultiplier = 1.55;
    }
    final tdee = bmr * activityMultiplier;

    // ---------- GOAL-ADJUSTED CALORIES ----------
    double targetCal;
    if (goalWeight < weight - 2) {
      // Fat Loss
      targetCal = tdee - 450;
    } else if (goalWeight > weight + 2) {
      // Muscle Gain
      targetCal = tdee + 350;
    } else {
      // Maintenance
      targetCal = tdee;
    }
    final int goalCalInt = targetCal.round();

    // ---------- MACROS ----------
    final proteinG = (weight * 1.8).round(); // 1.8g/kg
    final fatsG = (targetCal * 0.25 / 9).round(); // 25% cal from fats
    final carbsG = ((targetCal - (proteinG * 4) - (fatsG * 9)) / 4).round();
    final totalMacroG = proteinG + carbsG + fatsG;
    final proteinPct = totalMacroG > 0 ? ((proteinG / totalMacroG) * 100).round() : 30;
    final carbsPct = totalMacroG > 0 ? ((carbsG / totalMacroG) * 100).round() : 50;
    final fatsPct = totalMacroG > 0 ? ((fatsG / totalMacroG) * 100).round() : 20;

    // ---------- WORKOUT TYPE ----------
    final bool isGym = workoutMode.toLowerCase().contains('gym');
    final String wType = isGym ? 'gym' : 'home';

    // Dynamic exercise sets based on intensity
    int baseSets;
    switch (intensity.toLowerCase()) {
      case 'beginner':
        baseSets = 2;
        break;
      case 'advanced':
        baseSets = 4;
        break;
      default:
        baseSets = 3;
    }

    // Build workout schedule
    final weeklySchedule = _buildFallbackWorkout(wType, baseSets, intensity);

    // ---------- DIET PLAN ----------
    final meals = _buildFallbackDiet(goalCalInt, dietPreference, availableFoods);

    debugPrint('=== CALCULATED FALLBACK PLAN ===');
    debugPrint('BMI: ${bmi.toStringAsFixed(1)}, BMR: ${bmr.round()}, TDEE: ${tdee.round()}, Target: $goalCalInt');
    debugPrint('Macros: P=${proteinG}g, C=${carbsG}g, F=${fatsG}g');

    return {
      'bmi': bmi.toStringAsFixed(1),
      'bmr': bmr.round().toString(),
      'tdeeCalories': tdee.round().toString(),
      'goalAdjustedCalories': goalCalInt.toString(),
      'dailyCalories': goalCalInt,
      'macros': {
        'protein': {'grams': proteinG, 'percentage': proteinPct},
        'carbs': {'grams': carbsG, 'percentage': carbsPct},
        'fats': {'grams': fatsG, 'percentage': fatsPct},
      },
      'workout': {
        'weeklySchedule': weeklySchedule,
      },
      'diet': {
        'meals': meals,
      },
    };
  }

  /// Builds a fallback workout based on type (home/gym) and intensity.
  static List<Map<String, dynamic>> _buildFallbackWorkout(
      String workoutType, int sets, String intensity) {
    final isGym = workoutType == 'gym';
    final rest = intensity.toLowerCase() == 'beginner' ? '90s' : '60s';
    final diff = intensity.isNotEmpty
        ? '${intensity[0].toUpperCase()}${intensity.substring(1).toLowerCase()}'
        : 'Intermediate';

    if (isGym) {
      return [
        _wDay('Monday', 'Chest & Triceps', 'gym', diff, [
          _ex('Barbell Bench Press', sets, '10', rest, 'moderate'),
          _ex('Incline Dumbbell Press', sets, '12', rest, 'moderate'),
          _ex('Cable Flyes', sets, '15', rest, 'light'),
          _ex('Tricep Pushdowns', sets, '12', rest, 'moderate'),
          _ex('Overhead Tricep Extension', sets, '12', rest, 'moderate'),
        ]),
        _wDay('Tuesday', 'Back & Biceps', 'gym', diff, [
          _ex('Deadlift', sets, '8', rest, 'heavy'),
          _ex('Lat Pulldown', sets, '12', rest, 'moderate'),
          _ex('Seated Cable Row', sets, '12', rest, 'moderate'),
          _ex('Barbell Curl', sets, '12', rest, 'moderate'),
          _ex('Hammer Curls', sets, '12', rest, 'moderate'),
        ]),
        _wDay('Wednesday', 'Active Recovery', 'gym', 'Easy', [
          _ex('Treadmill Walk', 1, '15 mins', '-', 'light'),
          _ex('Stretching', 1, '10 mins', '-', 'light'),
        ]),
        _wDay('Thursday', 'Shoulders & Abs', 'gym', diff, [
          _ex('Overhead Press', sets, '10', rest, 'moderate'),
          _ex('Lateral Raises', sets, '15', rest, 'light'),
          _ex('Face Pulls', sets, '15', rest, 'light'),
          _ex('Cable Crunches', sets, '15', rest, 'moderate'),
          _ex('Hanging Leg Raises', sets, '12', rest, 'moderate'),
        ]),
        _wDay('Friday', 'Legs', 'gym', diff, [
          _ex('Barbell Squat', sets, '10', rest, 'heavy'),
          _ex('Leg Press', sets, '12', rest, 'moderate'),
          _ex('Romanian Deadlift', sets, '10', rest, 'moderate'),
          _ex('Leg Curls', sets, '12', rest, 'moderate'),
          _ex('Calf Raises (Machine)', sets, '15', rest, 'moderate'),
        ]),
        _wDay('Saturday', 'Full Body', 'gym', diff, [
          _ex('Pull-ups', sets, '8', rest, 'bodyweight'),
          _ex('Dumbbell Lunges', sets, '10 each', rest, 'moderate'),
          _ex('Dumbbell Shoulder Press', sets, '12', rest, 'moderate'),
          _ex('Plank Hold', sets, '45s', '30s', 'bodyweight'),
        ]),
        _wDay('Sunday', 'Rest Day', 'gym', 'Rest', [
          _ex('Rest & Recovery', 0, '-', '-', 'rest'),
        ]),
      ];
    } else {
      return [
        _wDay('Monday', 'Upper Body Push', 'home', diff, [
          _ex('Push-ups', sets, '15', rest, 'bodyweight'),
          _ex('Pike Push-ups', sets, '12', rest, 'bodyweight'),
          _ex('Tricep Dips (Chair)', sets, '12', rest, 'bodyweight'),
          _ex('Diamond Push-ups', sets, '10', rest, 'bodyweight'),
        ]),
        _wDay('Tuesday', 'Lower Body', 'home', diff, [
          _ex('Bodyweight Squats', sets + 1, '15', rest, 'bodyweight'),
          _ex('Walking Lunges', sets, '10 each', rest, 'bodyweight'),
          _ex('Calf Raises', sets, '20', rest, 'bodyweight'),
          _ex('Glute Bridges', sets, '15', rest, 'bodyweight'),
        ]),
        _wDay('Wednesday', 'Active Recovery', 'home', 'Easy', [
          _ex('Yoga Flow', 1, '15 mins', '-', 'light'),
          _ex('Light Stretching', 1, '10 mins', '-', 'light'),
        ]),
        _wDay('Thursday', 'Upper Body Pull', 'home', diff, [
          _ex('Inverted Rows (Table)', sets, '10', rest, 'bodyweight'),
          _ex('Superman Holds', sets, '12', rest, 'bodyweight'),
          _ex('Towel Bicep Curls', sets, '12', rest, 'bodyweight'),
          _ex('Reverse Snow Angels', sets, '15', rest, 'bodyweight'),
        ]),
        _wDay('Friday', 'Full Body HIIT', 'home', diff, [
          _ex('Burpees', sets, '10', '30s', 'heavy'),
          _ex('Mountain Climbers', sets, '20', '30s', 'heavy'),
          _ex('Jump Squats', sets, '15', rest, 'heavy'),
          _ex('Plank Hold', sets, '45s', '30s', 'moderate'),
        ]),
        _wDay('Saturday', 'Core & Mobility', 'home', diff, [
          _ex('Plank Variations', sets, '30s each', '30s', 'moderate'),
          _ex('Russian Twists', sets, '20', '30s', 'moderate'),
          _ex('Leg Raises', sets, '15', '30s', 'moderate'),
          _ex('Dead Bugs', sets, '12 each', '30s', 'moderate'),
        ]),
        _wDay('Sunday', 'Rest Day', 'home', 'Rest', [
          _ex('Rest & Recovery', 0, '-', '-', 'rest'),
        ]),
      ];
    }
  }

  /// Helper to build a workout day entry.
  static Map<String, dynamic> _wDay(String day, String sessionName,
      String type, String difficulty, List<Map<String, dynamic>> exercises) {
    return {
      'day': day,
      'sessionName': sessionName,
      'type': type,
      'duration': '${(exercises.length * 5 + 10)} mins',
      'difficulty': difficulty,
      'exercises': exercises,
    };
  }

  /// Helper to build an exercise entry.
  static Map<String, dynamic> _ex(
      String name, int sets, String reps, String rest, String intensity) {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'intensity': intensity,
    };
  }

  /// Builds a fallback diet plan using user's available foods and calorie target.
  static List<Map<String, dynamic>> _buildFallbackDiet(
      int targetCal, String dietPref, List<String> availableFoods) {
    final isVeg = dietPref.toLowerCase().contains('veg') &&
        !dietPref.toLowerCase().contains('non');

    // Distribute calories across meals
    final bfCal = (targetCal * 0.25).round();
    final lunchCal = (targetCal * 0.35).round();
    final dinnerCal = (targetCal * 0.30).round();
    final snackCal = (targetCal * 0.10).round();

    // Select foods from available list, fallback to common items
    List<String> foods = availableFoods.isNotEmpty
        ? availableFoods
        : (isVeg
            ? ['Dal', 'Rice', 'Roti', 'Paneer', 'Curd', 'Sabzi']
            : ['Chicken', 'Eggs', 'Rice', 'Dal', 'Roti', 'Curd']);

    // Map items into meal placeholders using available foods
    final bfItems = <Map<String, dynamic>>[];
    final lunchItems = <Map<String, dynamic>>[];
    final dinnerItems = <Map<String, dynamic>>[];
    final snackItems = <Map<String, dynamic>>[];

    // Build breakfast
    if (foods.any((f) => f.toLowerCase().contains('oat'))) {
      bfItems.add({'item': '60g Oats with Milk', 'grams': '60g', 'calories': '${(bfCal * 0.5).round()}'});
    } else {
      bfItems.add({'item': '2 Multigrain Roti', 'grams': '80g', 'calories': '${(bfCal * 0.4).round()}'});
    }
    if (!isVeg && foods.any((f) => f.toLowerCase().contains('egg'))) {
      bfItems.add({'item': '2 Boiled Eggs', 'grams': '100g', 'calories': '${(bfCal * 0.35).round()}'});
    } else {
      bfItems.add({'item': '1 Glass Milk / Curd', 'grams': '200ml', 'calories': '${(bfCal * 0.3).round()}'});
    }
    bfItems.add({'item': '1 Fruit (Banana/Apple)', 'grams': '100g', 'calories': '${(bfCal * 0.15).round()}'});

    // Build lunch
    if (foods.any((f) => f.toLowerCase().contains('rice'))) {
      lunchItems.add({'item': '150g Rice', 'grams': '150g', 'calories': '${(lunchCal * 0.4).round()}'});
    } else {
      lunchItems.add({'item': '3 Roti', 'grams': '120g', 'calories': '${(lunchCal * 0.4).round()}'});
    }
    lunchItems.add({'item': '1 Bowl Dal', 'grams': '150g', 'calories': '${(lunchCal * 0.25).round()}'});
    if (!isVeg && foods.any((f) => f.toLowerCase().contains('chicken'))) {
      lunchItems.add({'item': '150g Chicken Curry', 'grams': '150g', 'calories': '${(lunchCal * 0.25).round()}'});
    } else {
      lunchItems.add({'item': '1 Plate Green Sabzi', 'grams': '100g', 'calories': '${(lunchCal * 0.20).round()}'});
    }
    lunchItems.add({'item': '1 Bowl Curd', 'grams': '100g', 'calories': '${(lunchCal * 0.10).round()}'});

    // Build dinner
    if (!isVeg && foods.any((f) => f.toLowerCase().contains('chicken') || f.toLowerCase().contains('fish'))) {
      dinnerItems.add({'item': '150g Grilled Chicken/Fish', 'grams': '150g', 'calories': '${(dinnerCal * 0.35).round()}'});
    } else {
      dinnerItems.add({'item': '100g Paneer Bhurji', 'grams': '100g', 'calories': '${(dinnerCal * 0.35).round()}'});
    }
    dinnerItems.add({'item': '2 Multigrain Roti', 'grams': '80g', 'calories': '${(dinnerCal * 0.4).round()}'});
    dinnerItems.add({'item': '1 Plate Green Salad', 'grams': '100g', 'calories': '${(dinnerCal * 0.15).round()}'});

    // Build snacks
    snackItems.add({'item': '1 Handful Almonds & Walnuts', 'grams': '30g', 'calories': '${(snackCal * 0.6).round()}'});
    snackItems.add({'item': '1 Fruit / Buttermilk', 'grams': '100g', 'calories': '${(snackCal * 0.4).round()}'});

    // Build meal entries with per-meal macros
    return [
      _buildFallbackMealEntry('Breakfast', bfItems, bfCal),
      _buildFallbackMealEntry('Lunch', lunchItems, lunchCal),
      _buildFallbackMealEntry('Dinner', dinnerItems, dinnerCal),
      _buildFallbackMealEntry('Snack', snackItems, snackCal),
    ];
  }

  /// Build a meal entry for the fallback plan.
  static Map<String, dynamic> _buildFallbackMealEntry(
      String type, List<Map<String, dynamic>> items, int calories) {
    final protein = (calories * 0.30 / 4).round();
    final carbs = (calories * 0.50 / 4).round();
    final fats = (calories * 0.20 / 9).round();

    final nameItems = items.take(2).map((e) {
      final s = e['item']?.toString() ?? '';
      return s.replaceAll(RegExp(r'^\d+\s*g?\s*'), '');
    }).join(' & ');

    return {
      'type': type,
      'name': nameItems.isNotEmpty ? nameItems : '$type Meal',
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'items': items,
    };
  }
}
