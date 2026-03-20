import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _weightController = TextEditingController();

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${months[d.month - 1]} ${d.day}';
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentKey = _dateKey(_selectedDate);
    final checklist = userProvider.getChecklistForDate(currentKey);
    final completedCount = checklist.values.where((v) => v).length;
    final totalCount = checklist.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final streak = userProvider.getCurrentStreak();

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    // Calculate the start of the goal cycle
    final planStart = userProvider.planStartDate ?? todayMidnight;
    final goalDays = userProvider.goalDurationDays;

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
              _isToday(_selectedDate)
                  ? 'Today • ${_formatDate(_selectedDate)}'
                  : _formatDate(_selectedDate),
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppTheme.sunsetOrange,
                        surface: AppTheme.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                color: AppTheme.surface,
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Streak
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT STREAK', style: TextStyle(color: AppTheme.sunsetOrange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$streak', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Text('Days', style: TextStyle(fontSize: 18, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Completed', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text('$completedCount/$totalCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Today's Metric
            Row(
              children: const [
                Icon(Icons.scale, color: AppTheme.sunsetOrange),
                SizedBox(width: 8),
                Text("Log Weight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("LOG TODAY'S WEIGHT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _weightController,
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: '00.0',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const Text('kg', style: TextStyle(fontSize: 20, color: Colors.white54, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final value = double.tryParse(_weightController.text);
                      if (value != null && value > 0) {
                        userProvider.logWeight(value, _selectedDate);
                        _weightController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Weight logged: ${value.toStringAsFixed(1)} kg ✅'),
                            backgroundColor: AppTheme.sunsetOrange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a valid weight'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.sunsetOrange,
                      foregroundColor: AppTheme.charcoal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Daily Checklist
            Row(
              children: const [
                Icon(Icons.checklist, color: AppTheme.sunsetOrange),
                SizedBox(width: 8),
                Text("Today's Checklist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _ChecklistItem(
              icon: Icons.fitness_center,
              label: 'Completed workout',
              isChecked: checklist['workout'] ?? false,
              onTap: () => userProvider.toggleChecklistItem(currentKey, 'workout'),
            ),
            const SizedBox(height: 8),
            _ChecklistItem(
              icon: Icons.restaurant,
              label: 'Logged meals',
              isChecked: checklist['meals'] ?? false,
              onTap: () => userProvider.toggleChecklistItem(currentKey, 'meals'),
            ),
            const SizedBox(height: 8),
            _ChecklistItem(
              icon: Icons.water_drop,
              label: 'Drank enough water',
              isChecked: checklist['water'] ?? false,
              onTap: () => userProvider.toggleChecklistItem(currentKey, 'water'),
            ),
            const SizedBox(height: 8),
            _ChecklistItem(
              icon: Icons.directions_walk,
              label: 'Completed steps',
              isChecked: checklist['steps'] ?? false,
              onTap: () => userProvider.toggleChecklistItem(currentKey, 'steps'),
            ),
            const SizedBox(height: 8),
            _ChecklistItem(
              icon: Icons.scale,
              label: 'Logged weight',
              isChecked: checklist['weight'] ?? false,
              onTap: () => userProvider.toggleChecklistItem(currentKey, 'weight'),
            ),
            const SizedBox(height: 24),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppTheme.surface,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.sunsetOrange),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(progress * 100).toInt()}% DONE', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 32),

            // Calendar Grid
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppTheme.sunsetOrange),
                const SizedBox(width: 8),
                Text('$goalDays Day Overview', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: goalDays,
              itemBuilder: (context, index) {
                final day = planStart.add(Duration(days: index));
                final dayKey = _dateKey(day);
                final dayChecklist = userProvider.getChecklistForDate(dayKey);
                final allDone = dayChecklist.values.every((v) => v);
                final anyDone = dayChecklist.values.any((v) => v);
                final isToday = _isToday(day);
                final isSelected = dayKey == currentKey;
                final isFuture = day.isAfter(todayMidnight);
                final isPassed = day.isBefore(todayMidnight) && !isToday;

                return GestureDetector(
                  onTap: isFuture ? null : () {
                    setState(() => _selectedDate = day);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.sunsetOrange.withOpacity(0.15)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.sunsetOrange.withOpacity(0.5)
                            : Colors.white.withOpacity(0.05),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday ? 'TODAY' : 'D${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isToday || isSelected ? AppTheme.sunsetOrange : Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (allDone && !isFuture)
                          const Icon(Icons.check_circle, color: AppTheme.sunsetOrange, size: 24)
                        else if (anyDone && !isFuture)
                          const Icon(Icons.radio_button_checked, color: AppTheme.sunsetOrange, size: 24)
                        else if (isFuture)
                          const Icon(Icons.lock_outline, color: Colors.white10, size: 20)
                        else if (isPassed && !anyDone)
                          const Icon(Icons.close, color: Colors.white24, size: 24)
                        else
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isChecked;
  final VoidCallback onTap;

  const _ChecklistItem({
    required this.icon,
    required this.label,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked
              ? AppTheme.sunsetOrange.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? AppTheme.sunsetOrange.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? AppTheme.sunsetOrange : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppTheme.sunsetOrange : Colors.white30,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(icon, color: isChecked ? AppTheme.sunsetOrange : Colors.white38, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isChecked ? Colors.white : Colors.white70,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
