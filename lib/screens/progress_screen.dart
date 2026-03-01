import 'package:flutter/material.dart';
import '../theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          children: const [
                            Icon(Icons.trending_down, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 4),
                            Text('-0.8 kg this week', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
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

            // Time Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TimeFilter(label: '1W', isSelected: false),
                _TimeFilter(label: '1M', isSelected: true),
                _TimeFilter(label: '3M', isSelected: false),
                _TimeFilter(label: '1Y', isSelected: false),
                _TimeFilter(label: 'All', isSelected: false),
              ],
            ),
            const SizedBox(height: 32),

            // Chart area placeholder (using a container to represent the chart)
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
                  // Mock Line Path
                  CustomPaint(
                    size: const Size(double.infinity, 250),
                    painter: _MockChartPainter(),
                  ),
                  // Tooltip
                  Positioned(
                    right: 60,
                    top: 80,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                      ),
                      child: Column(
                        children: const [
                          Text('76.4 kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('OCT 12', style: TextStyle(fontSize: 8, color: Colors.white54, fontWeight: FontWeight.bold)),
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
              children: const [
                Text('SEP 15', style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold)),
                Text('SEP 30', style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold)),
                Text('OCT 15', style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),

            // Daily Logs
            const Text('Daily Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _LogItem(icon: Icons.scale, title: 'Today, 08:30 AM', subtitle: 'Logged manually', value: '76.4 kg', iconColor: AppTheme.sunsetOrange),
            const SizedBox(height: 12),
            _LogItem(icon: Icons.scale, title: 'Yesterday, 07:45 AM', subtitle: 'From Smart Scale', value: '76.9 kg', opacity: 0.7),
            
            const SizedBox(height: 80), // Bottom nav padding
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 1),
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

class _TimeFilter extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TimeFilter({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: AppTheme.sunsetOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            )
          : null,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppTheme.sunsetOrange : Colors.white54,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme.charcoal.withOpacity(0.9),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.sunsetOrange,
      unselectedItemColor: Colors.white54,
      currentIndex: currentIndex,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      onTap: (index) {
        if (index == 0) Navigator.pushReplacementNamed(context, '/home');
        if (index == 2) Navigator.pushReplacementNamed(context, '/tracker');
        if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Tracker'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppTheme.sunsetOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    var path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.35, size.width * 0.4, size.height * 0.55);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.75, size.width * 0.8, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    var circlePaint = Paint()
      ..color = AppTheme.sunsetOrange
      ..style = PaintingStyle.fill;
    
    var glowPaint = Paint()
      ..color = AppTheme.sunsetOrange.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.45), 8, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.45), 4, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
