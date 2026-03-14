import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/ai_service.dart';

class UserProvider with ChangeNotifier {
  // Account Info
  String _fullName = '';
  String _email = '';
  String _profilePhotoUrl = '';

  // Profile Metrics
  double _currentWeight = 75.0;
  double _targetWeight = 70.0;
  double _height = 182.0;
  int _age = 25;
  String _gender = 'Male';
  String _timeline = '12 Weeks (Optimal Pace)';

  // Preferences
  String _workoutEnvironment = 'Home Setup';
  String _difficulty = 'Beginner';
  String _dietType = 'Vegetarian';
  List<String> _selectedFoods = ['Basmati Rice', 'Free Range Eggs', 'Chicken Breast', 'Mixed Berries'];

  // Plan Data
  bool _isGenerating = false;
  String _generationStatus = '';
  Map<String, dynamic>? _aiPlanData;
  double _generationProgress = 0.0;

  // Weight Log History
  List<Map<String, dynamic>> _weightLogs = [];

  // Tracker Data: Map of date string (yyyy-MM-dd) -> checklist status
  Map<String, Map<String, bool>> _trackerData = {};

  // Getters
  String get fullName => _fullName;
  String get email => _email;
  String get profilePhotoUrl => _profilePhotoUrl;
  double get currentWeight => _currentWeight;
  double get targetWeight => _targetWeight;
  double get height => _height;
  int get age => _age;
  String get gender => _gender;
  String get timeline => _timeline;
  String get workoutEnvironment => _workoutEnvironment;
  String get difficulty => _difficulty;
  String get dietType => _dietType;
  List<String> get selectedFoods => _selectedFoods;
  bool get isGenerating => _isGenerating;
  double get generationProgress => _generationProgress;
  String get generationStatus => _generationStatus;
  Map<String, dynamic>? get aiPlanData => _aiPlanData;
  List<Map<String, dynamic>> get weightLogs => _weightLogs;
  Map<String, Map<String, bool>> get trackerData => _trackerData;

  // Setters
  void updateAccount(String name, String email) {
    _fullName = name;
    _email = email;
    notifyListeners();
  }

  void setProfilePhotoUrl(String url) {
    _profilePhotoUrl = url;
    notifyListeners();
  }

  void updateMetrics({double? current, double? target, double? height, int? age, String? gender, String? timeline}) {
    if (current != null) _currentWeight = current;
    if (target != null) _targetWeight = target;
    if (height != null) _height = height;
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

  // Weight Logging
  void logWeight(double weight, DateTime date) {
    _currentWeight = weight;
    _weightLogs.insert(0, {
      'weight': weight,
      'date': date.toIso8601String(),
    });
    // Keep only last 365 entries
    if (_weightLogs.length > 365) {
      _weightLogs = _weightLogs.sublist(0, 365);
    }
    notifyListeners();
    _saveWeightLogsLocally();
  }

  // Tracker Checklist
  Map<String, bool> getChecklistForDate(String dateKey) {
    return _trackerData[dateKey] ?? {
      'workout': false,
      'meals': false,
      'water': false,
      'steps': false,
    };
  }

  void toggleChecklistItem(String dateKey, String item) {
    if (!_trackerData.containsKey(dateKey)) {
      _trackerData[dateKey] = {
        'workout': false,
        'meals': false,
        'water': false,
        'steps': false,
      };
    }
    _trackerData[dateKey]![item] = !(_trackerData[dateKey]![item] ?? false);
    notifyListeners();
    _saveTrackerDataLocally();
  }

  int getCompletedDaysCount() {
    int count = 0;
    _trackerData.forEach((key, checklist) {
      if (checklist.values.every((v) => v)) count++;
    });
    return count;
  }

  int getCurrentStreak() {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final checklist = _trackerData[key];
      if (checklist != null && checklist.values.any((v) => v)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Load user profile from Firestore
  Future<void> loadUserProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _fullName = data['name'] ?? _fullName;
        _email = data['email'] ?? _email;
        _profilePhotoUrl = data['profilePhotoUrl'] ?? '';
        _currentWeight = (data['currentWeight'] ?? _currentWeight).toDouble();
        _targetWeight = (data['targetWeight'] ?? _targetWeight).toDouble();
        _height = (data['height'] ?? _height).toDouble();
        _age = data['age'] ?? _age;
        _gender = data['gender'] ?? _gender;
        _workoutEnvironment = data['workoutEnvironment'] ?? _workoutEnvironment;
        _dietType = data['dietType'] ?? _dietType;
        _difficulty = data['difficulty'] ?? _difficulty;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Save user profile to Firestore
  Future<void> saveUserProfile(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _fullName,
        'email': _email,
        'profilePhotoUrl': _profilePhotoUrl,
        'currentWeight': _currentWeight,
        'targetWeight': _targetWeight,
        'height': _height,
        'age': _age,
        'gender': _gender,
        'workoutEnvironment': _workoutEnvironment,
        'dietType': _dietType,
        'difficulty': _difficulty,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  // Local persistence for weight logs
  Future<void> _saveWeightLogsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weightLogs', jsonEncode(_weightLogs));
    } catch (e) {
      debugPrint('Error saving weight logs: $e');
    }
  }

  Future<void> loadWeightLogsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('weightLogs');
      if (data != null) {
        _weightLogs = List<Map<String, dynamic>>.from(jsonDecode(data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading weight logs: $e');
    }
  }

  // Local persistence for tracker data
  Future<void> _saveTrackerDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _trackerData.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, v))));
      await prefs.setString('trackerData', jsonEncode(encoded));
    } catch (e) {
      debugPrint('Error saving tracker data: $e');
    }
  }

  Future<void> loadTrackerDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('trackerData');
      if (data != null) {
        final decoded = Map<String, dynamic>.from(jsonDecode(data));
        _trackerData = decoded.map((key, value) =>
            MapEntry(key, Map<String, bool>.from((value as Map).map((k, v) => MapEntry(k.toString(), v as bool)))));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tracker data: $e');
    }
  }

  // Plan generation — real AI integration
  Future<void> startGeneration() async {
    _isGenerating = true;
    _generationProgress = 0.0;
    _generationStatus = 'Analyzing profile metrics...';
    _aiPlanData = null;
    notifyListeners();

    // Phase 1: Analyzing (0 → 30%)
    for (int i = 0; i <= 30; i += 3) {
      await Future.delayed(const Duration(milliseconds: 80));
      _generationProgress = i / 100.0;
      notifyListeners();
    }

    // Phase 2: Calling AI API (30 → 80%)
    _generationStatus = 'Generating personalized plan...';
    notifyListeners();

    // Start the AI generation in parallel with progress simulation
    final aiFuture = AiService.generatePlan(
      height: _height,
      weight: _currentWeight,
      goalWeight: _targetWeight,
      duration: _timeline,
      gender: _gender,
      workoutMode: _workoutEnvironment,
      intensity: _difficulty,
      dietPreference: _dietType,
      availableFoods: _selectedFoods,
    );

    // Simulate progress while waiting for AI
    Future<void> progressSimulation() async {
      for (int i = 31; i <= 80; i += 2) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (!_isGenerating) break;
        _generationProgress = i / 100.0;
        notifyListeners();
      }
    }

    // Run both concurrently
    final results = await Future.wait([
      aiFuture,
      progressSimulation(),
    ]);

    _aiPlanData = results[0] as Map<String, dynamic>?;

    // Phase 3: Finalizing (80 → 100%)
    _generationStatus = 'Calibrating caloric thresholds...';
    notifyListeners();

    for (int i = 81; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 50));
      _generationProgress = i / 100.0;
      notifyListeners();
    }

    // If AI failed, use default plan
    _aiPlanData ??= AiService.getDefaultPlan();

    // Save plan to shared preferences
    await _savePlanLocally();

    _generationStatus = 'Plan ready!';
    _isGenerating = false;
    notifyListeners();
  }

  // Save and load AI plan locally
  Future<void> _savePlanLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_aiPlanData != null) {
        await prefs.setString('aiPlanData', jsonEncode(_aiPlanData));
      }
    } catch (e) {
      debugPrint('Error saving plan: $e');
    }
  }

  Future<void> loadPlanLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('aiPlanData');
      if (data != null) {
        _aiPlanData = jsonDecode(data) as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading plan: $e');
    }
  }
}
