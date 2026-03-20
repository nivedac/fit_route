import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class PlanResultScreen extends StatefulWidget {
  const PlanResultScreen({super.key});

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Set initial day index based on current day of week (0=Monday)
    _selectedDayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDayIndex = (picked.weekday - 1).clamp(0, 6);
      });
    }
  }

  String get _formattedDate {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final prefix = isToday
        ? 'TODAY'
        : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
            [_selectedDate.weekday - 1];
    return '$prefix, ${months[_selectedDate.month - 1]} ${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  int _parseInt(dynamic val, int defaultVal) {
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final planData = userProvider.aiPlanData;

    // Parse Gemini-specific fields — NO hardcoded defaults
    final String bmi = planData?['bmi']?.toString() ?? '--';
    final String tdeeCalories = planData?['tdeeCalories']?.toString() ?? '--';
    final String goalAdjustedCalories =
        planData?['goalAdjustedCalories']?.toString() ?? '--';

    final int dailyCalories = _parseInt(planData?['dailyCalories'], 0);
    final macros = planData?['macros'] as Map<String, dynamic>? ?? {};
    final proteinG = _parseInt(macros['protein']?['grams'], 0);
    final carbsG = _parseInt(macros['carbs']?['grams'], 0);
    final fatsG = _parseInt(macros['fats']?['grams'], 0);
    final proteinPct =
        _parseInt(macros['protein']?['percentage'], 0) / 100.0;
    final carbsPct = _parseInt(macros['carbs']?['percentage'], 0) / 100.0;
    final fatsPct = _parseInt(macros['fats']?['percentage'], 0) / 100.0;

    // Workout schedule
    final workoutData = planData?['workout'] as Map<String, dynamic>? ?? {};
    final weeklySchedule =
        (workoutData['weeklySchedule'] as List<dynamic>?) ?? [];

    // Diet meals
    final dietData = planData?['diet'] as Map<String, dynamic>? ?? {};
    final meals = (dietData['meals'] as List<dynamic>?) ?? [];

    // Get today's workout
    final todayWorkout = _selectedDayIndex < weeklySchedule.length
        ? weeklySchedule[_selectedDayIndex] as Map<String, dynamic>
        : null;

    // Show empty state if no plan generated yet
    if (planData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F10),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 64, color: Color(0xFFD0BCFF)),
                const SizedBox(height: 24),
                const Text('No Plan Generated Yet',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Complete the onboarding to generate\nyour personalized AI plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    userProvider.startGeneration();
                    Navigator.pushNamed(context, '/generating-plan');
                  },
                  icon: const Icon(Icons.bolt),
                  label: const Text('GENERATE PLAN',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0BCFF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      // Regenerate Plan FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Regenerate Plan?'),
              content: const Text(
                'This will create a new AI plan based on your current profile data. Your existing plan will be replaced.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    userProvider.startGeneration();
                    Navigator.pushNamed(context, '/generating-plan');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0BCFF),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Regenerate'),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFFD0BCFF),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.refresh, size: 20),
        label:
            const Text('REGEN', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
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
                      Text(_formattedDate,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      const Text('AI Plan Strategy',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0BCFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 12, color: Color(0xFFD0BCFF)),
                            SizedBox(width: 4),
                            Text('GEMINI',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD0BCFF))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10)),
                          child: const Icon(Icons.calendar_today, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BMI & Calorie Summary Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatsChip(
                    icon: Icons.monitor_weight_outlined,
                    label: 'BMI',
                    value: bmi,
                    color: _getBmiColor(bmi),
                  ),
                  const SizedBox(width: 8),
                  _StatsChip(
                    icon: Icons.local_fire_department,
                    label: 'TDEE',
                    value: tdeeCalories,
                    color: AppTheme.accentOrange,
                  ),
                  const SizedBox(width: 8),
                  _StatsChip(
                    icon: Icons.track_changes,
                    label: 'TARGET',
                    value: goalAdjustedCalories,
                    color: AppTheme.accentEmerald,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Day Selector
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: weeklySchedule.length,
                itemBuilder: (context, index) {
                  final day =
                      weeklySchedule[index] as Map<String, dynamic>;
                  final dayName =
                      (day['day'] as String?) ?? 'Day ${index + 1}';
                  final isSelected = index == _selectedDayIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDayIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD0BCFF)
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD0BCFF)
                                  : Colors.white10),
                        ),
                        child: Center(
                          child: Text(
                            dayName.length >= 3
                                ? dayName.substring(0, 3).toUpperCase()
                                : dayName.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFD0BCFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFFD0BCFF),
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'WORKOUT'),
                  Tab(text: 'NUTRITION'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // WORKOUT TAB
                  _buildWorkoutTab(todayWorkout),
                  // NUTRITION TAB
                  _buildNutritionTab(dailyCalories, proteinG, carbsG,
                      fatsG, proteinPct, carbsPct, fatsPct, meals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(String bmiStr) {
    final bmi = double.tryParse(bmiStr) ?? 0;
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25) return AppTheme.accentEmerald;
    if (bmi < 30) return AppTheme.accentOrange;
    return Colors.redAccent;
  }

  Widget _buildWorkoutTab(Map<String, dynamic>? todayWorkout) {
    if (todayWorkout == null) {
      return const Center(
          child: Text('No workout data available',
              style: TextStyle(color: Colors.white54)));
    }

    final sessionName = todayWorkout['sessionName'] as String? ?? 'Workout';
    final duration = todayWorkout['duration'] as String? ?? '0 mins';
    final difficulty =
        todayWorkout['difficulty'] as String? ?? 'Intermediate';
    final exercises =
        (todayWorkout['exercises'] as List<dynamic>?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Session Header Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD0BCFF).withOpacity(0.15),
                const Color(0xFFD0BCFF).withOpacity(0.02)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFD0BCFF).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0BCFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.fitness_center,
                    color: Color(0xFFD0BCFF), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sessionName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(duration,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(difficulty.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentCyan)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text('EXERCISES',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 2)),
        const SizedBox(height: 12),

        // Exercise List
        ...exercises.asMap().entries.map((entry) {
          final idx = entry.key;
          final ex = entry.value as Map<String, dynamic>;
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/workout-detail',
                arguments: {
                  'title': sessionName,
                  'duration': duration,
                  'difficulty': difficulty,
                  'exercises': exercises,
                },
              );
            },
            child: _ExerciseCard(
              index: idx + 1,
              name: ex['name'] as String? ?? 'Exercise',
              sets: ex['sets'] is int
                  ? ex['sets']
                  : int.tryParse(ex['sets']?.toString() ?? '3') ?? 3,
              reps: ex['reps']?.toString() ?? '0',
              rest: ex['rest'] as String? ?? '60s',
            ),
          );
        }),

        const SizedBox(height: 24),

        // Start Workout Button
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/workout-detail',
              arguments: {
                'title': sessionName,
                'duration': duration,
                'difficulty': difficulty,
                'exercises': exercises,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 24),
              SizedBox(width: 8),
              Text('Start Workout',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNutritionTab(
      int dailyCalories,
      dynamic proteinG,
      dynamic carbsG,
      dynamic fatsG,
      double proteinPct,
      double carbsPct,
      double fatsPct,
      List<dynamic> meals) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Daily Energy Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD0BCFF).withOpacity(0.15),
                const Color(0xFFD0BCFF).withOpacity(0.02)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFD0BCFF).withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daily Energy Target',
                      style: TextStyle(
                          fontSize: 14, color: Colors.white70)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color:
                            const Color(0xFFD0BCFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 10, color: Color(0xFFD0BCFF)),
                        SizedBox(width: 4),
                        Text('GEMINI AI',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD0BCFF))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('${_formatNumber(dailyCalories)} kcal',
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Macro Bars
              _MacroBar(
                  label: 'Protein',
                  value: '${proteinG}g',
                  percentage: proteinPct,
                  color: const Color(0xFFD0BCFF)),
              const SizedBox(height: 12),
              _MacroBar(
                  label: 'Carbs',
                  value: '${carbsG}g',
                  percentage: carbsPct,
                  color: AppTheme.accentCyan),
              const SizedBox(height: 12),
              _MacroBar(
                  label: 'Fats',
                  value: '${fatsG}g',
                  percentage: fatsPct,
                  color: AppTheme.accentOrange),
            ],
          ),
        ),

        const SizedBox(height: 32),
        const Text('MEAL PLAN',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 2)),
        const SizedBox(height: 16),

        // Meal Cards
        ...meals.map((meal) {
          final m = meal as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/meal-detail',
                  arguments: {
                    'title': m['name'] as String? ?? 'Meal',
                    'calories': '${m['calories']} kcal',
                    'macroData': {
                      'protein': m['protein'],
                      'carbs': m['carbs'],
                      'fats': m['fats'],
                    },
                    'ingredientsList': m['items'],
                  },
                );
              },
              child: _AIMealCard(
                type: m['type']?.toString() ?? 'Meal',
                name: m['name']?.toString() ?? 'Meal',
                calories: _parseInt(m['calories'], 0),
                protein: _parseInt(m['protein'], 0),
                carbs: _parseInt(m['carbs'], 0),
                fats: _parseInt(m['fats'], 0),
                items: (m['items'] as List<dynamic>?) ?? [],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return n.toString();
  }
}

// ─── Stats Chip Widget ──────────────────────────────────────

class _StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatsChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.7),
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

// ─── Exercise Card Widget ───────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final int index;
  final String name;
  final int sets;
  final String reps;
  final String rest;

  const _ExerciseCard({
    required this.index,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFD0BCFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('$index',
                    style: const TextStyle(
                        color: Color(0xFFD0BCFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniChip(label: '$sets sets'),
                      const SizedBox(width: 6),
                      _MiniChip(label: '$reps reps'),
                      const SizedBox(width: 6),
                      _MiniChip(label: '$rest rest'),
                    ],
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

class _MiniChip extends StatelessWidget {
  final String label;
  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final String value;
  final double percentage;
  final Color color;

  const _MacroBar(
      {required this.label,
      required this.value,
      required this.percentage,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _AIMealCard extends StatelessWidget {
  final String type;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<dynamic> items;

  const _AIMealCard({
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.items,
  });

  IconData get _mealIcon {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(_mealIcon, color: AppTheme.accentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentOrange,
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('$calories kcal',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Macro row
          Row(
            children: [
              _MacroChip(
                  label: 'P',
                  value: '${protein}g',
                  color: const Color(0xFFD0BCFF)),
              const SizedBox(width: 8),
              _MacroChip(
                  label: 'C',
                  value: '${carbs}g',
                  color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              _MacroChip(
                  label: 'F',
                  value: '${fats}g',
                  color: AppTheme.accentOrange),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                String label = item.toString();
                if (item is Map) {
                  // Show item name (which already includes portions)
                  label = item['item']?.toString() ?? item.toString();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white60)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
