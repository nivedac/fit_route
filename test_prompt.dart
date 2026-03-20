import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final prompt = '''You are a professional fitness trainer and nutritionist.
Create a personalized workout plan and diet plan that is unique to this user profile.

User profile:
Age: 25
Height: 180 cm
Current Weight: 80 kg
Goal Weight: 75 kg
Duration: 12 weeks
Sex: Male
Workout Mode: Gym
Workout Intensity: Intermediate
Diet Preference: Non-veg
Available Foods: Chicken, Rice, Oats, Eggs

Return a structured response ONLY as a valid JSON object with the following fields:
1. "dailyCalories": total daily calorie target.
2. "macros": macronutrient breakdown with "protein", "carbs", "fats" (each as {"grams": X, "percentage": Y}).
3. "workout": a "weeklySchedule" array of 7 days, each having:
   - "day": Name of the day
   - "sessionName": Descriptive name
   - "duration": total time
   - "difficulty": intensity level
   - "exercises": array of {"name", "sets", "reps", "rest", "instructions"}
4. "diet": a "meals" array including "Breakfast", "Lunch", "Dinner", and "Snack" (each as:
   - "type": Meal type
   - "name": Recipe name
   - "calories": Total meal calories
   - "protein": meal protein grams
   - "carbs": meal carbs grams
   - "fats": meal fats grams
   - "items": array of {"item": "food name", "grams": "quantity in g or ml", "calories": "item calories"}
   )

CRITICAL: The diet plan MUST include exact gram measurements for every food item. 
Use ONLY the available foods listed where possible. Ensure all values are calculated based on the user metrics for optimal goal attainment.''';

  final uri = Uri.parse('https://integrate.api.nvidia.com/v1/chat/completions');
  final body = jsonEncode({
    'model': 'nvidia/llama-3.1-nemotron-70b-instruct',
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

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: body,
    );
    print('Status: \${response.statusCode}');
    final data = jsonDecode(response.body);
    final content = data['choices']?[0]?['message']?['content'];
    print('Content: \$content');

    // test parsing
    try {
      String jsonString = content;
      final startIndex = content.indexOf('{');
      final endIndex = content.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonString = content.substring(startIndex, endIndex + 1);
      }
      final parsed = jsonDecode(jsonString);
      print('Parsed successfully: \${parsed['dailyCalories']}');
    } catch (e) {
      print('Parse Error: \$e');
    }
  } catch (e) {
    print('Error: \$e');
  }
}
