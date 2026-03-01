import 'package:flutter/material.dart';
import '../theme.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Daily Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Journey Progress • Day 14 of 30', style: TextStyle(fontSize: 14, color: Colors.white54)),
          ],
        ),
        actions: [
          Container(
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
                        children: const [
                          Text('12', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Text('Days', style: TextStyle(fontSize: 18, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Consistency', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      SizedBox(height: 4),
                      Text('85%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
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
                Text("Today's Metric", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    onPressed: () {},
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

            // Checklist Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.checklist, color: AppTheme.sunsetOrange),
                    SizedBox(width: 8),
                    Text("Checklist Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Text('30 Day Cycle', style: TextStyle(fontSize: 14, color: Colors.white54)),
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
              itemCount: 20, // Sample 20 days
              itemBuilder: (context, index) {
                bool isCompleted = index < 13 && index != 7;
                bool isMissed = index == 7;
                bool isToday = index == 13;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.sunsetOrange.withOpacity(0.1) : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday ? AppTheme.sunsetOrange.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'TODAY' : 'D${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday ? AppTheme.sunsetOrange : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: AppTheme.sunsetOrange, size: 24)
                      else if (isMissed)
                        const Icon(Icons.close, color: Colors.white24, size: 24)
                      else if (isToday)
                        const Icon(Icons.radio_button_checked, color: AppTheme.sunsetOrange, size: 24)
                      else
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.46,
                      backgroundColor: AppTheme.surface,
                      valueColor: AlwaysStoppedAnimation(AppTheme.sunsetOrange),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('46% DONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 2),
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
        if (index == 1) Navigator.pushReplacementNamed(context, '/progress');
        // index 2 is current
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
