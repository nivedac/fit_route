import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _elapsedSeconds = 0;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restSeconds = 0;
  bool _isPaused = false;
  Timer? _timer;
  Timer? _restTimer;

  late List<Map<String, dynamic>> _exercises;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _startTimer();
  }

  void _loadExercises() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final aiPlan = provider.aiPlanData;
    
    // Default fallback exercises if no plan generated
    List<Map<String, dynamic>> fallback = [
      {'name': 'Bench Press', 'sets': 4, 'reps': '12 reps', 'weight': '60 kg', 'icon': Icons.fitness_center, 'completed': false},
      {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': '10 reps', 'weight': '22 kg', 'icon': Icons.fitness_center, 'completed': false},
      {'name': 'Cable Flyes', 'sets': 3, 'reps': '15 reps', 'weight': '14 kg', 'icon': Icons.cable, 'completed': false},
      {'name': 'Overhead Press', 'sets': 4, 'reps': '10 reps', 'weight': '40 kg', 'icon': Icons.fitness_center, 'completed': false},
    ];

    if (aiPlan == null) {
      _exercises = fallback;
      return;
    }

    try {
      final schedule = aiPlan['workout']['weeklySchedule'] as List;
      // Find a day with exercises
      final dayObj = schedule.firstWhere((day) => (day['exercises'] as List).isNotEmpty, orElse: () => schedule.first);
      final rawExercises = dayObj['exercises'] as List;
      _exercises = rawExercises.map((e) => {
        'name': e['name'],
        'sets': e['sets'] is int ? e['sets'] : int.tryParse(e['sets'].toString()) ?? 3,
        'reps': e['reps'].toString(),
        'weight': 'Bodyweight / Custom',
        'icon': Icons.fitness_center,
        'completed': false,
      }).toList();
      
      if (_exercises.isEmpty) _exercises = fallback;
    } catch (e) {
      _exercises = fallback;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _startRest() {
    setState(() {
      _isResting = true;
      _restSeconds = 90;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _restSeconds > 0) {
        setState(() => _restSeconds--);
      } else if (_restSeconds <= 0) {
        timer.cancel();
        setState(() => _isResting = false);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSeconds = 0;
    });
  }

  void _completeSet() {
    final exercise = _exercises[_currentExerciseIndex];
    final totalSets = exercise['sets'] as int;

    if (_currentSet >= totalSets) {
      // Exercise completed
      setState(() {
        _exercises[_currentExerciseIndex]['completed'] = true;
        if (_currentExerciseIndex < _exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          _startRest();
        }
      });

      // Check if all exercises are done
      if (_exercises.every((e) => e['completed'] == true)) {
        _showCompletionDialog();
      }
    } else {
      setState(() => _currentSet++);
      _startRest();
    }
  }

  void _showCompletionDialog() {
    _timer?.cancel();

    // Mark workout as done in User Provider
    final provider = Provider.of<UserProvider>(context, listen: false);
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (!(provider.getChecklistForDate(dateKey)['workout'] ?? false)) {
      provider.toggleChecklistItem(dateKey, 'workout');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentEmerald.withOpacity(0.1),
              ),
              child: const Icon(Icons.celebration_rounded, color: AppTheme.accentEmerald, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Workout Complete! 🎉', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_formatTime(_elapsedSeconds)}',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              '${_exercises.length} exercises completed',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentEmerald,
                foregroundColor: AppTheme.charcoal,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_currentExerciseIndex];
    final totalSets = currentExercise['sets'] as int;
    final completedCount = _exercises.where((e) => e['completed'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text('End Workout?', style: TextStyle(color: Colors.white)),
                          content: const Text('Your progress will be lost.', style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                            TextButton(
                              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                              child: const Text('End', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  Text(
                    '$completedCount/${_exercises.length} exercises',
                    style: const TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isPaused = !_isPaused),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _isPaused ? AppTheme.sunsetOrange.withOpacity(0.15) : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isPaused ? AppTheme.sunsetOrange.withOpacity(0.3) : Colors.white10),
                      ),
                      child: Icon(
                        _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: _isPaused ? AppTheme.sunsetOrange : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Timer Circle
            SizedBox(
              width: 160, height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: completedCount / _exercises.length,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.sunsetOrange),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const Text('ELAPSED', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Current Exercise / Rest Timer
            if (_isResting) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.accentCyan.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    const Text('REST TIME', style: TextStyle(fontSize: 12, color: AppTheme.accentCyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(
                      '${_restSeconds}s',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _skipRest,
                      child: const Text('Skip Rest →', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      currentExercise['name'] as String,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set $_currentSet of $totalSets  •  ${currentExercise['reps']}  •  ${currentExercise['weight']}',
                      style: const TextStyle(fontSize: 15, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Upcoming Exercises
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UP NEXT', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final ex = _exercises[index];
                          final isCurrent = index == _currentExerciseIndex;
                          final isCompleted = ex['completed'] as bool;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppTheme.sunsetOrange.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: isCurrent ? Border.all(color: AppTheme.sunsetOrange.withOpacity(0.2)) : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted ? AppTheme.accentEmerald : (isCurrent ? AppTheme.sunsetOrange : Colors.white10),
                                  ),
                                  child: isCompleted
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : isCurrent
                                          ? const Icon(Icons.play_arrow, color: Colors.white, size: 16)
                                          : Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white38))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ex['name'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                      color: isCompleted ? Colors.white38 : Colors.white,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${ex['sets']} × ${ex['reps']}',
                                  style: TextStyle(fontSize: 11, color: isCompleted ? Colors.white24 : Colors.white38),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_currentExerciseIndex < _exercises.length - 1) {
                          setState(() {
                            _exercises[_currentExerciseIndex]['completed'] = true;
                            _currentExerciseIndex++;
                            _currentSet = 1;
                            _isResting = false;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isResting ? null : _completeSet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sunsetOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.sunsetOrange.withOpacity(0.3),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isResting ? 'Resting...' : 'Complete Set',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
