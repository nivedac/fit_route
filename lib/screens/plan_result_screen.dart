import 'package:flutter/material.dart';
import '../theme.dart';

class PlanResultScreen extends StatelessWidget {
  const PlanResultScreen({super.key});

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
                    children: const [
                      Text('TODAY, MAR 01', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                      SizedBox(height: 4),
                      Text('Plan Strategy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                    child: const Icon(Icons.calendar_today, size: 20),
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
                  
                  // Workout Cards
                  const _SubSessionCard(title: 'Core Stability', duration: '15 MINS', difficulty: 'INTERMEDIATE', icon: Icons.accessibility_new),
                  const SizedBox(height: 12),
                  const _SubSessionCard(title: 'Strength Baseline', duration: '45 MINS', difficulty: 'ADVANCED', icon: Icons.fitness_center),
                  
                  const SizedBox(height: 32),
                  
                  const Text('MEAL STRATEGY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  
                  const _MealCard(title: 'Protein-Rich Breakfast', subtitle: '450 kcal • High recovery focus', icon: Icons.breakfast_dining),
                  const SizedBox(height: 12),
                  const _MealCard(title: 'Peak Performance Lunch', subtitle: '750 kcal • Balanced macros', icon: Icons.lunch_dining),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 84,
        padding: const EdgeInsets.only(bottom: 24),
        decoration: const BoxDecoration(color: Color(0xFF151516), border: Border(top: BorderSide(color: Colors.white10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavIcon(icon: Icons.flash_on, label: 'Today', isSelected: true),
            _NavIcon(icon: Icons.auto_awesome_motion, label: 'Plans', isSelected: false),
            _NavIcon(icon: Icons.insights, label: 'Insights', isSelected: false),
            _NavIcon(icon: Icons.person_outline, label: 'Profile', isSelected: false),
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

  const _SubSessionCard({required this.title, required this.duration, required this.difficulty, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Icon(Icons.play_circle_outline, color: Colors.white38, size: 28),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _MealCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavIcon({required this.icon, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFD0BCFF) : Colors.grey.withOpacity(0.5);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
