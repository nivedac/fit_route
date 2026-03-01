import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // Account Info
  String _fullName = '';
  String _email = '';

  // Profile Metrics
  double _currentWeight = 75.0;
  double _targetWeight = 70.0;
  int _age = 25;
  String _gender = 'Male';
  String _timeline = '12 Weeks (Optimal Pace)';

  // Preferences
  String _workoutEnvironment = 'Home Setup'; // or 'Commercial Gym'
  String _difficulty = 'Beginner';
  String _dietType = 'Vegetarian';
  List<String> _selectedFoods = ['Basmati Rice', 'Free Range Eggs', 'Chicken Breast', 'Mixed Berries'];

  // Plan Data (Mocked from Generate Screen)
  bool _isGenerating = false;
  double _generationProgress = 0.0;

  // Getters
  String get fullName => _fullName;
  String get email => _email;
  double get currentWeight => _currentWeight;
  double get targetWeight => _targetWeight;
  int get age => _age;
  String get gender => _gender;
  String get timeline => _timeline;
  String get workoutEnvironment => _workoutEnvironment;
  String get difficulty => _difficulty;
  String get dietType => _dietType;
  List<String> get selectedFoods => _selectedFoods;
  bool get isGenerating => _isGenerating;
  double get generationProgress => _generationProgress;

  // Setters
  void updateAccount(String name, String email) {
    _fullName = name;
    _email = email;
    notifyListeners();
  }

  void updateMetrics({double? current, double? target, int? age, String? gender, String? timeline}) {
    if (current != null) _currentWeight = current;
    if (target != null) _targetWeight = target;
    if (age != null) _age = age;
    if (gender != null) _gender = gender;
    if (timeline != null) _timeline = timeline;
    notifyListeners();
  }

  void setWorkoutEnvironment(String env) {
    _workoutEnvironment = env;
    notifyListeners();
  }

  void setDifficulty(String level) {
    _difficulty = level;
    notifyListeners();
  }

  void setDietType(String type) {
    _dietType = type;
    notifyListeners();
  }

  void toggleFood(String food) {
    if (_selectedFoods.contains(food)) {
      _selectedFoods.remove(food);
    } else {
      _selectedFoods.add(food);
    }
    notifyListeners();
  }

  void startGeneration() async {
    _isGenerating = true;
    _generationProgress = 0.0;
    notifyListeners();

    // Simulate generation loop
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(Duration(milliseconds: 50));
      _generationProgress = i / 100.0;
      notifyListeners();
    }
    _isGenerating = false;
    notifyListeners();
  }
}
