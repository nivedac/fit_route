import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/user_provider.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Text(
                        'Select Environment',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('PERSONALIZATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                        Text('STEP 2/5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD0BCFF))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFD0BCFF)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Where will you \n',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'be training?',
                        style: TextStyle(color: Color(0xFFD0BCFF)),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Text(
                  'Choose an environment to optimize your AI-generated equipment list.',
                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cards
              _WorkoutCard(
                title: 'Home Setup',
                subtitle: 'No equipment needed',
                description: 'Bodyweight, resistance bands, and minimal gear focus. Ideal for small spaces and busy schedules.',
                icon: Icons.house,
                accentColor: AppTheme.accentCyan,
                badgeText: 'FLEXIBLE',
                imagePath: 'https://images.unsplash.com/photo-1598136490941-30d885318abd?auto=format&fit=crop&q=80', // Proxy image
                onTap: () {
                  userProvider.setWorkoutEnvironment('Home Setup');
                  Navigator.pushNamed(context, '/difficulty-selection');
                },
              ),
              
              _WorkoutCard(
                title: 'Commercial Gym',
                subtitle: 'Full access facility',
                description: 'Full access to racks, machines, and heavy weights. Optimized for strength and hypertrophy.',
                icon: Icons.fitness_center,
                accentColor: AppTheme.accentEmerald,
                badgeText: 'PROFESSIONAL',
                imagePath: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80', // Proxy image
                onTap: () {
                  userProvider.setWorkoutEnvironment('Commercial Gym');
                  Navigator.pushNamed(context, '/difficulty-selection');
                },
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final String imagePath;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.multiply,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.surface.withOpacity(0.8), AppTheme.surface],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor)),
                        const SizedBox(width: 6),
                        Text(badgeText, style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: accentColor.withOpacity(0.2))),
                        child: Icon(icon, color: accentColor, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue with ${title.split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
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
