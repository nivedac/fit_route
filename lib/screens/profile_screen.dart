import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Image & Info
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.charcoal,
                    boxShadow: [
                      BoxShadow(color: AppTheme.sunsetOrange.withOpacity(0.2), blurRadius: 15, spreadRadius: 0),
                    ],
                    border: Border.all(color: AppTheme.sunsetOrange, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.sunsetOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.charcoal, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Alex Johnson', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            const Text('alex.johnson@fitroute.ai', style: TextStyle(fontSize: 14, color: Colors.white54)),
            const SizedBox(height: 40),

            // Stats
            Row(
              children: [
                Expanded(child: _StatCard(value: '72', unit: 'kg')),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(value: '182', unit: 'cm')),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(value: '24', unit: 'yrs')),
              ],
            ),
            const SizedBox(height: 40),

            // Account Settings
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                child: const Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 16),
            
            _SettingsTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Update your personal details',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your app alerts',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Data protection settings',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _SettingsTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: '',
              onTap: () {
                // Return to login screen
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
            const SizedBox(height: 48),

            // Version
            const Text('VERSION 2.4.0', style: TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 4)),
            const SizedBox(height: 100), // Bottom nav padding
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 3),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String unit;

  const _StatCard({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, color: AppTheme.sunsetOrange, fontWeight: FontWeight.bold)),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.sunsetOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.sunsetOrange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
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
        if (index == 1) Navigator.pushReplacementNamed(context, '/progress');
        if (index == 2) Navigator.pushReplacementNamed(context, '/tracker');
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
