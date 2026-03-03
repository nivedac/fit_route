import 'package:flutter/material.dart';
import '../theme.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String title;
  final String duration;
  final String difficulty;

  const WorkoutDetailScreen({
    super.key,
    this.title = 'Core Stability',
    this.duration = '15 MINS',
    this.difficulty = 'INTERMEDIATE',
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'Plank Hold', 'sets': '3 sets × 45 sec', 'icon': Icons.accessibility_new, 'completed': false},
    {'name': 'Dead Bug', 'sets': '3 sets × 12 reps', 'icon': Icons.self_improvement, 'completed': false},
    {'name': 'Bird Dog', 'sets': '3 sets × 10 reps/side', 'icon': Icons.pets, 'completed': false},
    {'name': 'Mountain Climbers', 'sets': '3 sets × 20 reps', 'icon': Icons.terrain, 'completed': false},
    {'name': 'Russian Twists', 'sets': '3 sets × 15 reps/side', 'icon': Icons.rotate_left, 'completed': false},
    {'name': 'Leg Raises', 'sets': '3 sets × 12 reps', 'icon': Icons.straighten, 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = _exercises.where((e) => e['completed'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(widget.duration, style: const TextStyle(fontSize: 10, color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.sunsetOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(widget.difficulty, style: const TextStyle(fontSize: 10, color: AppTheme.sunsetOrange, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.sunsetOrange.withOpacity(0.08), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56, height: 56,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: _exercises.isEmpty ? 0 : completedCount / _exercises.length,
                            strokeWidth: 5,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.sunsetOrange),
                          ),
                          Center(
                            child: Text(
                              '$completedCount/${_exercises.length}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exercises Completed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            completedCount == _exercises.length ? 'All done! Great work! 🎉' : '${_exercises.length - completedCount} exercises remaining',
                            style: const TextStyle(fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Exercises label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Text('EXERCISES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Exercises list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ex = _exercises[index];
                  final completed = ex['completed'] as bool;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _exercises[index]['completed'] = !completed);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: completed ? AppTheme.sunsetOrange.withOpacity(0.06) : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: completed ? AppTheme.sunsetOrange.withOpacity(0.2) : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: completed
                                  ? AppTheme.sunsetOrange.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              ex['icon'] as IconData,
                              color: completed ? AppTheme.sunsetOrange : Colors.white54,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: completed ? Colors.white54 : Colors.white,
                                    decoration: completed ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ex['sets'] as String,
                                  style: TextStyle(fontSize: 12, color: completed ? Colors.white24 : Colors.white54),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed ? AppTheme.sunsetOrange : Colors.transparent,
                              border: Border.all(color: completed ? AppTheme.sunsetOrange : Colors.white24, width: 2),
                            ),
                            child: completed ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Start Workout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/active-workout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.charcoal,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Start Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.play_arrow_rounded, size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
