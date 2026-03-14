import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedFilter = '1M';

  List<double> _getFilteredPoints(UserProvider provider) {
    final logs = provider.weightLogs;
    if (logs.isEmpty) {
      // Return mock data if no real data exists
      return _getMockPoints();
    }

    final now = DateTime.now();
    Duration duration;
    switch (_selectedFilter) {
      case '1W':
        duration = const Duration(days: 7);
        break;
      case '1M':
        duration = const Duration(days: 30);
        break;
      case '3M':
        duration = const Duration(days: 90);
        break;
      case '1Y':
        duration = const Duration(days: 365);
        break;
      case 'All':
      default:
        duration = const Duration(days: 3650);
        break;
    }

    final cutoff = now.subtract(duration);
    final filtered = logs.where((log) {
      final date = DateTime.tryParse(log['date'] ?? '');
      return date != null && date.isAfter(cutoff);
    }).toList();

    if (filtered.isEmpty) return _getMockPoints();

    return filtered.reversed.map<double>((e) => (e['weight'] as num).toDouble()).toList();
  }

  List<double> _getMockPoints() {
    final mockData = {
      '1W': [77.2, 77.0, 76.8, 76.9, 76.6, 76.5, 76.4],
      '1M': [78.5, 78.2, 77.8, 77.5, 77.9, 77.2, 76.8, 76.4],
      '3M': [82.0, 81.2, 80.5, 79.8, 79.0, 78.5, 77.8, 77.0, 76.4],
      '1Y': [90.0, 88.5, 86.0, 84.5, 83.0, 81.5, 80.0, 78.5, 77.0, 76.4],
      'All': [95.0, 92.0, 90.0, 88.0, 86.0, 84.0, 82.0, 80.0, 78.0, 76.4],
    };
    return mockData[_selectedFilter] ?? [76.4];
  }

  String _getChangeText(List<double> points) {
    if (points.length < 2) return 'No change';
    final diff = points.last - points.first;
    final sign = diff <= 0 ? '' : '+';
    switch (_selectedFilter) {
      case '1W':
        return '$sign${diff.toStringAsFixed(1)} kg this week';
      case '1M':
        return '$sign${diff.toStringAsFixed(1)} kg this month';
      case '3M':
        return '$sign${diff.toStringAsFixed(1)} kg in 3 months';
      case '1Y':
        return '$sign${diff.toStringAsFixed(1)} kg this year';
      case 'All':
        return '$sign${diff.toStringAsFixed(1)} kg total';
      default:
        return '$sign${diff.toStringAsFixed(1)} kg';
    }
  }

  List<String> _getLabels(List<double> points) {
    final mockLabels = {
      '1W': ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
      '1M': ['W1', 'W1', 'W2', 'W2', 'W3', 'W3', 'W4', 'W4'],
      '3M': ['M1', 'M1', 'M1', 'M2', 'M2', 'M2', 'M3', 'M3', 'NOW'],
      '1Y': ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'NOW'],
      'All': ['START', '', '', '', '', '', '', '', '', 'NOW'],
    };
    return mockLabels[_selectedFilter] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final points = _getFilteredPoints(provider);
    final change = _getChangeText(points);
    final labels = _getLabels(points);
    final currentWeight = provider.weightLogs.isNotEmpty
        ? (provider.weightLogs.first['weight'] as num).toDouble()
        : provider.currentWeight;
    final targetWeight = provider.targetWeight;
    final remaining = currentWeight - targetWeight;

    // Build recent weight log entries
    final recentLogs = provider.weightLogs.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Progress Chart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT WEIGHT', style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(currentWeight.toStringAsFixed(1), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            const Text('kg', style: TextStyle(fontSize: 14, color: AppTheme.sunsetOrange, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              remaining > 0 ? Icons.trending_down : Icons.trending_up,
                              color: Colors.greenAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(change, style: const TextStyle(color: Colors.greenAccent, fontSize: 12), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TARGET GOAL', style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(targetWeight.toStringAsFixed(1), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            const Text('kg', style: TextStyle(fontSize: 14, color: AppTheme.sunsetOrange, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flag, color: Colors.white30, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              remaining > 0
                                  ? '${remaining.toStringAsFixed(1)} kg to go'
                                  : 'Goal reached! 🎉',
                              style: const TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Time Filters — functional
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['1W', '1M', '3M', '1Y', 'All'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppTheme.sunsetOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppTheme.sunsetOrange.withOpacity(0.3)),
                          )
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.sunsetOrange : Colors.white54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Chart area — dynamic based on selected filter
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.sunsetOrange.withOpacity(0.15), Colors.transparent],
                ),
                border: const Border(
                  bottom: BorderSide(color: Colors.white12, width: 1),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) => const Divider(color: Colors.white10)),
                  ),
                  CustomPaint(
                    size: const Size(double.infinity, 250),
                    painter: _DynamicChartPainter(points: points),
                  ),
                  Positioned(
                    right: 20,
                    top: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Text('${points.last.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          if (labels.isNotEmpty)
                            Text(labels.last, style: const TextStyle(fontSize: 8, color: Colors.white54, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // X-axis labels
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (labels.isNotEmpty)
                  Text(labels.first, style: const TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold)),
                if (labels.length > 1)
                  Text(labels[labels.length ~/ 2], style: const TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold)),
                if (labels.length > 2)
                  Text(labels.last, style: const TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),

            // Daily Logs — real data
            const Text('Recent Weight Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            if (recentLogs.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('No weight logs yet. Start by logging your weight in the Tracker!',
                      style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                ),
              )
            else
              ...recentLogs.asMap().entries.map((entry) {
                final log = entry.value;
                final weight = (log['weight'] as num).toDouble();
                final date = DateTime.tryParse(log['date'] ?? '') ?? DateTime.now();
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;
                final dateStr = isToday
                    ? 'Today'
                    : '${_monthName(date.month)} ${date.day}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LogItem(
                    icon: Icons.scale,
                    title: dateStr,
                    subtitle: 'Logged manually',
                    value: '${weight.toStringAsFixed(1)} kg',
                    iconColor: AppTheme.sunsetOrange,
                    opacity: entry.key == 0 ? 1.0 : 0.7,
                  ),
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _LogItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color iconColor;
  final double opacity;

  const _LogItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.iconColor = Colors.white54,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _DynamicChartPainter extends CustomPainter {
  final List<double> points;

  _DynamicChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final chartPoints = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - ((points[i] - minVal) / range * (size.height * 0.7) + size.height * 0.1);
      chartPoints.add(Offset(x, y));
    }

    if (chartPoints.length >= 2) {
      final fillPath = Path();
      fillPath.moveTo(chartPoints.first.dx, size.height);
      for (int i = 0; i < chartPoints.length - 1; i++) {
        final p0 = chartPoints[i];
        final p1 = chartPoints[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }
      fillPath.lineTo(chartPoints.last.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF4D00).withOpacity(0.15),
            const Color(0xFFFF4D00).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFFF4D00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final linePath = Path();
    linePath.moveTo(chartPoints.first.dx, chartPoints.first.dy);
    for (int i = 0; i < chartPoints.length - 1; i++) {
      final p0 = chartPoints[i];
      final p1 = chartPoints[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(linePath, linePaint);

    final lastPoint = chartPoints.last;
    final glowPaint = Paint()
      ..color = const Color(0xFFFF4D00).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 10, glowPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFFFF4D00)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
