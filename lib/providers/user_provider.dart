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
  String _timeline = '30 Days';

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
  DateTime? _planStartDate;
  int _goalDurationDays = 30;
  String? _uid;

  // Getters
  String? get uid => _uid;
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
  DateTime? get planStartDate => _planStartDate;
  int get goalDurationDays => _goalDurationDays;

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
    if (timeline != null) {
      _timeline = timeline;
      // Parse days from timeline string (e.g. "30 Days")
      final match = RegExp(r'(\d+)').firstMatch(timeline);
      if (match != null) {
        _goalDurationDays = int.parse(match.group(1)!);
      }
    }
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

  /// Clears ALL in-memory user data AND local cache.
  /// Called on logout and before loading a new user.
  Future<void> clearData() async {
    debugPrint('🔄 clearData() — wiping all user data (uid was: $_uid)');

    // Clear local SharedPreferences for the current user
    final oldUid = _uid;
    if (oldUid != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('aiPlanData_$oldUid');
        await prefs.remove('planStartDate_$oldUid');
        await prefs.remove('goalDurationDays_$oldUid');
        await prefs.remove('weightLogs_$oldUid');
        await prefs.remove('trackerData_$oldUid');
        debugPrint('✅ Cleared SharedPreferences for uid: $oldUid');
      } catch (e) {
        debugPrint('⚠️ Error clearing local cache: $e');
      }
    }

    // Reset ALL in-memory state
    _fullName = '';
    _email = '';
    _profilePhotoUrl = '';
    _currentWeight = 75.0;
    _targetWeight = 70.0;
    _height = 182.0;
    _age = 25;
    _gender = 'Male';
    _timeline = '30 Days';
    _workoutEnvironment = 'Home Setup';
    _difficulty = 'Beginner';
    _dietType = 'Vegetarian';
    _selectedFoods = ['Basmati Rice', 'Free Range Eggs', 'Chicken Breast', 'Mixed Berries'];
    _isGenerating = false;
    _generationStatus = '';
    _generationProgress = 0.0;
    _aiPlanData = null;
    _weightLogs = [];
    _trackerData = {};
    _planStartDate = null;
    _goalDurationDays = 30;
    _uid = null;
    notifyListeners();
  }

  // Weight Logging
  void logWeight(double weight, DateTime date) {
    _currentWeight = weight;
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Remove any existing log for the same date before inserting
    _weightLogs.removeWhere((log) => log['date'] == dateKey);
    _weightLogs.insert(0, {
      'weight': weight,
      'date': dateKey,
    });
    // Keep only last 365 entries
    if (_weightLogs.length > 365) {
      _weightLogs = _weightLogs.sublist(0, 365);
    }
    
    // Automatically mark weight logged in tracker
    if (!_trackerData.containsKey(dateKey)) {
      _trackerData[dateKey] = {
        'workout': false,
        'meals': false,
        'water': false,
        'steps': false,
        'weight': false,
      };
    }
    _trackerData[dateKey]!['weight'] = true;
    
    notifyListeners();
    _saveWeightLogsLocally();
    _saveTrackerDataLocally();
    _saveTrackerDataToFirestore();
    _saveWeightLogsToFirestore();
  }

  // Tracker Checklist
  Map<String, bool> getChecklistForDate(String dateKey) {
    return _trackerData[dateKey] ?? {
      'workout': false,
      'meals': false,
      'water': false,
      'steps': false,
      'weight': false,
    };
  }

  void toggleChecklistItem(String dateKey, String item) {
    if (!_trackerData.containsKey(dateKey)) {
      _trackerData[dateKey] = {
        'workout': false,
        'meals': false,
        'water': false,
        'steps': false,
        'weight': false,
      };
    }
    _trackerData[dateKey]![item] = !(_trackerData[dateKey]![item] ?? false);
    notifyListeners();
    _saveTrackerDataLocally();
    _saveTrackerDataToFirestore(); // Persist to Firestore
  }

  void updateChecklistItem(String dateKey, String item, bool value) {
    if (!_trackerData.containsKey(dateKey)) {
      _trackerData[dateKey] = {
        'workout': false,
        'meals': false,
        'water': false,
        'steps': false,
        'weight': false,
      };
    }
    _trackerData[dateKey]![item] = value;
    notifyListeners();
    _saveTrackerDataLocally();
    _saveTrackerDataToFirestore();
  }

  int getCompletedDaysCount() {
    int count = 0;
    _trackerData.forEach((key, checklist) {
      if (checklist.values.every((v) => v)) count++;
    });
    return count;
  }

  double getTodayProgress() {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final checklist = getChecklistForDate(dateKey);
    int completed = 0;
    if (checklist['workout'] ?? false) completed++;
    if (checklist['meals'] ?? false) completed++;
    if (checklist['water'] ?? false) completed++;
    if (checklist['steps'] ?? false) completed++;
    if (checklist['weight'] ?? false) completed++;
    // Returns a value between 0.0 and 1.0
    return completed / 5.0;
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
  // IMPORTANT: Always clears previous user data first to prevent data mixing
  Future<void> loadUserProfile(String uid) async {
    try {
      // If switching users, clear ALL previous user data first
      if (_uid != null && _uid != uid) {
        debugPrint('🔀 User switch detected: $_uid → $uid — clearing old data');
        await clearData();
      }

      _uid = uid; // Set the UID for the new user
      debugPrint('👤 Loading profile for uid: $uid');

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

        // Load tracker, weight logs, and plan from Firestore (per-user)
        await _loadTrackerDataFromFirestore(uid);
        await _loadWeightLogsFromFirestore(uid);
        await _loadPlanFromFirestore(uid);

        debugPrint('✅ Profile loaded for $uid — plan exists: ${_aiPlanData != null}');
        notifyListeners();
      } else {
        debugPrint('ℹ️ No Firestore profile found for uid: $uid (new user)');
      }
    } catch (e) {
      debugPrint('❌ Error loading user profile: $e');
    }
  }

  Future<void> _loadWeightLogsFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('logs').doc('weight').get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['logs'] != null) {
          _weightLogs = List<Map<String, dynamic>>.from(data['logs']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading weight logs from Firestore: $e');
    }
  }

  Future<void> _saveWeightLogsToFirestore() async {
    if (_uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).collection('logs').doc('weight').set({
        'logs': _weightLogs,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving weight logs to Firestore: $e');
    }
  }

  Future<void> _loadPlanFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('plans').doc('generated_plan').get();
      if (doc.exists) {
        final data = doc.data()!;
        _aiPlanData = data['planData'];
        if (data['planStartDate'] != null) {
          _planStartDate = DateTime.tryParse(data['planStartDate']);
        }
        _goalDurationDays = data['goalDurationDays'] ?? _goalDurationDays;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading plan from Firestore: $e');
    }
  }

  Future<void> _savePlanToFirestore() async {
    if (_uid == null || _aiPlanData == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).collection('plans').doc('generated_plan').set({
        'planData': _aiPlanData,
        'planStartDate': _planStartDate?.toIso8601String(),
        'goalDurationDays': _goalDurationDays,
        'generatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving plan to Firestore: $e');
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
        'planStartDate': _planStartDate?.toIso8601String(),
        'goalDurationDays': _goalDurationDays,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  // Local persistence for weight logs
  Future<void> _saveWeightLogsLocally() async {
    if (_uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weightLogs_$_uid', jsonEncode(_weightLogs));
    } catch (e) {
      debugPrint('Error saving weight logs locally: $e');
    }
  }

  Future<void> loadWeightLogsLocally() async {
    if (_uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('weightLogs_$_uid');
      if (data != null) {
        _weightLogs = List<Map<String, dynamic>>.from(jsonDecode(data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading weight logs locally: $e');
    }
  }

  // Local persistence for tracker data
  Future<void> _saveTrackerDataLocally() async {
    if (_uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _trackerData.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, v))));
      await prefs.setString('trackerData_$_uid', jsonEncode(encoded));
    } catch (e) {
      debugPrint('Error saving tracker data locally: $e');
    }
  }

  Future<void> loadTrackerDataLocally() async {
    if (_uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('trackerData_$_uid');
      if (data != null) {
        final decoded = Map<String, dynamic>.from(jsonDecode(data));
        _trackerData = decoded.map((key, value) =>
            MapEntry(key, Map<String, bool>.from((value as Map).map((k, v) => MapEntry(k.toString(), v as bool)))));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tracker data locally: $e');
    }
  }

  // Plan generation — real AI integration
  Future<void> startGeneration() async {
    _isGenerating = true;
    _generationProgress = 0.0;
    _generationStatus = 'Analyzing your profile metrics...';
    _aiPlanData = null;
    notifyListeners();

    // Phase 1: Analyzing (0 → 30%)
    for (int i = 0; i <= 30; i += 3) {
      await Future.delayed(const Duration(milliseconds: 80));
      _generationProgress = i / 100.0;
      notifyListeners();
    }

    // Phase 2: Calling AI API (30 → 80%)
    _generationStatus = 'Connecting to Gemini AI...';
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
      age: _age,
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
    _generationStatus = 'Gemini calibrating your plan...';
    notifyListeners();

    for (int i = 81; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 50));
      _generationProgress = i / 100.0;
      notifyListeners();
    }

    // If AI failed, use dynamically calculated fallback plan (NOT hardcoded)
    _aiPlanData ??= AiService.getCalculatedFallbackPlan(
      height: _height,
      weight: _currentWeight,
      goalWeight: _targetWeight,
      duration: _timeline,
      gender: _gender,
      workoutMode: _workoutEnvironment,
      intensity: _difficulty,
      dietPreference: _dietType,
      availableFoods: _selectedFoods,
      age: _age,
    );

    // Set plan start date to today
    _planStartDate = DateTime.now();

    // Save plan locally and to Firestore
    await _savePlanLocally();
    await _savePlanToFirestore();

    _generationStatus = 'Your Gemini AI plan is ready!';
    _isGenerating = false;
    notifyListeners();
  }

  Future<void> loadPlanLocally() async {
    if (_uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('aiPlanData_$_uid');
      if (data != null) {
        _aiPlanData = jsonDecode(data) as Map<String, dynamic>;
      }
      
      final startDateStr = prefs.getString('planStartDate_$_uid');
      if (startDateStr != null) {
        _planStartDate = DateTime.parse(startDateStr);
      }
      
      _goalDurationDays = prefs.getInt('goalDurationDays_$_uid') ?? 30;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading plan locally: $e');
    }
  }

  Future<void> _savePlanLocally() async {
    if (_uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_aiPlanData != null) {
        await prefs.setString('aiPlanData_$_uid', jsonEncode(_aiPlanData));
        if (_planStartDate != null) {
          await prefs.setString('planStartDate_$_uid', _planStartDate!.toIso8601String());
        }
        await prefs.setInt('goalDurationDays_$_uid', _goalDurationDays);
      }
    } catch (e) {
      debugPrint('Error saving plan locally: $e');
    }
  }

  Future<void> _loadTrackerDataFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('tracker').doc('daily_progress').get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['data'] != null) {
          final rawData = data['data'] as Map<String, dynamic>;
          _trackerData = rawData.map(
            (key, value) => MapEntry(key, Map<String, bool>.from(value as Map)),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading tracker from Firestore: $e');
    }
  }

  Future<void> _saveTrackerDataToFirestore() async {
    if (_uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).collection('tracker').doc('daily_progress').set({
        'data': _trackerData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving tracker to Firestore: $e');
    }
  }
}
