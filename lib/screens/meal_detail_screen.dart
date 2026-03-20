import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class MealDetailScreen extends StatefulWidget {
  final String title;
  final String calories;
  final Map<String, dynamic>? macroData;
  final List<dynamic>? ingredientsList;

  const MealDetailScreen({
    super.key,
    this.title = 'Protein-Rich Breakfast',
    this.calories = '450 kcal',
    this.macroData,
    this.ingredientsList,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool _isEaten = false;
  late Map<String, dynamic> _macros;
  late List<Map<String, dynamic>> _ingredients;

  @override
  void initState() {
    super.initState();
    
    // Initialize macros from passed data or use fallback
    if (widget.macroData != null) {
      _macros = {
        'Protein': {'value': '${widget.macroData!['protein']}g', 'percentage': 0.7, 'color': const Color(0xFFD0BCFF)},
        'Carbs': {'value': '${widget.macroData!['carbs']}g', 'percentage': 0.55, 'color': AppTheme.accentCyan},
        'Fat': {'value': '${widget.macroData!['fats']}g', 'percentage': 0.3, 'color': AppTheme.accentOrange},
      };
    } else {
      _macros = {
        'Protein': {'value': '35g', 'percentage': 0.7, 'color': const Color(0xFFD0BCFF)},
        'Carbs': {'value': '45g', 'percentage': 0.55, 'color': AppTheme.accentCyan},
        'Fat': {'value': '15g', 'percentage': 0.3, 'color': AppTheme.accentOrange},
      };
    }

    // Initialize ingredients from passed data or use fallback
    if (widget.ingredientsList != null) {
      _ingredients = widget.ingredientsList!.map((item) {
        if (item is Map) {
          return {
            'name': item['item']?.toString() ?? 'Food Item',
            'quantity': '${item['grams'] ?? '--'}g',
            'icon': _getIconForFood(item['item']?.toString() ?? ''),
            'cal': '${item['calories'] ?? '--'} kcal',
          };
        }
        return {
          'name': item.toString(),
          'quantity': '1 portion',
          'icon': _getIconForFood(item.toString()),
          'cal': '-- kcal',
        };
      }).toList();
    } else {
      _ingredients = [
        {'name': 'Egg Whites', 'quantity': '3 large', 'icon': Icons.egg_rounded, 'cal': '51 kcal'},
        {'name': 'Greek Yogurt', 'quantity': '1 cup (170g)', 'icon': Icons.icecream_rounded, 'cal': '100 kcal'},
      ];
    }
  }

  IconData _getIconForFood(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('egg')) return Icons.egg_rounded;
    if (lowerName.contains('chicken') || lowerName.contains('meat') || lowerName.contains('fish')) return Icons.restaurant_menu;
    if (lowerName.contains('rice') || lowerName.contains('grain') || lowerName.contains('oat')) return Icons.grain_rounded;
    if (lowerName.contains('berry') || lowerName.contains('fruit') || lowerName.contains('apple')) return Icons.spa_rounded;
    if (lowerName.contains('yogurt') || lowerName.contains('milk') || lowerName.contains('cheese')) return Icons.icecream_rounded;
    if (lowerName.contains('water') || lowerName.contains('shake')) return Icons.water_drop_rounded;
    return Icons.restaurant;
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
                    final provider = Provider.of<UserProvider>(context, listen: false);
                    final now = DateTime.now();
                    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    provider.updateChecklistItem(dateKey, 'meals', true);

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
