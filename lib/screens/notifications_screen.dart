import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../theme.dart';

// Global notifications plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  void initState() {
    super.initState();
    _loadPreferences();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workoutReminders = prefs.getBool('notif_workout') ?? true;
      _dietAlerts = prefs.getBool('notif_diet') ?? true;
      _hydrationReminders = prefs.getBool('notif_hydration') ?? false;
      _appUpdates = prefs.getBool('notif_updates') ?? true;
      _newsletter = prefs.getBool('notif_newsletter') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fitroute_reminders',
      'FitRoute Reminders',
      channelDescription: 'Workout and meal reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  void _toggleWorkoutReminders(bool val) {
    setState(() => _workoutReminders = val);
    _savePreference('notif_workout', val);
    if (val) {
      _scheduleNotification(id: 1, title: '💪 Workout Time!', body: 'Time to crush your training session. Let\'s go!');
    } else {
      _cancelNotification(1);
    }
  }

  void _toggleDietAlerts(bool val) {
    setState(() => _dietAlerts = val);
    _savePreference('notif_diet', val);
    if (val) {
      _scheduleNotification(id: 2, title: '🍽️ Meal Reminder', body: 'Don\'t forget to log your meals and stay on track!');
    } else {
      _cancelNotification(2);
    }
  }

  void _toggleHydrationReminders(bool val) {
    setState(() => _hydrationReminders = val);
    _savePreference('notif_hydration', val);
    if (val) {
      _scheduleNotification(id: 3, title: '💧 Hydration Check', body: 'Remember to drink water! Stay hydrated for peak performance.');
    } else {
      _cancelNotification(3);
    }
  }

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
                    onChanged: _toggleWorkoutReminders,
                  ),
                  _NotificationTile(
                    icon: Icons.restaurant,
                    title: 'Diet Alerts',
                    subtitle: 'Meal timing and macro tracking',
                    value: _dietAlerts,
                    onChanged: _toggleDietAlerts,
                  ),
                  _NotificationTile(
                    icon: Icons.water_drop,
                    title: 'Hydration Reminders',
                    subtitle: 'Keep your performance peaked',
                    value: _hydrationReminders,
                    onChanged: _toggleHydrationReminders,
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
                    onChanged: (val) {
                      setState(() => _appUpdates = val);
                      _savePreference('notif_updates', val);
                    },
                  ),
                  _NotificationTile(
                    icon: Icons.mail_outline,
                    title: 'Newsletter',
                    subtitle: 'Weekly fitness tips and community highlights',
                    value: _newsletter,
                    onChanged: (val) {
                      setState(() => _newsletter = val);
                      _savePreference('notif_newsletter', val);
                    },
                  ),
                ],
              ),
            ),

            // Test Notification Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _scheduleNotification(
                    id: 99,
                    title: '🎯 FitRoute',
                    body: 'Test notification! Your reminders are working perfectly.',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Test notification sent! 🔔'),
                      backgroundColor: AppTheme.sunsetOrange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.sunsetOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Send Test Notification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            // System Settings Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () async {
                  // Open app notification settings
                  final androidPlugin = flutterLocalNotificationsPlugin
                      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
                  if (androidPlugin != null) {
                    await androidPlugin.requestNotificationsPermission();
                  }
                },
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
