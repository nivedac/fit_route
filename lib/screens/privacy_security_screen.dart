import 'package:flutter/material.dart';
import '../theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

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
        title: const Text('Privacy & Security', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Score Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.sunsetOrange.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.sunsetOrange.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SECURITY SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.sunsetOrange, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        const Text('Strong', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Your account is well protected. Keep your recovery info updated for maximum safety.',
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_user, color: AppTheme.sunsetOrange.withOpacity(0.2), size: 64),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Login & Access
            _SectionLabel('LOGIN & ACCESS'),
            const SizedBox(height: 12),
            _SecurityTile(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Last changed 3 months ago',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SecurityTile(
              icon: Icons.enhanced_encryption,
              title: 'Two-Factor Authentication',
              subtitle: 'Secured via SMS and App',
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Data & Privacy
            _SectionLabel('DATA & PRIVACY'),
            const SizedBox(height: 12),
            _SecurityTile(
              icon: Icons.safety_check,
              title: 'Data Permissions',
              subtitle: 'Manage how we use your fitness data',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SecurityTile(
              icon: Icons.visibility_off,
              title: 'Profile Visibility',
              subtitle: "Set to 'Friends Only'",
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Advanced
            _SectionLabel('ADVANCED'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.sunsetOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.devices, color: AppTheme.sunsetOrange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Logged Devices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('2 active sessions', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.sunsetOrange.withOpacity(0.2),
                      foregroundColor: AppTheme.sunsetOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.sunsetOrange, letterSpacing: 1)),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecurityTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
