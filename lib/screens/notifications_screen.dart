import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _workoutReminders = true;
  bool _dietAlerts = true;
  bool _hydrationReminders = false;
  bool _appUpdates = true;
  bool _newsletter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: AppTheme.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.sunsetOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.sunsetOrange.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.sunsetOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Stay on track', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Keep your notifications enabled for the best fitness journey experience.',
                              style: TextStyle(fontSize: 14, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Alerts & Reminders Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                    child: Text('ALERTS & REMINDERS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.sunsetOrange, letterSpacing: 1)),
                  ),
                  _NotificationTile(
                    icon: Icons.fitness_center,
                    title: 'Workout Reminders',
                    subtitle: 'Daily cues for your training sessions',
                    value: _workoutReminders,
                    onChanged: (val) => setState(() => _workoutReminders = val),
                  ),
                  _NotificationTile(
                    icon: Icons.restaurant,
                    title: 'Diet Alerts',
                    subtitle: 'Meal timing and macro tracking',
                    value: _dietAlerts,
                    onChanged: (val) => setState(() => _dietAlerts = val),
                  ),
                  _NotificationTile(
                    icon: Icons.water_drop,
                    title: 'Hydration Reminders',
                    subtitle: 'Keep your performance peaked',
                    value: _hydrationReminders,
                    onChanged: (val) => setState(() => _hydrationReminders = val),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                    child: Text('APPLICATION',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.sunsetOrange, letterSpacing: 1)),
                  ),
                  _NotificationTile(
                    icon: Icons.system_update,
                    title: 'App Updates',
                    subtitle: 'New features and performance improvements',
                    value: _appUpdates,
                    onChanged: (val) => setState(() => _appUpdates = val),
                  ),
                  _NotificationTile(
                    icon: Icons.mail_outline,
                    title: 'Newsletter',
                    subtitle: 'Weekly fitness tips and community highlights',
                    value: _newsletter,
                    onChanged: (val) => setState(() => _newsletter = val),
                  ),
                ],
              ),
            ),

            // System Settings Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.settings_suggest, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text('System Notification Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                      Icon(Icons.open_in_new, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white38)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.sunsetOrange,
              inactiveTrackColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}
