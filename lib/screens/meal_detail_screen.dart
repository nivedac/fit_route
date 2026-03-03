import 'package:flutter/material.dart';
import '../theme.dart';

class MealDetailScreen extends StatefulWidget {
  final String title;
  final String calories;

  const MealDetailScreen({
    super.key,
    this.title = 'Protein-Rich Breakfast',
    this.calories = '450 kcal',
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool _isEaten = false;

  final Map<String, dynamic> _macros = {
    'Protein': {'value': '35g', 'percentage': 0.7, 'color': const Color(0xFFD0BCFF)},
    'Carbs': {'value': '45g', 'percentage': 0.55, 'color': AppTheme.accentCyan},
    'Fat': {'value': '15g', 'percentage': 0.3, 'color': AppTheme.accentOrange},
    'Fiber': {'value': '8g', 'percentage': 0.4, 'color': AppTheme.accentEmerald},
  };

  final List<Map<String, dynamic>> _ingredients = [
    {'name': 'Egg Whites', 'quantity': '3 large', 'icon': Icons.egg_rounded, 'cal': '51 kcal'},
    {'name': 'Greek Yogurt', 'quantity': '1 cup (170g)', 'icon': Icons.icecream_rounded, 'cal': '100 kcal'},
    {'name': 'Mixed Berries', 'quantity': '100g', 'icon': Icons.spa_rounded, 'cal': '57 kcal'},
    {'name': 'Rolled Oats', 'quantity': '40g', 'icon': Icons.grass_rounded, 'cal': '154 kcal'},
    {'name': 'Honey', 'quantity': '1 tbsp', 'icon': Icons.water_drop_rounded, 'cal': '64 kcal'},
    {'name': 'Chia Seeds', 'quantity': '10g', 'icon': Icons.grain_rounded, 'cal': '49 kcal'},
  ];

  @override
  Widget build(BuildContext context) {
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
                        Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(widget.calories, style: const TextStyle(fontSize: 12, color: AppTheme.accentOrange, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  if (_isEaten)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.accentEmerald.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: AppTheme.accentEmerald, size: 14),
                          SizedBox(width: 4),
                          Text('EATEN', style: TextStyle(fontSize: 10, color: AppTheme.accentEmerald, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Macro Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFD0BCFF).withOpacity(0.08), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD0BCFF).withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MACRO BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                        const SizedBox(height: 20),
                        // Macro circles row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _macros.entries.map((entry) {
                            final data = entry.value as Map<String, dynamic>;
                            final color = data['color'] as Color;
                            return Column(
                              children: [
                                SizedBox(
                                  width: 56, height: 56,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: data['percentage'] as double,
                                        strokeWidth: 4,
                                        backgroundColor: Colors.white.withOpacity(0.05),
                                        valueColor: AlwaysStoppedAnimation(color),
                                      ),
                                      Center(
                                        child: Text(
                                          data['value'] as String,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(entry.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Ingredients
                  const Text('INGREDIENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
                  const SizedBox(height: 16),

                  ...List.generate(_ingredients.length, (index) {
                    final item = _ingredients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item['icon'] as IconData, color: Colors.white38, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(item['quantity'] as String, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ),
                            Text(item['cal'] as String, style: const TextStyle(fontSize: 13, color: Colors.white38, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Mark as Eaten Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isEaten = !_isEaten);
                  if (_isEaten) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Meal logged! 🎉'),
                        backgroundColor: AppTheme.accentEmerald,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEaten ? AppTheme.surface : AppTheme.accentEmerald,
                  foregroundColor: _isEaten ? Colors.white54 : AppTheme.charcoal,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isEaten ? Icons.check_circle : Icons.restaurant_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isEaten ? 'Marked as Eaten' : 'Mark as Eaten',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
