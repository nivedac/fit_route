import 'package:flutter/material.dart';
import '../theme.dart';

class PlanResultScreen extends StatefulWidget {
  const PlanResultScreen({super.key});

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD0BCFF),
              surface: AppTheme.surface,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
    final prefix = isToday ? 'TODAY' : _selectedDate.weekday == now.weekday ? 'TODAY' : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][_selectedDate.weekday - 1];
    return '$prefix, ${months[_selectedDate.month - 1]} ${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formattedDate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      const Text('Plan Strategy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: const Icon(Icons.calendar_today, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Daily Energy Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFD0BCFF).withOpacity(0.15), const Color(0xFFD0BCFF).withOpacity(0.02)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD0BCFF).withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Daily Energy Target', style: TextStyle(fontSize: 14, color: Colors.white70)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFD0BCFF).withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                              child: const Text('CALIBRATED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFD0BCFF))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('2,450 kcal', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        // Macro Bars
                        _MacroBar(label: 'Proteins', value: '180g', percentage: 0.8, color: const Color(0xFFD0BCFF)),
                        const SizedBox(height: 12),
                        _MacroBar(label: 'Carbs', value: '250g', percentage: 0.6, color: AppTheme.accentCyan),
                        const SizedBox(height: 12),
                        _MacroBar(label: 'Fats', value: '75g', percentage: 0.4, color: AppTheme.accentOrange),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text('TODAY\'S WORKOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  
                  // Workout Cards — now tappable
                  _SubSessionCard(
                    title: 'Core Stability',
                    duration: '15 MINS',
                    difficulty: 'INTERMEDIATE',
                    icon: Icons.accessibility_new,
                    onTap: () {
                      Navigator.pushNamed(context, '/workout-detail', arguments: {
                        'title': 'Core Stability',
                        'duration': '15 MINS',
                        'difficulty': 'INTERMEDIATE',
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SubSessionCard(
                    title: 'Strength Baseline',
                    duration: '45 MINS',
                    difficulty: 'ADVANCED',
                    icon: Icons.fitness_center,
                    onTap: () {
                      Navigator.pushNamed(context, '/workout-detail', arguments: {
                        'title': 'Strength Baseline',
                        'duration': '45 MINS',
                        'difficulty': 'ADVANCED',
                      });
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text('MEAL STRATEGY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  
                  // Meal Cards — now tappable
                  _MealCard(
                    title: 'Protein-Rich Breakfast',
                    subtitle: '450 kcal • High recovery focus',
                    icon: Icons.breakfast_dining,
                    onTap: () {
                      Navigator.pushNamed(context, '/meal-detail', arguments: {
                        'title': 'Protein-Rich Breakfast',
                        'calories': '450 kcal',
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _MealCard(
                    title: 'Peak Performance Lunch',
                    subtitle: '750 kcal • Balanced macros',
                    icon: Icons.lunch_dining,
                    onTap: () {
                      Navigator.pushNamed(context, '/meal-detail', arguments: {
                        'title': 'Peak Performance Lunch',
                        'calories': '750 kcal',
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final String value;
  final double percentage;
  final Color color;

  const _MacroBar({required this.label, required this.value, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _SubSessionCard extends StatelessWidget {
  final String title;
  final String duration;
  final String difficulty;
  final IconData icon;
  final VoidCallback onTap;

  const _SubSessionCard({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white54, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(duration, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24)),
                      const SizedBox(width: 8),
                      Text(difficulty, style: const TextStyle(fontSize: 10, color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 28),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MealCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black.withAlpha(40), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white24, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
