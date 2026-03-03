import 'package:flutter/material.dart';
import '../theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedFilter = '1M';

  // Mock data for different time ranges
  final Map<String, Map<String, dynamic>> _filterData = {
    '1W': {
      'points': [77.2, 77.0, 76.8, 76.9, 76.6, 76.5, 76.4],
      'labels': ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
      'change': '-0.8 kg this week',
      'current': '76.4',
    },
    '1M': {
      'points': [78.5, 78.2, 77.8, 77.5, 77.9, 77.2, 76.8, 76.4],
      'labels': ['SEP 15', 'SEP 20', 'SEP 25', 'SEP 30', 'OCT 05', 'OCT 10', 'OCT 12', 'OCT 15'],
      'change': '-2.1 kg this month',
      'current': '76.4',
    },
    '3M': {
      'points': [82.0, 81.2, 80.5, 79.8, 79.0, 78.5, 77.8, 77.0, 76.4],
      'labels': ['JUL', 'JUL', 'AUG', 'AUG', 'SEP', 'SEP', 'OCT', 'OCT', 'OCT'],
      'change': '-5.6 kg in 3 months',
      'current': '76.4',
    },
    '1Y': {
      'points': [90.0, 88.5, 86.0, 84.5, 83.0, 81.5, 80.0, 78.5, 77.0, 76.4],
      'labels': ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT'],
      'change': '-13.6 kg this year',
      'current': '76.4',
    },
    'All': {
      'points': [95.0, 92.0, 90.0, 88.0, 86.0, 84.0, 82.0, 80.0, 78.0, 76.4],
      'labels': ['2024', '', '2024', '', '2025', '', '2025', '', '2025', 'NOW'],
      'change': '-18.6 kg total',
      'current': '76.4',
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = _filterData[_selectedFilter]!;
    final points = data['points'] as List<double>;
    final labels = data['labels'] as List<String>;
    final change = data['change'] as String;

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
                          children: const [
                            Text('76.4', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text('kg', style: TextStyle(fontSize: 14, color: AppTheme.sunsetOrange, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.trending_down, color: Colors.greenAccent, size: 14),
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
                          children: const [
                            Text('72.0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text('kg', style: TextStyle(fontSize: 14, color: AppTheme.sunsetOrange, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.flag, color: Colors.white30, size: 14),
                            SizedBox(width: 4),
                            Text('4.4 kg to go', style: TextStyle(color: Colors.white30, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Time Filters — now functional
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
                  // Horizontal grid lines
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) => const Divider(color: Colors.white10)),
                  ),
                  // Dynamic chart line
                  CustomPaint(
                    size: const Size(double.infinity, 250),
                    painter: _DynamicChartPainter(points: points),
                  ),
                  // Tooltip at last point
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
                          Text('${points.last} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(labels.last, style: const TextStyle(fontSize: 8, color: Colors.white54, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // X-axis labels — dynamic
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

            // Daily Logs
            const Text('Daily Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _LogItem(icon: Icons.scale, title: 'Today, 08:30 AM', subtitle: 'Logged manually', value: '76.4 kg', iconColor: AppTheme.sunsetOrange),
            const SizedBox(height: 12),
            _LogItem(icon: Icons.scale, title: 'Yesterday, 07:45 AM', subtitle: 'From Smart Scale', value: '76.9 kg', opacity: 0.7),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
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

    // Create normalized points
    final chartPoints = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - ((points[i] - minVal) / range * (size.height * 0.7) + size.height * 0.1);
      chartPoints.add(Offset(x, y));
    }

    // Draw gradient fill
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

    // Draw line
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

    // Draw glow on last point
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
